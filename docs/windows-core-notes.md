# Notas para Windows (Server) Core

Entorno sin GUI; todo es headless/CLI.

## Consideraciones
- Ejecutar PowerShell como Administrador en pasos de SO.
- Conectividad saliente a Chocolatey/Microsoft/Gitea.
- Logs en `C:\Logs\*`.

## Equivalentes CLI
- 7-Zip: paquete Chocolatey `7zip.commandline` (`7z.exe`).
- .NET SDK: `dotnet-8.0-sdk` (verificar `dotnet --info`).
- Node.js: `nodejs` 24.x (verificar `node -v`).
- Git: `git` (`git --version`).
- Build Tools: `visualstudio2026buildtools` + `vswhere`.
- Windows SDK: `windows-sdk-10.0` (verificar `signtool.exe`).

## Orden sugerido
1. `scripts/00-bootstrap/*`
2. `scripts/10-os-config/*` (incluye `115` rutas largas, `170` activación)
3. `scripts/40-system-tools/*`
4. `scripts/50-build-toolchain/*`
5. `configs/set-env.sample.ps1`
6. `scripts/60-gitea-act-runner/*`

## Red/Firewall
- WinRM opcional: `scripts/00-bootstrap/030-enable-winrm-optional.ps1 -Enable`.
- Reglas mínimas CI: `scripts/30-security-hardening/310-config-firewall-for-ci.ps1`.

## PATH y rutas largas
- Habilitar: `scripts/10-os-config/115-enable-long-paths.ps1`.
- PATH herramientas: `scripts/50-build-toolchain/550-config-path-for-build-tools.ps1`.

## YAML del runner
1) Ejecuta `configs/set-env.sample.ps1`.
2) Genera YAML: `scripts/60-gitea-act-runner/630-config-act-runner-yaml.ps1`.

## Verificación rápida
- `choco --version`, `dotnet --info`, `node -v`, `git --version`.
- `vswhere -products Microsoft.VisualStudio.Product.BuildTools`.
- `act_runner --version` y logs en `C:\Logs\ActRunner`.

