# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

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
  }
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
