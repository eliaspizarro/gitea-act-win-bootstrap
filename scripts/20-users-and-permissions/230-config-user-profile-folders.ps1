param(
  [string]$User = 'gitea-runner',
  [string]$BaseDir = 'C:\CI',
  [string]$WorkDirName = 'work',
  [string]$CacheDirName = 'cache'
)
$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }

$acct = "$env:COMPUTERNAME\$User"
$workDir = Join-Path $BaseDir $WorkDirName
$cacheDir = Join-Path $BaseDir $CacheDirName
$dirs = @($BaseDir,$workDir,$cacheDir)

foreach ($d in $dirs) {
  if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

# Conceder Modify al usuario del runner y mantener Admins/ SYSTEM
foreach ($d in @($workDir,$cacheDir)) {
  try {
    icacls $d /inheritance:e | Out-Null
    icacls $d /grant:r "${acct}:(M)" /T | Out-Null
  } catch {
    Write-Warning "No se pudieron aplicar ACLs en $d: $($_.Exception.Message)"
  }
}

# Configurar permisos adicionales para herramientas de compilación e instalación de paquetes
$packageFolders = @(
  "$env:ProgramData\chocolatey",
  "$env:ProgramData\chocolatey\bin",
  "$env:ProgramData\chocolatey\lib",
  "$env:LOCALAPPDATA\NuGet",
  "$env:LOCALAPPDATA\NuGet\Cache",
  "$env:LOCALAPPDATA\NuGet\plugins",
  "$env:APPDATA\npm",
  "$env:APPDATA\npm-cache",
  "C:\tools",
  "C:\build"
)

foreach ($folder in $packageFolders) {
  if (-not (Test-Path $folder)) {
    try {
      New-Item -Path $folder -ItemType Directory -Force | Out-Null
      Write-Host "Creada carpeta: $folder"
    } catch {
      Write-Warning "No se pudo crear carpeta: $folder - $($_.Exception.Message)"
      continue
    }
  }
  
  try {
    icacls $folder /grant:r "${acct}:(M)" /T | Out-Null
    Write-Host "Permisos configurados para: $folder"
  } catch {
    Write-Warning "No se pudieron configurar permisos en: $folder - $($_.Exception.Message)"
  }
}
