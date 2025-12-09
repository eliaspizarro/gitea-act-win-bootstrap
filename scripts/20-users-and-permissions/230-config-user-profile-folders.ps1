param(
  [string]$User = 'gitea-runner',
  [string]$BaseDir = 'C:\CI',
  [string]$WorkDirName = 'work',
  [string]$CacheDirName = 'cache'
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$User = if ($env:GITEA_BOOTSTRAP_USER -and $env:GITEA_BOOTSTRAP_USER -ne '') { $env:GITEA_BOOTSTRAP_USER } else { $User }
$BaseDir = if ($env:GITEA_BOOTSTRAP_PROFILE_BASE_DIR -and $env:GITEA_BOOTSTRAP_PROFILE_BASE_DIR -ne '') { $env:GITEA_BOOTSTRAP_PROFILE_BASE_DIR } else { $BaseDir }
$WorkDirName = if ($env:GITEA_BOOTSTRAP_PROFILE_WORK_DIR -and $env:GITEA_BOOTSTRAP_PROFILE_WORK_DIR -ne '') { $env:GITEA_BOOTSTRAP_PROFILE_WORK_DIR } else { $WorkDirName }
$CacheDirName = if ($env:GITEA_BOOTSTRAP_PROFILE_CACHE_DIR -and $env:GITEA_BOOTSTRAP_PROFILE_CACHE_DIR -ne '') { $env:GITEA_BOOTSTRAP_PROFILE_CACHE_DIR } else { $CacheDirName }

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }

# Expandir variables de entorno en las rutas base
$BaseDir = [System.Environment]::ExpandEnvironmentVariables($BaseDir)
$acct = "$User"  # Solo el nombre de usuario para icacls
$workDir = Join-Path $BaseDir $WorkDirName
$cacheDir = Join-Path $BaseDir $CacheDirName
$dirs = @($BaseDir,$workDir,$cacheDir)

foreach ($d in $dirs) {
  if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

# Conceder Modify al usuario del runner y mantener Admins/SYSTEM
foreach ($d in @($workDir,$cacheDir)) {
  try {
    icacls "$d" /inheritance:e | Out-Null
    if ($LASTEXITCODE -ne 0) {
      Write-Warning "icacls inheritance retorno codigo de error $($LASTEXITCODE) para: $d"
      continue
    }
    
    icacls "$d" /grant:r "$($acct):(M)" /T | Out-Null
    if ($LASTEXITCODE -ne 0) {
      Write-Warning "icacls grant retorno codigo de error $($LASTEXITCODE) para: $d"
    } else {
      Write-Host "Permisos configurados para: $d"
    }
  } catch {
    Write-Warning "No se pudieron aplicar ACLs en ${d}: $($_.Exception.Message)"
  }
}

# Configurar permisos adicionales para herramientas de compilación e instalación de paquetes
# Priorizar variables de entorno para ejecución desatendida
$InstallDir = if ($env:GITEA_BOOTSTRAP_INSTALL_DIR) { 
  $env:GITEA_BOOTSTRAP_INSTALL_DIR
} else { 
  'C:\Tools'
}

$packageFolders = @(
  "$env:ProgramData\chocolatey",
  "$env:ProgramData\chocolatey\bin",
  "$env:ProgramData\chocolatey\lib",
  "$env:LOCALAPPDATA\NuGet",
  "$env:LOCALAPPDATA\NuGet\Cache",
  "$env:LOCALAPPDATA\NuGet\plugins",
  "$env:APPDATA\npm",
  "$env:APPDATA\npm-cache",
  $InstallDir,
  "C:\build"
)

foreach ($folder in $packageFolders) {
  # Validar que las variables de entorno existan antes de expandir la ruta
  $expandedFolder = [System.Environment]::ExpandEnvironmentVariables($folder)
  
  if ([string]::IsNullOrWhiteSpace($expandedFolder)) {
    Write-Warning "Ruta vacia despues de expandir variables de entorno: $folder"
    continue
  }
  
  if (-not (Test-Path -LiteralPath $expandedFolder)) {
    try {
      New-Item -Path $expandedFolder -ItemType Directory -Force | Out-Null
      Write-Host "Creada carpeta: $expandedFolder"
    } catch {
      Write-Warning "No se pudo crear carpeta: $expandedFolder - $($_.Exception.Message)"
      continue
    }
  }
  
  try {
    icacls "$expandedFolder" /grant:r "$($acct):(M)" /T | Out-Null
    if ($LASTEXITCODE -ne 0) {
      Write-Warning "icacls retorno codigo de error $LASTEXITCODE para: $expandedFolder"
    } else {
      Write-Host "Permisos configurados para: $expandedFolder"
    }
  } catch {
    Write-Warning "No se pudieron configurar permisos en: ${expandedFolder} - $($_.Exception.Message)"
  }
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer



