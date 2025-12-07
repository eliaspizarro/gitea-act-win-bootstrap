# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

param(
  [ValidateSet('Auto','Custom')][string]$Mode = 'Auto',
  [int]$InitialMB,
  [int]$MaximumMB
)
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecuciÃ³n desatendida
if ($env:GITEA_BOOTSTRAP_PAGEFILE_SIZE -and $env:GITEA_BOOTSTRAP_PAGEFILE_SIZE -ne '') {
  $Mode = 'Custom'
  $InitialMB = [int]$env:GITEA_BOOTSTRAP_PAGEFILE_SIZE
  $MaximumMB = [int]$env:GITEA_BOOTSTRAP_PAGEFILE_SIZE
}
$drive = if ($env:GITEA_BOOTSTRAP_PAGEFILE_DRIVE -and $env:GITEA_BOOTSTRAP_PAGEFILE_DRIVE -ne '') { $env:GITEA_BOOTSTRAP_PAGEFILE_DRIVE } else { 'C:' }

$cs = Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges
if ($Mode -eq 'Auto') {
  $cs.AutomaticManagedPagefile = $true
  [void]$cs.Put()
} else {
  if (-not $InitialMB -or -not $MaximumMB) { throw 'Debe especificar InitialMB y MaximumMB para modo Custom.' }
  $cs.AutomaticManagedPagefile = $false
  [void]$cs.Put()
  cmd /c "wmic pagefileset where name='$drive\\pagefile.sys' set InitialSize=$InitialMB,MaximumSize=$MaximumMB" | Out-Null
}


Write-ScriptLog -Type 'End' -StartTime $scriptTimer

