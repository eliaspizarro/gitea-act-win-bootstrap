$ErrorActionPreference = 'Stop'
$pol = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer'
if (-not (Test-Path $pol)) { New-Item -Path $pol -Force | Out-Null }
New-ItemProperty -Path $pol -Name 'Logging' -PropertyType String -Value 'voicewarmupx' -Force | Out-Null
$def = 'HKLM:\SOFTWARE\Microsoft\Windows\Installer'
if (-not (Test-Path $def)) { New-Item -Path $def -Force | Out-Null }
New-ItemProperty -Path $def -Name 'Logging' -PropertyType String -Value 'voicewarmupx' -Force | Out-Null
