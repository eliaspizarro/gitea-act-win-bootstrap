$ErrorActionPreference = 'Stop'
$features = @('WorkFolders-Client','XPS-Viewer','FaxServicesClientPackage','Printing-XPSServices-Features')
foreach ($f in $features) {
  try { Start-Process -FilePath dism.exe -ArgumentList "/Online","/Disable-Feature","/FeatureName:$f","/NoRestart" -Wait -WindowStyle Hidden } catch {}
}
