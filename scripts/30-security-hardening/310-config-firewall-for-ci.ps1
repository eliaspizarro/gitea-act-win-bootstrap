param(
  [switch]$AllowWinRM
)
$ErrorActionPreference = 'Stop'
$profiles = @('Domain','Private','Public')
foreach ($p in $profiles) { try { Set-NetFirewallProfile -Profile $p -Enabled True } catch {} }
if ($AllowWinRM) {
  $rule = Get-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -ErrorAction SilentlyContinue
  if ($null -ne $rule) { Enable-NetFirewallRule -InputObject $rule | Out-Null }
  else { New-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -DisplayName 'Windows Remote Management (HTTP-In)' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5985 | Out-Null }
}
