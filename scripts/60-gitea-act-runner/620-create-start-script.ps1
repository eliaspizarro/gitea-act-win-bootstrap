param(
  [string]$InstallDir = 'C:\Tools\gitea-act-runner',
  [string]$LogDir = 'C:\Logs\ActRunner'
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
$logBase = if ($env:GITEA_BOOTSTRAP_LOG_DIR) { $env:GITEA_BOOTSTRAP_LOG_DIR } else { $LogDir }
$LogDir = Join-Path $logBase 'ActRunner'

if (-not (Test-Path -LiteralPath $InstallDir)) { throw "InstallDir no existe: $InstallDir" }
if (-not (Test-Path -LiteralPath $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

# Dar permisos al usuario del runner sobre el directorio de logs
$runnerUser = if ($env:GITEA_BOOTSTRAP_USER) { $env:GITEA_BOOTSTRAP_USER } else { 'gitea-runner' }

# Validar que el usuario del runner exista
try {
  $null = Get-LocalUser -Name $runnerUser -ErrorAction Stop
}
catch {
  throw "El usuario '$runnerUser' no existe. Ejecute primero los scripts del grupo 20 (usuarios y permisos)."
}

try {
  & icacls $LogDir /grant ("{0}:(OI)(CI)F" -f $runnerUser) | Out-Null
  Write-Host "Permisos concedidos a $runnerUser sobre $LogDir" -ForegroundColor Green
}
catch {
  $errorMsg = $_.Exception.Message
  Write-Warning ('No se pudieron establecer permisos en {0}: {1}' -f $LogDir, $errorMsg)
}
$exe = Join-Path $InstallDir 'act_runner.exe'
if (-not (Test-Path -LiteralPath $exe)) { throw 'act_runner.exe no encontrado. Ejecute 600-install-act-runner.ps1 antes.' }
$startScript = Join-Path $InstallDir 'start-act-runner.ps1'
$script = @"
# Script de inicio para Gitea Act Runner
# Arranca act_runner como daemon con auto-reinicio y logging

param(
  [string]`$InstallDir = '$InstallDir',
  [string]`$LogDir = '$LogDir'
)

`$ErrorActionPreference = 'Stop'

# Función de logging
function Write-Log {
  param([string]`$Message)
  `$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
  `$logFile = Join-Path `$LogDir 'runner-startup.log'
  Add-Content -Path `$logFile -Value "`$timestamp - `$Message"
}

# Cambiar al directorio del runner
Set-Location `$InstallDir
Write-Log "Directorio de trabajo: `$InstallDir"
`$exe = Join-Path `$InstallDir 'act_runner.exe'

# Bucle infinito: si el runner se cae, se vuelve a levantar con backoff exponencial
`$restartCount = 0
`$maxBackoffSeconds = 300  # Máximo 5 minutos de espera
`$shouldExit = `$false

# Manejo graceful shutdown
trap {
  Write-Log "Recibida señal de terminación. Deteniendo graceful shutdown..."
  `$shouldExit = `$true
}

while (`$true) {
  if (`$shouldExit) {
    Write-Log "Saliendo graceful shutdown"
    break
  }
  
  try {
    Write-Log "Iniciando act_runner daemon (intento #`$(`$restartCount + 1))"
    Write-Log "Ejecutable: `$exe"
    `$outLog = Join-Path `$LogDir 'act-runner.stdout.log'
    `$errLog = Join-Path `$LogDir 'act-runner.stderr.log'
    Write-Log "Stdout log: `$outLog"
    Write-Log "Stderr log: `$errLog"
    `$process = Start-Process -FilePath "`$exe" -ArgumentList @('daemon') -WorkingDirectory "`$InstallDir" -WindowStyle Hidden -RedirectStandardOutput "`$outLog" -RedirectStandardError "`$errLog" -PassThru -Wait
    
    if (`$process.ExitCode -ne 0) {
      Write-Log "act_runner terminó con código de salida: `$(`$process.ExitCode)"
      Write-Log "Revisar logs: `$outLog y `$errLog"
    } else {
      Write-Log "act_runner terminó normalmente"
      `$restartCount = 0  # Resetear contador si terminó normalmente
    }
  }
  catch {
    Write-Log ("ERROR al iniciar act_runner: {0}" -f `$_.Exception.Message)
    if (`$_.ScriptStackTrace) { Write-Log ("TRACE: {0}" -f `$_.ScriptStackTrace) }
    if (`$_.InvocationInfo -and `$_.InvocationInfo.PositionMessage) { Write-Log ("AT: {0}" -f `$_.InvocationInfo.PositionMessage) }
  }
  
  if (`$shouldExit) {
    break
  }
  
  `$restartCount++
  # Backoff exponencial: 5s, 10s, 20s, 40s, 80s, 160s, 300s (máximo)
  `$waitSeconds = [Math]::Min(5 * [Math]::Pow(2, (`$restartCount - 1)), `$maxBackoffSeconds)
  Write-Log "Esperando `$waitSeconds segundos antes de reiniciar..."
  Start-Sleep -Seconds `$waitSeconds
}
"@
Set-Content -Path $startScript -Value $script -Encoding UTF8
Write-Output $startScript

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
