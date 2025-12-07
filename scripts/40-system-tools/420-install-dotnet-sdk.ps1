param(
  [string]$Channel = '8.0'  # Canal LTS por defecto
)
$ErrorActionPreference = 'Stop'

# Priorizar variables de entorno para ejecución desatendida
$Channel = if ($env:GITEA_BOOTSTRAP_DOTNET_CHANNEL -and $env:GITEA_BOOTSTRAP_DOTNET_CHANNEL -ne '') { $env:GITEA_BOOTSTRAP_DOTNET_CHANNEL } else { $Channel }
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { throw 'Chocolatey no está instalado. Ejecute 400-install-chocolatey.ps1 primero.' }
$pkg = "dotnet-$Channel-sdk"
$dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
if ($dotnet) {
  $has = (& dotnet --list-sdks) -match "^$Channel" | Select-Object -First 1
  if ($has) { return }
}
choco install $pkg -y --no-progress | Out-Null
