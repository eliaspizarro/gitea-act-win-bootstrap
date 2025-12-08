param(
  [string]$winsdkVersion = $null
)

# Importar funciones de logging estandarizado
. "$PSScriptRoot\..\lib\logging.ps1"

$scriptTimer = Start-ScriptTimer
Write-ScriptLog -Type 'Start'

$ErrorActionPreference = 'Stop'

# Leer versión desde parámetro o variable de entorno
if (-not $winsdkVersion) {
  $winsdkVersion = $env:GITEA_BOOTSTRAP_WINSDK_VERSION
}
if (-not $winsdkVersion) {
  throw 'La versión del Windows SDK no está definida. Use el parámetro -winsdkVersion o configure GITEA_BOOTSTRAP_WINSDK_VERSION en set-env.ps1'
}

# Directorio de instalación base
$installDir = if ($env:GITEA_BOOTSTRAP_INSTALL_DIR) { $env:GITEA_BOOTSTRAP_INSTALL_DIR } else { 'C:\Tools' }
$winsdkDir = Join-Path $installDir "WindowsSDK\$winsdkVersion"
$sdkBinPath = Join-Path $winsdkDir 'bin'

Write-Host "Instalando Windows SDK versión $winsdkVersion..."
Write-Host "Directorio de instalación: $winsdkDir"

# Verificar si ya está instalado
$signtoolPath = Join-Path $sdkBinPath 'x64\signtool.exe'
if (Test-Path -LiteralPath $signtoolPath) {
  Write-Host "Windows SDK $winsdkVersion ya está instalado."
} else {
  # Usar NuGet.exe (debe estar instalado por script previo)
  if (-not (Get-Command nuget -ErrorAction SilentlyContinue)) {
    throw 'NuGet.exe no encontrado. Ejecute primero el script de instalación de NuGet.'
  }

  # Crear directorio de instalación
  New-Item -Path $winsdkDir -ItemType Directory -Force | Out-Null

  # Descargar paquete NuGet del Windows SDK BuildTools
  Write-Host "Descargando Microsoft.Windows.SDK.BuildTools versión $winsdkVersion..."
  try {
    nuget install Microsoft.Windows.SDK.BuildTools -Version $winsdkVersion -OutputDirectory $winsdkDir -NoCache
  } catch {
    throw "No se pudo descargar el paquete NuGet. Verifique que la versión $winsdkVersion existe en NuGet."
  }

  # El paquete ya está extraído por nuget.exe, solo necesitamos encontrar la ruta correcta
  $packageDir = Join-Path $winsdkDir "Microsoft.Windows.SDK.BuildTools.$winsdkVersion"
  $versionShort = $winsdkVersion -replace '\.\d+$','.0'  # Extraer 10.0.26100.0 de 10.0.26100.6901
  
  # Usar la ruta correcta basada en la estructura real del paquete
  $correctSigntoolPath = Join-Path $packageDir "bin\$versionShort\x64\signtool.exe"
  
  if (Test-Path -LiteralPath $correctSigntoolPath) {
    $sdkBinPath = Split-Path $correctSigntoolPath -Parent
    Write-Host "Windows SDK encontrado en: $sdkBinPath"
  } else {
    throw "Windows SDK $winsdkVersion no se encontró en la ruta esperada: $correctSigntoolPath"
  }
}

# Agregar al PATH del sistema si no está presente
$pathM = [Environment]::GetEnvironmentVariable('Path','Machine')
if (-not ($pathM.Split(';') -contains $sdkBinPath)) {
  [Environment]::SetEnvironmentVariable('Path', ($pathM.TrimEnd(';') + ';' + $sdkBinPath), 'Machine')
  Write-Host "Se agregó $sdkBinPath al PATH del sistema."
  
  # Refrescar variables de entorno en la sesión actual
  $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
}

Write-Host "Windows SDK $winsdkVersion configurado correctamente."
Write-ScriptLog -Type 'End' -StartTime $scriptTimer
