param(
  [string[]]$Paths = @('C:\CI','C:\Tools','C:\Logs','C:\Tools\gitea-act-runner'),
  [switch]$DisableRealtime
)
$ErrorActionPreference = 'Stop'
$hasDefender = Get-Command Add-MpPreference -ErrorAction SilentlyContinue
if ($null -eq $hasDefender) { return }
if ($Paths) {
  $current = (Get-MpPreference).ExclusionPath
  foreach ($p in $Paths) {
    if (-not ($current -contains $p)) { Add-MpPreference -ExclusionPath $p }
  }
}
if ($DisableRealtime) { Set-MpPreference -DisableRealtimeMonitoring $true }
