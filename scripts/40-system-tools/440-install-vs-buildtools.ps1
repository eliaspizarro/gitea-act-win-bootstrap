# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$InstallDir = if ($env:GITEA_BOOTSTRAP_INSTALL_DIR) { 
  $env:GITEA_BOOTSTRAP_INSTALL_DIR 
} else { 
  'C:\Tools' 
}
$MSBuildDir = Join-Path $InstallDir 'msbuild'

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { throw 'Chocolatey no está instalado. Ejecute 400-install-chocolatey.ps1 primero.' }

# Asegura vswhere
if (-not (Get-Command vswhere -ErrorAction SilentlyContinue)) {
  choco install vswhere -y --no-progress | Out-Null
}

# Detecta BuildTools existente
$vsbt = & vswhere -products Microsoft.VisualStudio.Product.BuildTools -property installationPath 2>$null | Select-Object -First 1
if (-not $vsbt) {
  $params = @(
    '--add Microsoft.VisualStudio.Workload.MSBuildTools',
    '--add Microsoft.VisualStudio.Workload.VCTools',
    '--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64',
    '--add Microsoft.VisualStudio.Component.Windows10SDK.26100',
    '--add Microsoft.Net.Component.4.8.SDK',
    '--add Microsoft.Net.Component.4.8.TargetingPack',
    '--add Microsoft.NetCore.Component.SDK',
    '--quiet','--wait','--norestart','--nocache',
    "--installPath $MSBuildDir"
  ) -join ' '
  choco install visualstudio2026buildtools --package-parameters "$params" -y --no-progress
  $vsbt = & vswhere -products Microsoft.VisualStudio.Product.BuildTools -property installationPath 2>$null | Select-Object -First 1
}

# validación MSBuild
$msbuild = Get-ChildItem -Path "$vsbt\MSBuild\Current\Bin" -Filter msbuild.exe -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $msbuild) { Write-Warning 'MSBuild no encontrado tras la instalación de BuildTools.' }

# Agregar MSBuild al PATH para usar comandos sin ruta completa
$msbuildBinPath = Join-Path $vsbt 'MSBuild\Current\Bin'
if ($msbuild -and (Test-Path $msbuildBinPath)) {
  $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
  if ($currentPath -notlike "*$msbuildBinPath*") {
    [Environment]::SetEnvironmentVariable('PATH', "$currentPath;$msbuildBinPath", 'Machine')
    $env:PATH = "$env:PATH;$msbuildBinPath"
    Write-Host "MSBuild agregado al PATH: $msbuildBinPath" -ForegroundColor Green
  }
}

Write-ScriptLog -Type 'End' -StartTime $scriptTimer


