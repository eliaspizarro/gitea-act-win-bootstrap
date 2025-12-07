$ErrorActionPreference = 'Stop'
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { throw 'Chocolatey no está instalado. Ejecute 400-install-chocolatey.ps1 primero.' }
if (-not (Get-Command 7z -ErrorAction SilentlyContinue)) {
  choco install 7zip.commandline -y --no-progress | Out-Null
}
