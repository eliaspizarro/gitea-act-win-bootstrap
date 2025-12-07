param(
  [ValidateSet('Auto','Custom')][string]$Mode = 'Auto',
  [int]$InitialMB,
  [int]$MaximumMB
)
$ErrorActionPreference = 'Stop'
$cs = Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges
if ($Mode -eq 'Auto') {
  $cs.AutomaticManagedPagefile = $true
  [void]$cs.Put()
} else {
  if (-not $InitialMB -or -not $MaximumMB) { throw 'Debe especificar InitialMB y MaximumMB para modo Custom.' }
  $cs.AutomaticManagedPagefile = $false
  [void]$cs.Put()
  cmd /c "wmic pagefileset where name='C:\\pagefile.sys' set InitialSize=$InitialMB,MaximumSize=$MaximumMB" | Out-Null
}
