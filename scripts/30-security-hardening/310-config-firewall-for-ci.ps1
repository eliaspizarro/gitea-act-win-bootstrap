# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

param(
  [switch]$AllowWinRM
)
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecuciÃ³n desatendida
if ($env:GITEA_BOOTSTRAP_FIREWALL_ALLOW_WINRM -and $env:GITEA_BOOTSTRAP_FIREWALL_ALLOW_WINRM -eq 'true') {
  $AllowWinRM = $true
}

$profiles = @('Domain','Private','Public')
foreach ($p in $profiles) { try { Set-NetFirewallProfile -Profile $p -Enabled True } catch {} }
if ($AllowWinRM) {
  $rule = Get-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -ErrorAction SilentlyContinue
  if ($null -ne $rule) { Enable-NetFirewallRule -InputObject $rule | Out-Null }
  else { New-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -DisplayName 'Windows Remote Management (HTTP-In)' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5985 | Out-Null }
}


Write-ScriptLog -Type 'End' -StartTime $scriptTimer

