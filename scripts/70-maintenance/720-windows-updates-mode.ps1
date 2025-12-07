# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

param(
  [ValidateSet('Automatic','Manual','Disable')][string]$Mode = 'Manual'
)
$ErrorActionPreference = 'Stop'
$services = @('wuauserv','UsoSvc','bits')
if ($Mode -eq 'Disable') {
  foreach ($s in $services) { try { Set-Service -Name $s -StartupType Disabled } catch {} }
  try {
    $wu = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
    if (-not (Test-Path $wu)) { New-Item -Path $wu -Force | Out-Null }
    New-ItemProperty -Path $wu -Name 'NoAutoUpdate' -PropertyType DWord -Value 1 -Force | Out-Null
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
  } catch {}
  return
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
}
foreach ($s in $services) { try { Set-Service -Name $s -StartupType Automatic } catch {} }
if ($Mode -eq 'Automatic') {
  try {
    $wu = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
    if (-not (Test-Path $wu)) { New-Item -Path $wu -Force | Out-Null }
    New-ItemProperty -Path $wu -Name 'NoAutoUpdate' -PropertyType DWord -Value 0 -Force | Out-Null
    New-ItemProperty -Path $wu -Name 'AUOptions' -PropertyType DWord -Value 4 -Force | Out-Null
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
  } catch {}
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
}


