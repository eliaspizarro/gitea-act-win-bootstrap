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

# Configurar directorio caché si se especificó
if ($cacheDir -and (Get-Command choco -ErrorAction SilentlyContinue)) {
  if (-not (Test-Path -LiteralPath $cacheDir)) { 
    New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null 
  }
  try { choco config set cacheLocation $cacheDir | Out-Null } catch {}
}
