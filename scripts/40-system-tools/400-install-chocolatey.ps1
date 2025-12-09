# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$cacheDir = if ($env:GITEA_BOOTSTRAP_CHOCO_CACHE_DIR -and $env:GITEA_BOOTSTRAP_CHOCO_CACHE_DIR -ne '') { $env:GITEA_BOOTSTRAP_CHOCO_CACHE_DIR } else { $null }

$chocoPath = "$env:PROGRAMDATA\chocolatey"
$chocoExe = "$chocoPath\bin\choco.exe"

# Detectar instalación corrupta y limpiar
if ((Test-Path $chocoPath) -and -not (Test-Path $chocoExe)) {
  Write-Host "Detectada instalacion corrupta de Chocolatey. Limpiando..." -ForegroundColor Yellow
  Remove-Item -Path $chocoPath -Recurse -Force
}

# Instalar Chocolatey si no está presente
if (-not (Test-Path $chocoExe)) {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Set-ExecutionPolicy Bypass -Scope Process -Force
  
  try {
    Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) 2>&1 | Out-Null
    
    if (-not (Test-Path $chocoExe)) {
      throw "La instalacion de Chocolatey fallo"
    }
  }
  catch {
    Write-Error "Error durante la instalacion de Chocolatey: $_"
    throw
  }
}

# Actualizar PATH para la sesión actual
$env:PATH = [Environment]::GetEnvironmentVariable('Path', 'Machine')
Write-Host "PATH actualizado para incluir Chocolatey en la sesion actual" -ForegroundColor Green

try { choco feature disable -n showDownloadProgress | Out-Null } catch {}
try { choco feature enable -n allowGlobalConfirmation | Out-Null } catch {}

# Configurar directorio caché si se especificó
if ($cacheDir -and (Get-Command choco -ErrorAction SilentlyContinue)) {
  if (-not (Test-Path -LiteralPath $cacheDir)) { 
    New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null 
  }
  try { choco config set cacheLocation $cacheDir | Out-Null } catch {}
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer



