# Script de validación para ejecución desatendida del bootstrap de Gitea Act Runner
# Verifica que todas las variables de entorno requeridas estén configuradas correctamente

param(
  [switch]$SkipOptional,
  [switch]$ListRequired,
  [switch]$AuditScripts
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'

# Definición de variables requeridas y opcionales
$requiredVars = @(
  @{ Name = 'GITEA_SERVER_URL'; Description = 'URL completa del servidor Gitea'; Required = $true },
  @{ Name = 'GITEA_RUNNER_TOKEN'; Description = 'Token del runner generado en Gitea'; Required = $true },
  @{ Name = 'RUNNER_NAME'; Description = 'Nombre único del runner'; Required = $true },
  @{ Name = 'GITEA_BOOTSTRAP_USER'; Description = 'Nombre de usuario local para el runner'; Required = $true },
  @{ Name = 'GITEA_BOOTSTRAP_RUNNER_PASSWORD'; Description = 'Contraseña del usuario del runner'; Required = $true }
)

$optionalVars = @(
  @{ Name = 'RUNNER_LABELS'; Description = 'Etiquetas del runner (default: windows,core,win2025)'; Required = $false },
  @{ Name = 'RUNNER_WORKDIR'; Description = 'Directorio de trabajo del runner'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_CHECK_ONLY'; Description = 'Solo verificar activación Windows (true/false)'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_PRODUCT_KEY'; Description = 'Clave de producto Windows'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_USER_GROUPS'; Description = 'Grupos para el usuario del runner (separados por ,)'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_TIMEZONE'; Description = 'Zona horaria (default: UTC)'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_SYSTEM_LOCALE'; Description = 'configuración regional del sistema'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_USER_LOCALE'; Description = 'configuración regional del usuario'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_INPUT_LOCALE'; Description = 'Lista de idiomas de entrada'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_TEMP_DIR'; Description = 'Directorio temporal personalizado'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_TMP_DIR'; Description = 'Directorio TMP personalizado'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_PAGEFILE_SIZE'; Description = 'Tamaño del pagefile en MB'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_PAGEFILE_DRIVE'; Description = 'Unidad del pagefile (default: C:)'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_INSTALL_DIR'; Description = 'Directorio base para instalación de herramientas'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_ACT_RUNNER_VERSION'; Description = 'Versión específica de act_runner a instalar'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_CHOCO_CACHE_DIR'; Description = 'Directorio caché de Chocolatey'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_PROFILE_BASE_DIR'; Description = 'Directorio base para perfiles de usuario'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_PROFILE_WORK_DIR'; Description = 'Nombre del subdirectorio de trabajo'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_PROFILE_CACHE_DIR'; Description = 'Nombre del subdirectorio de caché'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_LOG_DIR'; Description = 'Directorio base para logs de servicios y aplicaciones'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_DOTNET_CHANNEL'; Description = 'Canal de .NET SDK a instalar'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_WINSDK_VERSION'; Description = 'Versión específica del Windows SDK'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_AV_EXCLUSIONS'; Description = 'Variables de entorno para exclusiones AV (separadas por ,)'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_FIREWALL_ALLOW_WINRM'; Description = 'Permitir WinRM a través del firewall'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_CLEANUP_PATHS'; Description = 'Directorios para limpieza automática'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_CLEANUP_OLDER_THAN_DAYS'; Description = 'Días para limpieza automática'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_TEMP_CLEANUP_OLDER_THAN_DAYS'; Description = 'Días para limpieza temporales'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_EXPORT_OUTPUT_DIR'; Description = 'Directorio para exportar estado'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_EXPORT_INCLUDE_DIAGNOSTICS'; Description = 'Incluir Diagnóstico en exportación (true/false)'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_ENABLE_WINRM'; Description = 'Habilitar WinRM (true/false)'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_ENABLE_SSH'; Description = 'Habilitar servidor SSH (true/false)'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_SSH_PORT'; Description = 'Puerto SSH (default: 22)'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_SSH_FIREWALL'; Description = 'Permitir SSH en firewall (true/false)'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_AUTO_LOGON_ENABLE'; Description = 'Habilitar auto-logon (true/false)'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_AUTO_LOGON_USER'; Description = 'Usuario para auto-logon'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_AUTO_LOGON_PASSWORD'; Description = 'Contraseña para auto-logon'; Required = $false },
  @{ Name = 'GITEA_BOOTSTRAP_AUTO_LOGON_DOMAIN'; Description = 'Dominio para auto-logon'; Required = $false }
)

function Write-ValidationResult {
  param([bool]$Success, [string]$Message)
  $color = if ($Success) { 'Green' } else { 'Red' }
  Write-Host "[$(if ($Success) { 'OK' } else { 'ERROR' })] $Message" -ForegroundColor $color
}

function Test-EnvironmentVariable {
  param([string]$Name, [string]$Description, [bool]$Required)
  
  $value = [Environment]::GetEnvironmentVariable($Name, 'Machine')
  if (-not $value) { $value = [Environment]::GetEnvironmentVariable($Name, 'User') }
  if (-not $value) { $value = Get-Item -Path "Env:$Name" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Value }
  
  $isSet = $value -and $value -ne '' -and $value -notmatch '^\$\{.*\}$'
  
  if ($Required -and -not $isSet) {
    Write-ValidationResult $false "Variable requerida faltante: $Name - $Description"
    return $false
  }
  
  if ($isSet) {
    Write-ValidationResult $true "Variable configurada: $Name = $value"
  } elseif (-not $SkipOptional) {
    Write-Host "[INFO] Variable opcional no configurada: $Name - $Description" -ForegroundColor Yellow
  }
  
  return $true
}

function Test-Prerequisites {
  Write-Host "`n=== Verificando Prerrequisitos del Sistema ===" -ForegroundColor Cyan
  
  # Verificar PowerShell versión
  $psVersion = $PSVersionTable.PSVersion.Major
  Write-ValidationResult ($psVersion -ge 5) "PowerShell versión $psVersion (requerido: 5+)"
  
  # Verificar privilegios de administrador
  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  Write-ValidationResult $isAdmin "Privilegios de administrador"
  
  # Verificar conexión a internet (opcional)
  try {
    Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet | Out-Null
    Write-ValidationResult $true "conexión a internet disponible"
  } catch {
    Write-Host "[INFO] No se pudo verificar conexión a internet" -ForegroundColor Yellow
  }
  
  return $isAdmin
}

function Find-InteractiveScripts {
  param([string]$ScriptsPath)
  
  Write-Host "`n=== Auditando Scripts para Entradas Interactivas ===" -ForegroundColor Cyan
  
  $interactivePatterns = @(
    'Read-Host',
    'param\([^)]*\$[^)]*\)[^;]*$',  # parámetros sin defaults
    'Write-Host.*"Enter',
    'Write-Host.*"Input',
    'Write-Host.*"Password',
    'Write-Host.*"Username'
  )
  
  $scripts = Get-ChildItem -Path $ScriptsPath -Recurse -Filter '*.ps1'
  $interactiveScripts = @()
  $nonInteractiveScripts = @()
  
  foreach ($script in $scripts) {
    $content = Get-Content -Path $script.FullName -Raw
    $isInteractive = $false
    
    foreach ($pattern in $interactivePatterns) {
      if ($content -match $pattern) {
        # Excluir scripts que ya tienen manejo de variables de entorno
        if ($content -match 'env:GITEA_BOOTSTRAP_' -or $content -match 'env:RUNNER_') {
          continue
        }
        $isInteractive = $true
        break
      }
    }
    
    if ($isInteractive) {
      $interactiveScripts += $script.FullName.Replace($PSScriptRoot, '.')
    } else {
      $nonInteractiveScripts += $script.FullName.Replace($PSScriptRoot, '.')
    }
  }
  
  Write-Host "`nScripts que necesitan modificación (interactivos):" -ForegroundColor Yellow
  $interactiveScripts | ForEach-Object { Write-Host "  - $_" }
  
  Write-Host "`nScripts ya compatibles (no interactivos):" -ForegroundColor Green
  $nonInteractiveScripts | ForEach-Object { Write-Host "  - $_" }
  
  Write-Host "`nResumen:" -ForegroundColor Cyan
  Write-Host "  - Scripts totales: $($scripts.Count)"
  Write-Host "  - Scripts interactivos: $($interactiveScripts.Count)"
  Write-Host "  - Scripts no interactivos: $($nonInteractiveScripts.Count)"
  
  return @{
    Interactive = $interactiveScripts
    NonInteractive = $nonInteractiveScripts
  }
}

# ejecución principal
if ($ListRequired) {
  Write-Host "`n=== Variables de Entorno Requeridas ===" -ForegroundColor Cyan
  $requiredVars | ForEach-Object { 
    Write-Host "$($_.Name) - $($_.Description)" 
  }
  
  if (-not $SkipOptional) {
    Write-Host "`n=== Variables de Entorno Opcionales ===" -ForegroundColor Cyan
    $optionalVars | ForEach-Object { 
      Write-Host "$($_.Name) - $($_.Description)" 
    }
  }
  exit 0
}

if ($AuditScripts) {
  $scriptsPath = Split-Path $PSScriptRoot -Parent
  Write-Host "Auditando scripts en: $scriptsPath" -ForegroundColor Cyan
  Find-InteractiveScripts -ScriptsPath $scriptsPath
  exit 0
}

Write-Host "=== validación de Variables de Entorno para Bootstrap Desatendido ===" -ForegroundColor Cyan
Write-Host "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# Verificar prerrequisitos
$prereqsOk = Test-Prerequisites
if (-not $prereqsOk) {
  Write-Host "`n[ERROR] Se requieren privilegios de administrador para continuar" -ForegroundColor Red
  exit 1
}

# Validar variables requeridas
Write-Host "`n=== Validando Variables Requeridas ===" -ForegroundColor Cyan
$allRequiredOk = $true
foreach ($var in $requiredVars) {
  if (-not (Test-EnvironmentVariable -Name $var.Name -Description $var.Description -Required $var.Required)) {
    $allRequiredOk = $false
  }
}

# Validar variables opcionales
if (-not $SkipOptional) {
  Write-Host "`n=== Validando Variables Opcionales ===" -ForegroundColor Cyan
  foreach ($var in $optionalVars) {
    Test-EnvironmentVariable -Name $var.Name -Description $var.Description -Required $var.Required | Out-Null
  }
}

# Resumen final
Write-Host "`n=== Resumen de validación ===" -ForegroundColor Cyan
if ($allRequiredOk) {
  Write-ValidationResult $true "Todas las variables requeridas están configuradas"
  Write-Host "`n[SUCCESS] El entorno está listo para ejecución desatendida del bootstrap" -ForegroundColor Green
  exit 0
} else {
  Write-ValidationResult $false "Faltan variables requeridas"
  Write-Host "`n[ERROR] Configure las variables faltantes antes de ejecutar el bootstrap" -ForegroundColor Red
  Write-Host "Ejecute: .\validate-env.ps1 -ListRequired para ver todas las variables necesarias" -ForegroundColor Yellow
  exit 1
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer









