param(
  [string]$InstallDir = 'C:\Tools\gitea-act-runner',
  [string]$Version,
  [string]$AssetUrl
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $InstallDir)) { New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null }
$exe = Join-Path $InstallDir 'act_runner.exe'
if (Test-Path -LiteralPath $exe) { return }
if (-not $AssetUrl -and -not $Version) { throw 'Debe proporcionar -AssetUrl o -Version (ej: 0.2.10).' }
if (-not $AssetUrl) {
  $file = "act_runner_${Version}_windows_amd64.zip"
  $AssetUrl = "https://gitea.com/gitea/act_runner/releases/download/v$Version/$file"
}
$tmp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ([Guid]::NewGuid().ToString())) -Force
$zip = Join-Path $tmp.FullName 'act_runner.zip'
Invoke-WebRequest -UseBasicParsing -Uri $AssetUrl -OutFile $zip
Expand-Archive -Path $zip -DestinationPath $InstallDir -Force
$found = Get-ChildItem -Path $InstallDir -Recurse -Filter act_runner.exe -ErrorAction SilentlyContinue | Select-Object -First 1
if ($found -and ($found.FullName -ne $exe)) { Move-Item -Force -Path $found.FullName -Destination $exe }
if (-not (Test-Path -LiteralPath $exe)) { throw 'act_runner.exe no se encontró tras la extracción.' }
$machinePath = [Environment]::GetEnvironmentVariable('Path','Machine')
if (-not ($machinePath.Split(';') -contains $InstallDir)) {
  [Environment]::SetEnvironmentVariable('Path', ($machinePath.TrimEnd(';') + ';' + $InstallDir), 'Machine')
}
