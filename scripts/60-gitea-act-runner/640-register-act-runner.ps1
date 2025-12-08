param(
  [string]$InstallDir = 'C:\Tools\gitea-act-runner',
  [string]$ConfigPath,
  [string]$RunnerName,
  [string]$Labels,
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

$exe = Join-Path $InstallDir 'act_runner.exe'
if (-not (Test-Path -LiteralPath $exe)) { throw 'act_runner.exe no encontrado. Ejecute 600-install-act-runner.ps1 antes.' }

$cfg = if ($ConfigPath) { $ConfigPath } else { Join-Path $InstallDir 'config.yaml' }
$runnerFile = Join-Path $InstallDir '.runner'

# Idempotencia: si ya está registrado, salir sin error
if (Test-Path -LiteralPath $runnerFile) { 
  Write-Host ".runner ya existe. Runner previamente registrado." -ForegroundColor Green
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
  exit 0 
}

# Resolver valores opcionales desde variables de entorno
if (-not $RunnerName) { $RunnerName = $env:RUNNER_NAME }
if (-not $Labels) { $Labels = $env:RUNNER_LABELS }
if (-not $WorkDir) { $WorkDir = if ($env:RUNNER_WORKDIR) { $env:RUNNER_WORKDIR } else { Join-Path $InstallDir 'work' } }

# Registrar el runner (preferencia: vía config.yaml)
$useConfig = Test-Path -LiteralPath $cfg

try {
  if ($useConfig) {
    & $exe register --config "$cfg" --no-interaction
  }
  else {
    $serverUrl = $env:GITEA_SERVER_URL
    $serverToken = $env:GITEA_RUNNER_TOKEN
    if (-not $serverUrl -or -not $serverToken) { throw 'Faltan GITEA_SERVER_URL o GITEA_RUNNER_TOKEN y no existe config.yaml' }
    $regArgs = @('register','--no-interaction','--instance', $serverUrl, '--token', $serverToken)
    if ($RunnerName) { $regArgs += @('--name', $RunnerName) }
    if ($Labels) { $regArgs += @('--labels', $Labels) }
    if ($WorkDir) { $regArgs += @('--workdir', $WorkDir) }
    & $exe @regArgs
  }

  if ($LASTEXITCODE -ne 0) { 
    throw "Registro falló con código: $LASTEXITCODE" 
  }
  
  if (-not (Test-Path -LiteralPath $runnerFile)) { 
    throw "Registro completado, pero no se encontró .runner en $InstallDir" 
  }

  Write-Host "Runner registrado correctamente." -ForegroundColor Green
}
catch {
  Write-ScriptLog -Type 'Error' -Message $_.Exception.Message
  throw
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
