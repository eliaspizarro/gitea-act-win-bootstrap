$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }

Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Type DWord -Value 1 -Force

$git = Get-Command git -ErrorAction SilentlyContinue
if ($null -ne $git) {
  try { & git config --system core.longpaths true 2>$null } catch {}
  try { & git config --global core.longpaths true 2>$null } catch {}
}
