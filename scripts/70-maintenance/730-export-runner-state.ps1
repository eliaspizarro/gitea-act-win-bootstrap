param(
  [string]$OutputDir = 'C:\Logs',
  [switch]$IncludeDiagnostics
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$OutputDir = if ($env:GITEA_BOOTSTRAP_EXPORT_OUTPUT_DIR -and $env:GITEA_BOOTSTRAP_EXPORT_OUTPUT_DIR -ne '') { $env:GITEA_BOOTSTRAP_EXPORT_OUTPUT_DIR } else { $OutputDir }
if ($env:GITEA_BOOTSTRAP_EXPORT_INCLUDE_DIAGNOSTICS -and $env:GITEA_BOOTSTRAP_EXPORT_INCLUDE_DIAGNOSTICS -eq 'true') {
  $IncludeDiagnostics = $true
}

if (-not (Test-Path -LiteralPath $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$stage = Join-Path $env:TEMP ("runner_state_" + $ts)
New-Item -ItemType Directory -Path $stage -Force | Out-Null

# Priorizar variables de entorno para ejecución desatendida
$InstallDir = if ($env:GITEA_BOOTSTRAP_INSTALL_DIR) { 
  Join-Path $env:GITEA_BOOTSTRAP_INSTALL_DIR 'gitea-act-runner'
} else { 
  'C:\Tools\gitea-act-runner'
}

# Recolectar archivos clave
$items = @()
$items += 'C:\Logs'
$items += (Join-Path $InstallDir 'start-act-runner.ps1')
$items += (Join-Path $InstallDir '.runner')
$items += (Join-Path (Split-Path -Parent $PSCommandPath) '..\..\REPO_TREE.txt' | Resolve-Path -ErrorAction SilentlyContinue)
$items += (Join-Path (Split-Path -Parent $PSCommandPath) '..\..\tree' | Resolve-Path -ErrorAction SilentlyContinue)
$items += (Join-Path (Split-Path -Parent $PSCommandPath) '..\..\configs' | Resolve-Path -ErrorAction SilentlyContinue)

foreach ($i in $items) {
  if (-not $i) { continue }
  if (Test-Path -LiteralPath $i) {
    $dest = Join-Path $stage (Split-Path -Path $i -Leaf)
    try {
      if ((Get-Item $i).PSIsContainer) { Copy-Item -Recurse -Force -Path $i -Destination $dest }
      else { Copy-Item -Force -Path $i -Destination $dest }
    } catch {}
  }
}

# Diagnóstico opcional
if ($IncludeDiagnostics) {
  $diag = Join-Path $stage 'diagnostics.txt'
  $lines = New-Object System.Collections.Generic.List[string]
  try { $lines.Add("OS: " + (Get-ComputerInfo -Property OsName,OsVersion | ForEach-Object { $_.OsName + ' ' + $_.OsVersion })) } catch {}
  try { $lines.Add("dotnet: " + (& dotnet --info 2>$null | Select-Object -First 1)) } catch {}
  try { $lines.Add("node: " + (& node -v 2>$null)) } catch {}
  try { $lines.Add("git: " + (& git --version 2>$null)) } catch {}
  try {
    $runner = Get-Command act_runner -ErrorAction SilentlyContinue
    if ($runner) { $lines.Add("act_runner: " + (& act_runner --version 2>$null)) }
  } catch {}
  Set-Content -Path $diag -Value $lines -Encoding UTF8
}

# Empaquetar
$zip = Join-Path $OutputDir ("runner-state_" + $ts + '.zip')
if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip -Force

# Limpiar staging
Remove-Item -Recurse -Force -Path $stage -ErrorAction SilentlyContinue | Out-Null

Write-Output $zip

Write-ScriptLog -Type 'End' -StartTime $scriptTimer


