# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

param(
  [switch]$Enable,
  [int]$Port = 22,
  [switch]$AllowFirewall
)
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecuciÃ³n desatendida
if ($env:GITEA_BOOTSTRAP_ENABLE_SSH -and $env:GITEA_BOOTSTRAP_ENABLE_SSH -eq 'true') {
  $Enable = $true
}
if ($env:GITEA_BOOTSTRAP_SSH_PORT -and $env:GITEA_BOOTSTRAP_SSH_PORT -ne '') {
  $Port = [int]$env:GITEA_BOOTSTRAP_SSH_PORT
}
if ($env:GITEA_BOOTSTRAP_SSH_FIREWALL -and $env:GITEA_BOOTSTRAP_SSH_FIREWALL -eq 'true') {
  $AllowFirewall = $true
}

if (-not $Enable) {
  Write-Host "SSH no habilitado. Use -Enable o configure GITEA_BOOTSTRAP_ENABLE_SSH='true'" -ForegroundColor Yellow

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
  exit 0
}

Write-Host "Habilitando servidor SSH en Windows..." -ForegroundColor Cyan

# Verificar si estamos en Windows Server o Windows 10/11 con OpenSSH disponible
$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
Write-Host "Sistema operativo: $($osInfo.Caption)" -ForegroundColor Green

# Instalar la caracterÃ­stica OpenSSH Server si no estÃ¡ presente
try {
  $sshFeature = Get-WindowsCapability -Online | Where-Object { $_.Name -like 'OpenSSH.Server*' }
  if (-not $sshFeature -or $sshFeature.State -ne 'Installed') {
    Write-Host "Instalando OpenSSH Server..." -ForegroundColor Yellow
    Add-WindowsCapability -Online -Name $sshFeature.Name
    Write-Host "OpenSSH Server instalado correctamente" -ForegroundColor Green
  } else {
    Write-Host "OpenSSH Server ya estÃ¡ instalado" -ForegroundColor Green
  }
} catch {
  Write-Error "Error al instalar OpenSSH Server: $_"
  exit 1
}

# Configurar el servicio sshd
try {
  Write-Host "Configurando servicio sshd..." -ForegroundColor Yellow
  
  # Iniciar el servicio si no estÃ¡ corriendo
  $sshService = Get-Service -Name 'sshd' -ErrorAction SilentlyContinue
  if (-not $sshService) {
    Write-Error "Servicio sshd no encontrado despuÃ©s de la instalaciÃ³n"
    exit 1
  }
  
  if ($sshService.Status -ne 'Running') {
    Start-Service -Name 'sshd'
    Write-Host "Servicio sshd iniciado" -ForegroundColor Green
  }
  
  # Configurar para inicio automÃ¡tico
  Set-Service -Name 'sshd' -StartupType Automatic
  Write-Host "Servicio sshd configurado para inicio automÃ¡tico" -ForegroundColor Green
  
} catch {
  Write-Error "Error al configurar el servicio sshd: $_"
  exit 1
}

# Configurar firewall si se solicita
if ($AllowFirewall) {
  try {
    Write-Host "Configurando regla de firewall para SSH en puerto $Port..." -ForegroundColor Yellow
    
    # Eliminar regla existente si existe
    $existingRule = Get-NetFirewallRule -DisplayName "OpenSSH Server" -ErrorAction SilentlyContinue
    if ($existingRule) {
      Remove-NetFirewallRule -DisplayName "OpenSSH Server"
      Write-Host "Regla de firewall existente eliminada" -ForegroundColor Yellow
    }
    
    # Crear nueva regla
    New-NetFirewallRule -DisplayName "OpenSSH Server" -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow -Description "Allow SSH connections on port $Port"
    Write-Host "Regla de firewall creada para puerto $Port" -ForegroundColor Green
    
  } catch {
    Write-Error "Error al configurar firewall: $_"
    exit 1
  }
}

# Configurar puerto SSH si es diferente del predeterminado
if ($Port -ne 22) {
  try {
    Write-Host "Configurando puerto SSH a $Port..." -ForegroundColor Yellow
    
    # Ruta del archivo de configuraciÃ³n SSH
    $sshConfigPath = "$env:ProgramData\ssh\sshd_config"
    
    if (Test-Path $sshConfigPath) {
      # Leer configuraciÃ³n actual
      $configContent = Get-Content $sshConfigPath
      
      # Reemplazar o agregar puerto
      $portLineFound = $false
      $newConfig = @()
      foreach ($line in $configContent) {
        if ($line -match '^#\s*Port\s+\d+|^Port\s+\d+') {
          $newConfig += "Port $Port"
          $portLineFound = $true
        } else {
          $newConfig += $line
        }
      }
      
      # Si no se encontrÃ³ lÃ­nea de puerto, agregarla
      if (-not $portLineFound) {
        $newConfig = @("Port $Port") + $newConfig
      }
      
      # Guardar configuraciÃ³n
      $newConfig | Set-Content $sshConfigPath -Encoding UTF8
      
      # Reiniciar servicio para aplicar cambios
      Restart-Service -Name 'sshd'
      Write-Host "Puerto SSH configurado a $Port y servicio reiniciado" -ForegroundColor Green
    } else {
      Write-Warning "Archivo de configuraciÃ³n SSH no encontrado en $sshConfigPath"
    }
    
  } catch {
    Write-Error "Error al configurar puerto SSH: $_"
    exit 1
  }
}

# Mostrar estado final
try {
  $finalService = Get-Service -Name 'sshd'
  Write-Host "`n=== Estado Final de SSH ===" -ForegroundColor Cyan
  Write-Host "Servicio sshd: $($finalService.Status)" -ForegroundColor Green
  Write-Host "Startup Type: $($finalService.StartType)" -ForegroundColor Green
  Write-Host "Puerto configurado: $Port" -ForegroundColor Green
  
  if ($AllowFirewall) {
    $firewallRule = Get-NetFirewallRule -DisplayName "OpenSSH Server"
    Write-Host "Regla firewall: $($firewallRule.Enabled)" -ForegroundColor Green
  }
  
  Write-Host "`nâœ… SSH Server habilitado correctamente" -ForegroundColor Green
  Write-Host "Puede conectarse usando: ssh <usuario>@<hostname> -p $Port" -ForegroundColor Cyan
  
} catch {
  Write-Warning "No se pudo verificar el estado final: $_"
}


