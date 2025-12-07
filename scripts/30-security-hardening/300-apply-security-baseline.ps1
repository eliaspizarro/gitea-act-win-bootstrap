$ErrorActionPreference = 'Stop'
# .NET fuerte cifrado
$paths = @(
  'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319',
  'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319'
)
foreach ($p in $paths) {
  if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
  New-ItemProperty -Path $p -Name 'SchUseStrongCrypto' -PropertyType DWord -Value 1 -Force | Out-Null
}
# WinHTTP TLS 1.2/1.3 por defecto si está disponible
$winhttp = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp'
if (-not (Test-Path $winhttp)) { New-Item -Path $winhttp -Force | Out-Null }
# 0x0800 TLS1.2, 0x2000 TLS1.3
$new = 0x0800 -bor 0x2000
New-ItemProperty -Path $winhttp -Name 'DefaultSecureProtocols' -PropertyType DWord -Value $new -Force | Out-Null
