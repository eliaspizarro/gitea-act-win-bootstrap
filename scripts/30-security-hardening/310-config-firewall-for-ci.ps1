param(
  [switch]$AllowWinRM
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
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



