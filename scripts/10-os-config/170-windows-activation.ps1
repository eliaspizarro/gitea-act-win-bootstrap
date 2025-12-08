param(
  [switch]$CheckOnly,
  [SecureString]$ProductKey
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$CheckOnly = if ($env:GITEA_BOOTSTRAP_CHECK_ONLY -eq 'true') { $true } else { $CheckOnly }
if ($env:GITEA_BOOTSTRAP_PRODUCT_KEY -and -not $ProductKey) {
  $ProductKey = ConvertTo-SecureString $env:GITEA_BOOTSTRAP_PRODUCT_KEY -AsPlainText -Force
}

$slmgr = Join-Path $env:WINDIR 'System32\slmgr.vbs'

# Script compatible con claves KMS, MAK y Retail para Windows Server 2025 Core
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

Write-ScriptLog -Type 'End' -StartTime $scriptTimer




