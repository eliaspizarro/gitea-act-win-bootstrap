param(
  [string]$ActRunnerInstallDir = 'C:\Tools\gitea-act-runner',
  [string]$ActRunnerVersion,
  [string]$DownloadAssetUrl
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$ActRunnerInstallDir = if ($env:GITEA_BOOTSTRAP_INSTALL_DIR) { 
  Join-Path $env:GITEA_BOOTSTRAP_INSTALL_DIR 'gitea-act-runner' 
} else { 
  $ActRunnerInstallDir 
}

$ActRunnerVersion = if ($env:GITEA_BOOTSTRAP_ACT_RUNNER_VERSION) { 
  $env:GITEA_BOOTSTRAP_ACT_RUNNER_VERSION 
} else { 
  $ActRunnerVersion 
}

if (-not (Test-Path -LiteralPath $ActRunnerInstallDir)) { New-Item -ItemType Directory -Path $ActRunnerInstallDir -Force | Out-Null }

# Dar permisos al usuario del runner sobre el directorio de instalación
$runnerUser = if ($env:GITEA_BOOTSTRAP_USER) { $env:GITEA_BOOTSTRAP_USER } else { 'gitea-runner' }

# Validar que el usuario del runner exista
try {
  $null = Get-LocalUser -Name $runnerUser -ErrorAction Stop
}
catch {
  throw "El usuario '$runnerUser' no existe. Ejecute primero los scripts del grupo 20 (usuarios y permisos)."
}

function Grant-RunnerPermissions {
  param(
    [string]$DirectoryPath,
    [string]$UserName
  )
  
  try {
    & icacls $DirectoryPath /grant ("{0}:(OI)(CI)F" -f $UserName) | Out-Null
    Write-Host "Permisos concedidos a $UserName sobre $DirectoryPath" -ForegroundColor Green
  }
  catch {
    Write-Warning ("No se pudieron establecer permisos en {0}: Error de permisos" -f $DirectoryPath)
  }
}

Grant-RunnerPermissions -DirectoryPath $ActRunnerInstallDir -UserName $runnerUser
$actRunnerExePath = Join-Path $ActRunnerInstallDir 'act_runner.exe'
if (Test-Path -LiteralPath $actRunnerExePath) { 
  Write-Host 'Gitea Act Runner ya está instalado. Omitiendo instalación.' -ForegroundColor Yellow
  return 
}
if (-not $DownloadAssetUrl -and -not $ActRunnerVersion) { throw 'Debe proporcionar -DownloadAssetUrl o -ActRunnerVersion (ej: 0.2.10).' }
if (-not $DownloadAssetUrl) {
  $downloadFileName = "act_runner-${ActRunnerVersion}-windows-amd64.exe"
  $DownloadAssetUrl = "https://dl.gitea.com/act_runner/${ActRunnerVersion}/$downloadFileName"
} else {
  # Si se proporciona DownloadAssetUrl directamente, extraer nombre del archivo de la URL
  $downloadFileName = Split-Path -Leaf $DownloadAssetUrl
  if (-not $downloadFileName -or $downloadFileName -eq '') {
    throw 'No se pudo extraer el nombre del archivo de DownloadAssetUrl.'
  }
}
$tempDirectory = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ([Guid]::NewGuid().ToString())) -Force
$downloadedFilePath = Join-Path $tempDirectory.FullName $downloadFileName

try {
  Invoke-WebRequest -UseBasicParsing -Uri $DownloadAssetUrl -OutFile $downloadedFilePath
  if (-not (Test-Path -LiteralPath $downloadedFilePath)) { throw 'No se pudo descargar act_runner.exe.' }
  
  Move-Item -Force -Path $downloadedFilePath -Destination $actRunnerExePath
  if (-not (Test-Path -LiteralPath $actRunnerExePath)) { throw 'act_runner.exe no se encontró tras la extracción.' }
}
finally {
  if (Test-Path -LiteralPath $tempDirectory.FullName) {
    Remove-Item $tempDirectory.FullName -Recurse -Force -ErrorAction SilentlyContinue
  }
}
$machinePath = [Environment]::GetEnvironmentVariable('Path','Machine')
if (-not ($machinePath.Split(';') -contains $ActRunnerInstallDir)) {
  [Environment]::SetEnvironmentVariable('Path', ($machinePath.TrimEnd(';') + ';' + $ActRunnerInstallDir), 'Machine')
  Write-Host 'Directorio de Gitea Act Runner agregado al PATH del sistema.' -ForegroundColor Green
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
