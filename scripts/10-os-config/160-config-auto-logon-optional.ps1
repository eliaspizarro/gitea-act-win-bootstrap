param(
  [switch]$Enable,
  [string]$User,
  [SecureString]$Password,
  [string]$Domain = ''
)
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
if ($env:GITEA_BOOTSTRAP_AUTO_LOGON_ENABLE -and $env:GITEA_BOOTSTRAP_AUTO_LOGON_ENABLE -eq 'true') {
  $Enable = $true
}
if ($Enable) {
  if ($env:GITEA_BOOTSTRAP_AUTO_LOGON_USER -and $env:GITEA_BOOTSTRAP_AUTO_LOGON_USER -ne '') {
    $User = $env:GITEA_BOOTSTRAP_AUTO_LOGON_USER
  }
  if ($env:GITEA_BOOTSTRAP_AUTO_LOGON_PASSWORD -and $env:GITEA_BOOTSTRAP_AUTO_LOGON_PASSWORD -ne '' -and -not $Password) {
    $Password = ConvertTo-SecureString -String $env:GITEA_BOOTSTRAP_AUTO_LOGON_PASSWORD -AsPlainText -Force
  }
  if ($env:GITEA_BOOTSTRAP_AUTO_LOGON_DOMAIN -and $env:GITEA_BOOTSTRAP_AUTO_LOGON_DOMAIN -ne '') {
    $Domain = $env:GITEA_BOOTSTRAP_AUTO_LOGON_DOMAIN
  }
}

if (-not $Enable) { return }
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }
if (-not $User -or -not $Password) { throw 'Debe especificar User y Password.' }
$plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
try {
  $key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
  Set-ItemProperty -Path $key -Name 'AutoAdminLogon' -Type String -Value '1' -Force
  Set-ItemProperty -Path $key -Name 'DefaultUserName' -Type String -Value $User -Force
  if ($Domain) { Set-ItemProperty -Path $key -Name 'DefaultDomainName' -Type String -Value $Domain -Force }
  Set-ItemProperty -Path $key -Name 'DefaultPassword' -Type String -Value $plain -Force
} finally {
  if ($plain) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)) | Out-Null }
}
