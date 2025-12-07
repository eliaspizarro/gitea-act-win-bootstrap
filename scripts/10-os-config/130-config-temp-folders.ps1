$ErrorActionPreference = 'Stop'
$path = 'C:\Temp'
if (-not (Test-Path -LiteralPath $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
[Environment]::SetEnvironmentVariable('TEMP', $path, 'Machine')
[Environment]::SetEnvironmentVariable('TMP', $path, 'Machine')
try {
  [Environment]::SetEnvironmentVariable('TEMP', $path, 'User')
  [Environment]::SetEnvironmentVariable('TMP', $path, 'User')
} catch {}
