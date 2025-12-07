# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'
$features = @('WorkFolders-Client','XPS-Viewer','FaxServicesClientPackage','Printing-XPSServices-Features')
foreach ($f in $features) {
  try { Start-Process -FilePath dism.exe -ArgumentList "/Online","/Disable-Feature","/FeatureName:$f","/NoRestart" -Wait -WindowStyle Hidden } catch {}
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
}


