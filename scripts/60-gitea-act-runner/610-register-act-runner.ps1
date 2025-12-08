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

$runnerFile = Join-Path $InstallDir '.runner'

# Validar variables de entorno necesarias
$serverUrl = $env:GITEA_SERVER_URL
$serverToken = $env:GITEA_RUNNER_TOKEN
if (-not $serverUrl -or -not $serverToken) {
  throw 'Faltan GITEA_SERVER_URL o GITEA_RUNNER_TOKEN; no se puede registrar el runner.'
}

# Idempotencia: si ya está registrado, salir sin error
if (Test-Path -LiteralPath $runnerFile) { 
  Write-Host ".runner ya existe. Runner previamente registrado." -ForegroundColor Green
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
  exit 0 
}

# Guardar directorio actual y cambiar al del runner
Push-Location
Set-Location $InstallDir

# Resolver valores opcionales desde variables de entorno
if (-not $RunnerName) { $RunnerName = $env:RUNNER_NAME }
if (-not $Labels) { $Labels = $env:RUNNER_LABELS }
if (-not $WorkDir) { $WorkDir = if ($env:RUNNER_WORKDIR) { $env:RUNNER_WORKDIR } else { Join-Path $InstallDir 'work' } }

try {
  $regArgs = @('register','--no-interactive','--instance', $serverUrl, '--token', $serverToken)
  if ($RunnerName) { $regArgs += @('--name', $RunnerName) }
  if ($Labels) { $regArgs += @('--labels', $Labels) }
  & $exe @regArgs

  if ($LASTEXITCODE -ne 0) { 
    throw "Registro falló con código: $LASTEXITCODE" 
  }
  
  if (-not (Test-Path -LiteralPath $runnerFile)) { 
    throw "Registro completado, pero no se encontró .runner en $InstallDir" 
  }

  # Dar permisos al usuario del runner sobre el archivo .runner
  $runnerUser = if ($env:GITEA_BOOTSTRAP_USER) { $env:GITEA_BOOTSTRAP_USER } else { 'gitea-runner' }
  try {
    & icacls $runnerFile /grant "${runnerUser}:(M)" | Out-Null
    Write-Host "Permisos concedidos a $runnerUser sobre .runner" -ForegroundColor Green
  }
  catch {
    Write-Warning "No se pudieron establecer permisos en .runner: $($_.Exception.Message)"
  }

  Write-Host "Runner registrado correctamente." -ForegroundColor Green
}
catch {
  Write-ScriptLog -Type 'Error' -Message $_.Exception.Message
  throw
}
finally {
  Pop-Location
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
