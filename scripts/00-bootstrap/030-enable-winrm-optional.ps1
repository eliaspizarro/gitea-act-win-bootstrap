param(
  [switch]$Enable
)

$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
if ($env:GITEA_BOOTSTRAP_ENABLE_WINRM -and $env:GITEA_BOOTSTRAP_ENABLE_WINRM -eq 'true') {
  $Enable = $true
}

try {
  if (-not $Enable) { exit 0 }

  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }

  Enable-PSRemoting -SkipNetworkProfileCheck -Force

  $svc = Get-Service -Name WinRM -ErrorAction Stop
  if ($svc.StartType -ne 'Automatic') { Set-Service -Name WinRM -StartupType Automatic }
  if ($svc.Status -ne 'Running') { Start-Service -Name WinRM }

  $rule = Get-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -ErrorAction SilentlyContinue
  if ($null -ne $rule) {
    Enable-NetFirewallRule -InputObject $rule | Out-Null
  }
  else {
    New-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -DisplayName 'Windows Remote Management (HTTP-In)' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5985 | Out-Null
  }

  exit 0
}
catch {
  Write-Error $_
  exit 1
}

