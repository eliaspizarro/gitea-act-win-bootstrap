param(
  [string[]]$Paths = @('C:\CI','C:\Tools','C:\Logs','C:\Tools\gitea-act-runner'),
  [switch]$DisableRealtime
)
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
if ($env:GITEA_BOOTSTRAP_AV_EXCLUSIONS -and $env:GITEA_BOOTSTRAP_AV_EXCLUSIONS -ne '') {
  $Paths = $env:GITEA_BOOTSTRAP_AV_EXCLUSIONS.Split(';') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

$hasDefender = Get-Command Add-MpPreference -ErrorAction SilentlyContinue
if ($null -eq $hasDefender) { return }
if ($Paths) {
  $current = (Get-MpPreference).ExclusionPath
  foreach ($p in $Paths) {
    if (-not ($current -contains $p)) { Add-MpPreference -ExclusionPath $p }
  }
}
if ($DisableRealtime) { Set-MpPreference -DisableRealtimeMonitoring $true }
