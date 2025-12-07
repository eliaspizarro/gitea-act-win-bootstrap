# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'
$services = @(
  'Fax',
  'XblGameSave',
  'XblAuthManager',
  'XboxGipSvc',
  'WSearch'
)
foreach ($s in $services) {
  $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
  if ($null -ne $svc) {
    try { Set-Service -Name $s -StartupType Disabled } catch {}
    try { if ($svc.Status -ne 'Stopped') { Stop-Service -Name $s -Force } } catch {}
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
  }
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
}


