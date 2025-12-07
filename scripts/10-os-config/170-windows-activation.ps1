param(
  [switch]$CheckOnly,
  [SecureString]$ProductKey
)
$ErrorActionPreference = 'Stop'
$slmgr = Join-Path $env:WINDIR 'System32\slmgr.vbs'
if ($CheckOnly) {
  cscript.exe //B //NoLogo $slmgr /dli | Out-Null
  return
}
if ($ProductKey) {
  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  if (-not $isAdmin) { throw 'Se requieren privilegios de administrador.' }
  $key = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($ProductKey))
  try {
    cscript.exe //B //NoLogo $slmgr /ipk $key | Out-Null
    cscript.exe //B //NoLogo $slmgr /ato | Out-Null
  } finally {
    if ($key) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($ProductKey)) | Out-Null }
  }
}
