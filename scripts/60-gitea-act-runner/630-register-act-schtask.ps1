param(
  [string]$InstallDir = 'C:\Tools\gitea-act-runner',
  [string]$TaskName = 'GiteaActRunner',
  [ValidateSet('Startup','Logon')][string]$Trigger = 'Startup',
  [switch]$RunAsSystem,
  [string]$User,
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
if ($env:GITEA_BOOTSTRAP_USER -and $env:GITEA_BOOTSTRAP_USER -ne '') {
  $User = $env:GITEA_BOOTSTRAP_USER
}
if ($env:GITEA_BOOTSTRAP_RUNNER_PASSWORD -and $env:GITEA_BOOTSTRAP_RUNNER_PASSWORD -ne '' -and -not $Password) {
  $Password = ConvertTo-SecureString -String $env:GITEA_BOOTSTRAP_RUNNER_PASSWORD -AsPlainText -Force
}

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }

$startScript = Join-Path $InstallDir 'start-act-runner.ps1'
if (-not (Test-Path -LiteralPath $startScript)) { throw "No existe: $startScript (ejecute 620-create-start-script.ps1)" }

$triggerType = if ($Trigger -eq 'Startup') { 'ONSTART' } else { 'ONLOGON' }
$action = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File '$startScript'"

# Si existe, eliminar para recrear limpio (solo schtasks)
& C:\Windows\System32\schtasks.exe /Query /TN $TaskName 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
  & C:\Windows\System32\schtasks.exe /Delete /TN $TaskName /F | Out-Null
  Write-Host "Tarea existente '$TaskName' eliminada" -ForegroundColor Green
}

if ($RunAsSystem) {
  & C:\Windows\System32\schtasks.exe /Create /TN $TaskName /TR $action /SC $triggerType /RL HIGHEST /RU SYSTEM /F
  if ($LASTEXITCODE -ne 0) { 
    throw "Error al crear tarea programada (código: $LASTEXITCODE)"
  }
}
else {
  if (-not $User -or -not $Password) { throw 'Debe especificar -User y -Password (o use -RunAsSystem).' }
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
  try {
    $plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    & C:\Windows\System32\schtasks.exe /Create /TN $TaskName /TR $action /SC $triggerType /RL HIGHEST /RU $User /RP $plain /F
    if ($LASTEXITCODE -ne 0) { 
      throw "Error al crear tarea programada (código: $LASTEXITCODE)"
    }
  }
  finally {
    if ($bstr -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
  }
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
