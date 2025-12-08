# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'
$features = @('WorkFolders-Client','XPS-Viewer','FaxServicesClientPackage','Printing-XPSServices-Features')
foreach ($f in $features) {
  try { Start-Process -FilePath dism.exe -ArgumentList "/Online","/Disable-Feature","/FeatureName:$f","/NoRestart" -Wait -WindowStyle Hidden } catch {}
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer
