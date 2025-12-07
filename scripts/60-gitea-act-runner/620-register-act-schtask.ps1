param(
  [string]$InstallDir = 'C:\Tools\gitea-act-runner',
  [string]$TaskName = 'GiteaActRunner',
  [ValidateSet('Startup','Logon')][string]$Trigger = 'Startup',
  [switch]$RunAsSystem,
  [string]$User,
  [SecureString]$Password
)
$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }

$startScript = Join-Path $InstallDir 'start-act-runner.ps1'
if (-not (Test-Path -LiteralPath $startScript)) { throw "No existe: $startScript (ejecute 610-create-start-script.ps1)" }

$triggerArg = if ($Trigger -eq 'Startup') { '/SC ONSTART' } else { '/SC ONLOGON' }
$action = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$startScript`""

# Si existe, eliminar para recrear limpio
$exists = (& schtasks /Query /TN $TaskName 2>$null) | Out-Null; $exists = ($LASTEXITCODE -eq 0)
if ($exists) { & schtasks /Delete /TN $TaskName /F | Out-Null }

if ($RunAsSystem) {
  & schtasks /Create /TN $TaskName /TR $action $triggerArg /RL HIGHEST /RU SYSTEM /F /DU INFINITE /K /V1 | Out-Null
}
else {
  if (-not $User -or -not $Password) { throw 'Debe especificar -User y -Password (o use -RunAsSystem).' }
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
  try {
    $plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    & schtasks /Create /TN $TaskName /TR $action $triggerArg /RL HIGHEST /RU $User /RP $plain /F /DU INFINITE /K /V1 | Out-Null
  }
  finally {
    if ($bstr -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
  }
}
