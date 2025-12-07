param(
  [switch]$EnableWinRM
)
$ErrorActionPreference = 'Stop'
# Reglas de ejemplo para un runner CI. Outbound permitido por defecto en Windows.
# Inbound opcionales: WinRM HTTP si se requiere administración remota.
if ($EnableWinRM) {
  $rule = Get-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -ErrorAction SilentlyContinue
  if ($null -ne $rule) { Enable-NetFirewallRule -InputObject $rule | Out-Null }
  else { New-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -DisplayName 'Windows Remote Management (HTTP-In)' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5985 | Out-Null }
}
