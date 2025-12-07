# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'
$paths = New-Object System.Collections.Generic.List[string]
$paths.Add('C:\Tools') | Out-Null
$paths.Add('C:\Program Files\Git\bin') | Out-Null
$paths.Add('C:\Program Files\Git\cmd') | Out-Null
$paths.Add('C:\Program Files\7-Zip') | Out-Null
$paths.Add('C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64') | Out-Null
$paths.Add('C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin') | Out-Null

$machinePath = [Environment]::GetEnvironmentVariable('Path','Machine')
$parts = @()
if ($machinePath) { $parts = $machinePath.Split(';') }
foreach ($p in $paths) {
  if (-not ($parts -contains $p)) {
    $machinePath = ($machinePath.TrimEnd(';') + ';' + $p)
  }
}
[Environment]::SetEnvironmentVariable('Path', $machinePath, 'Machine')


Write-ScriptLog -Type 'End' -StartTime $scriptTimer

