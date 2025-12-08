param(
  [string]$InstallDir = 'C:\Tools\gitea-act-runner',
  [string]$OutputPath,
  [string]$RunnerName,
  [string]$Labels,
  [int]$Concurrency,
  [string]$WorkDir
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

if (-not (Test-Path -LiteralPath $InstallDir)) { throw "InstallDir no existe: $InstallDir" }
$cfg = if ($OutputPath) { $OutputPath } else { Join-Path $InstallDir 'config.yaml' }
if (-not $RunnerName) { $RunnerName = $env:RUNNER_NAME }
if (-not $Labels) { $Labels = $env:RUNNER_LABELS }
if (-not $WorkDir) { $WorkDir = if ($env:RUNNER_WORKDIR) { $env:RUNNER_WORKDIR } else { Join-Path $InstallDir 'work' } }
if (-not $Concurrency) { $Concurrency = if ($env:RUNNER_CONCURRENCY) { [int]$env:RUNNER_CONCURRENCY } else { 1 } }

# Validar que existan las variables necesarias para generar un config.yaml completo
${serverUrl} = $env:GITEA_SERVER_URL
${serverToken} = $env:GITEA_RUNNER_TOKEN
if (-not ${serverUrl} -or -not ${serverToken}) {
  throw 'Faltan GITEA_SERVER_URL o GITEA_RUNNER_TOKEN; no se puede generar config.yaml completo para registro no interactivo.'
}
$labelsArr = @()
if ($Labels) { $labelsArr = $Labels.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ } }
$yaml = @()
$yaml += 'log:'
$yaml += '  level: info'
# A este punto ya sabemos que serverUrl y serverToken existen
$yaml += 'server:'
$yaml += "  url: ${serverUrl}"
$yaml += "  token: ${serverToken}"
$yaml += "  capacity: $Concurrency"
$yaml += '  env_file: ""'
if ($RunnerName) { $yaml += "  name: $RunnerName" }
if ($labelsArr.Count -gt 0) {
  $yaml += '  labels:'
  foreach ($l in $labelsArr) { $yaml += "    - $l" }
}
$yaml += "  workdir: $WorkDir"
$yamlText = ($yaml -join [Environment]::NewLine)
Set-Content -Path $cfg -Value $yamlText -Encoding UTF8
Write-Output $cfg


Write-ScriptLog -Type 'End' -StartTime $scriptTimer


