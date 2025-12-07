# Importar funciones de logging estandarizado
. "D:\Develop\personal\gitea-act-win-bootstrap\scripts\00-bootstrap\..\00-bootstrap\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'
$paths = @(
  'C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\signtool.exe',
  'C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x86\signtool.exe'
)
$found = $null
foreach ($p in $paths) { if (Test-Path -LiteralPath $p) { $found = $p; break } }
if (-not $found) {
  $kits = 'C:\Program Files (x86)\Windows Kits\10\bin'
  if (Test-Path -LiteralPath $kits) {
    $s = Get-ChildItem -Path $kits -Recurse -Filter signtool.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($s) { $found = $s.FullName }
  }
}
if (-not $found) {
  if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { throw 'Chocolatey no estÃ¡ instalado. Ejecute scripts/40-system-tools/400-install-chocolatey.ps1 primero.' }
  try {
    choco install windows-sdk-10.0 -y --no-progress | Out-Null
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
  } catch {
    Write-Warning 'No se pudo instalar windows-sdk-10.0 vÃ­a Chocolatey. Verifique conectividad o intente manualmente.'
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
  }
  $paths2 = @(
    'C:\\Program Files (x86)\\Windows Kits\\10\\bin\\x64\\signtool.exe',
    'C:\\Program Files (x86)\\Windows Kits\\10\\bin\\x86\\signtool.exe'
  )
  foreach ($p in $paths2) { if (Test-Path -LiteralPath $p) { $found = $p; break } }
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
}
if ($found) {
  $dir = Split-Path -Path $found -Parent
  $pathM = [Environment]::GetEnvironmentVariable('Path','Machine')
  if (-not ($pathM.Split(';') -contains $dir)) {
    [Environment]::SetEnvironmentVariable('Path', ($pathM.TrimEnd(';') + ';' + $dir), 'Machine')
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
  }
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
} else {
  Write-Warning 'Windows SDK / signtool no encontrados. Asegure instalaciÃ³n del componente Windows10SDK.26100.'
  Write-ScriptLog -Type 'End' -StartTime $scriptTimer
}


