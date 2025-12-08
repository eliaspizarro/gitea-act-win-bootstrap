param(
  [string]$InstallDir = 'C:\Tools\gitea-act-runner',
  [string]$Version,
  [string]$AssetUrl
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$InstallDir = if ($env:GITEA_BOOTSTRAP_INSTALL_DIR) { 
  Join-Path $env:GITEA_BOOTSTRAP_INSTALL_DIR 'gitea-act-runner' 
} else { 
  $InstallDir 
}

$Version = if ($env:GITEA_BOOTSTRAP_ACT_RUNNER_VERSION) { 
  $env:GITEA_BOOTSTRAP_ACT_RUNNER_VERSION 
} else { 
  $Version 
}

if (-not (Test-Path -LiteralPath $InstallDir)) { New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null }
$exe = Join-Path $InstallDir 'act_runner.exe'
if (Test-Path -LiteralPath $exe) { return }
if (-not $AssetUrl -and -not $Version) { throw 'Debe proporcionar -AssetUrl o -Version (ej: 0.2.10).' }
if (-not $AssetUrl) {
  $file = "act_runner-${Version}-windows-amd64.exe"
  $AssetUrl = "https://dl.gitea.com/act_runner/${Version}/$file"
} else {
  # Si se proporciona AssetUrl directamente, extraer nombre del archivo de la URL
  $file = Split-Path -Leaf $AssetUrl
  if (-not $file -or $file -eq '') {
    throw 'No se pudo extraer el nombre del archivo de AssetUrl.'
  }
}
$tmp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ([Guid]::NewGuid().ToString())) -Force
$downloadedFile = Join-Path $tmp.FullName $file
Invoke-WebRequest -UseBasicParsing -Uri $AssetUrl -OutFile $downloadedFile
if (-not (Test-Path -LiteralPath $downloadedFile)) { throw 'No se pudo descargar act_runner.exe.' }
Move-Item -Force -Path $downloadedFile -Destination $exe
if (-not (Test-Path -LiteralPath $exe)) { throw 'act_runner.exe no se encontró tras la extracción.' }
$machinePath = [Environment]::GetEnvironmentVariable('Path','Machine')
if (-not ($machinePath.Split(';') -contains $InstallDir)) {
  [Environment]::SetEnvironmentVariable('Path', ($machinePath.TrimEnd(';') + ';' + $InstallDir), 'Machine')
}


Write-ScriptLog -Type 'End' -StartTime $scriptTimer




