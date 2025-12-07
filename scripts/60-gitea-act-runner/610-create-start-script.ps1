param(
  [string]$InstallDir = 'C:\Tools\gitea-act-runner',
  [string]$ConfigPath,
  [string]$LogDir = 'C:\Logs\ActRunner'
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $InstallDir)) { throw "InstallDir no existe: $InstallDir" }
if (-not (Test-Path -LiteralPath $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$exe = Join-Path $InstallDir 'act_runner.exe'
if (-not (Test-Path -LiteralPath $exe)) { throw 'act_runner.exe no encontrado. Ejecute 600-install-act-runner.ps1 antes.' }
$cfg = if ($ConfigPath) { $ConfigPath } else { Join-Path $InstallDir 'config.yaml' }
$startScript = Join-Path $InstallDir 'start-act-runner.ps1'
$script = @"
# Script de inicio para Gitea Act Runner
# Arranca act_runner como daemon con auto-reinicio y logging

param(
  [string]`$InstallDir = '$InstallDir',
  [string]`$ConfigPath = '$cfg',
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

# 1. Ajustar PATH para incluir NodeJS si existe
`$nodePath = 'C:\Program Files\nodejs'
if (Test-Path -LiteralPath `$nodePath) {
  `$env:PATH = "`$nodePath;" + `$env:PATH
  Write-Log "NodeJS agregado al PATH: `$nodePath"
}

# 2. Cambiar al directorio del runner
Set-Location `$InstallDir
Write-Log "Directorio de trabajo: `$InstallDir"

# 3. Bucle infinito: si el runner se cae, se vuelve a levantar con backoff exponencial
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
    `$process = Start-Process -FilePath "`$exe" -ArgumentList @('daemon','--config',"`$ConfigPath") -WorkingDirectory "`$InstallDir" -WindowStyle Hidden -PassThru -Wait
    
    if (`$process.ExitCode -ne 0) {
      Write-Log "act_runner terminó con código de salida: `$(`$process.ExitCode)"
    } else {
      Write-Log "act_runner terminó normalmente"
      `$restartCount = 0  # Resetear contador si terminó normalmente
    }
  }
  catch {
    Write-Log "ERROR al iniciar act_runner: `$_"
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
