# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$cacheDir = if ($env:GITEA_BOOTSTRAP_CHOCO_CACHE_DIR -and $env:GITEA_BOOTSTRAP_CHOCO_CACHE_DIR -ne '') { $env:GITEA_BOOTSTRAP_CHOCO_CACHE_DIR } else { $null }

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Set-ExecutionPolicy Bypass -Scope Process -Force
  Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
try { choco feature disable -n showDownloadProgress | Out-Null } catch {}
try { choco feature enable -n allowGlobalConfirmation | Out-Null } catch {}

# Actualizar PATH para la sesión actual si Chocolatey está instalado
if (Get-Command choco -ErrorAction SilentlyContinue) {
  $chocoPath = "$env:ProgramData\chocolatey\bin"
  if ($env:PATH -notlike "*$chocoPath*") {
    $env:PATH = "$env:PATH;$chocoPath"
    Write-Host "PATH actualizado para incluir Chocolatey en la sesión actual" -ForegroundColor Green
  }
}

# Configurar directorio caché si se especificó
if ($cacheDir -and (Get-Command choco -ErrorAction SilentlyContinue)) {
  if (-not (Test-Path -LiteralPath $cacheDir)) { 
    New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null 
  }
  try { choco config set cacheLocation $cacheDir | Out-Null } catch {}
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer



