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
$logBase = if ($env:GITEA_BOOTSTRAP_LOG_DIR) { $env:GITEA_BOOTSTRAP_LOG_DIR } else { 'C:\Logs' }
$LogDir = Join-Path $logBase 'ActRunner'

if (-not (Test-Path -LiteralPath $InstallDir)) { throw "InstallDir no existe: $InstallDir" }
if (-not (Test-Path -LiteralPath $LogDir)) { 
  Write-Host "Creando directorio de logs: $LogDir" -ForegroundColor Yellow
  New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Verificación explícita de que la carpeta existe
if (-not (Test-Path -LiteralPath $LogDir -PathType Container)) {
  throw "No se pudo crear el directorio de logs: $LogDir"
}
Write-Host "Directorio de logs verificado: $LogDir" -ForegroundColor Green

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
$templatePath = Join-Path $PSScriptRoot '..\..\templates\60-gitea-act-runner\start-act-runner.ps1.template'

# Validar que el template exista
if (-not (Test-Path -LiteralPath $templatePath)) {
  throw "Template no encontrado: $templatePath"
}

# Leer template y reemplazar placeholders
$script = Get-Content -Path $templatePath -Raw
$script = $script -Replace '__INSTALL_DIR__', $InstallDir
$script = $script -Replace '__LOG_DIR__', 'C:\Logs\ActRunner'
Set-Content -Path $startScript -Value $script -Encoding UTF8 -Force
Write-Output $startScript

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
