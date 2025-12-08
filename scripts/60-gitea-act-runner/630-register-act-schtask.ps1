param(
  [string]$InstallDir = 'C:\Tools\gitea-act-runner',
  [string]$TaskName = 'GiteaActRunner',
  [SecureString]$Password
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$InstallDir = if ($env:GITEA_BOOTSTRAP_INSTALL_DIR -and $env:GITEA_BOOTSTRAP_INSTALL_DIR -ne '') { 
  Join-Path $env:GITEA_BOOTSTRAP_INSTALL_DIR 'gitea-act-runner' 
} else { 
  $InstallDir 
}
if ($env:GITEA_BOOTSTRAP_RUNNER_PASSWORD -and $env:GITEA_BOOTSTRAP_RUNNER_PASSWORD -ne '' -and -not $Password) {
  $Password = ConvertTo-SecureString -String $env:GITEA_BOOTSTRAP_RUNNER_PASSWORD -AsPlainText -Force
}

# Construir LogDir consistentemente con script 620
$logBase = if ($env:GITEA_BOOTSTRAP_LOG_DIR) { $env:GITEA_BOOTSTRAP_LOG_DIR } else { 'C:\Logs' }
$LogDir = Join-Path $logBase 'ActRunner'

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }

$startScript = Join-Path $InstallDir 'start-act-runner.ps1'
if (-not (Test-Path -LiteralPath $startScript)) { throw "No existe: $startScript (ejecute 620-create-start-script.ps1)" }

# Determinar usuario para ejecutar la tarea
$taskUser = if ($env:GITEA_BOOTSTRAP_USER -and $env:GITEA_BOOTSTRAP_USER -ne '') {
  $env:GITEA_BOOTSTRAP_USER
} else {
  $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name
  $currentUser
}

Write-Host "Usuario seleccionado para la tarea programada: $taskUser" -ForegroundColor Green

# Validar que el usuario exista
try {
  $null = Get-LocalUser -Name ($taskUser.Split('\')[-1]) -ErrorAction Stop
}
catch {
  throw "El usuario '$taskUser' no existe en el sistema."
}

# Validar permisos de escritura en directorios críticos
$requiredDirs = @($InstallDir, $LogDir)
foreach ($dir in $requiredDirs) {
  if (-not (Test-Path -Path $dir -PathType Container)) {
    throw "El directorio requerido no existe: $dir"
  }
  
  # Verificar permisos de escritura
  $testFile = Join-Path $dir "test_access_$(Get-Random).tmp"
  try {
    "test" | Out-File -FilePath $testFile -ErrorAction Stop
    Remove-Item $testFile -Force -ErrorAction SilentlyContinue
  }
  catch {
    throw "El usuario '$taskUser' no tiene permisos de escritura en: $dir"
  }
}

Write-Host "Permisos validados para el usuario '$taskUser'" -ForegroundColor Green

# Construir acción para PowerShell Scheduled Task
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$startScript`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -ExecutionTimeLimit (New-TimeSpan -Days 3650)

# Si existe, eliminar para recrear limpio
try {
  Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop | Unregister-ScheduledTask -Confirm:$false
  Write-Host "Tarea existente '$TaskName' eliminada" -ForegroundColor Green
}
catch {
  # No existe, continuar
}

# Crear tarea con el usuario determinado
if (-not $Password) {
  throw "Debe proporcionar la contraseña del usuario '$taskUser' mediante el parametro -Password o la variable de entorno GITEA_BOOTSTRAP_RUNNER_PASSWORD."
}

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -User $taskUser -Password $Password -RunLevel Highest | Out-Null

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
