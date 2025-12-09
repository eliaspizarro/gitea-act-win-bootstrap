# Notas para Windows (Server) Core

Entorno sin GUI; todo es headless/CLI.

## Consideraciones
- Ejecutar PowerShell como Administrador en pasos de SO.
- Conectividad saliente a Chocolatey/Microsoft/Gitea.
- Logs en `C:\Logs\*`.
- Variables de entorno temporales: ejecutar `configs\set-env.ps1` en cada sesión.

## Equivalentes CLI
- 7-Zip: paquete Chocolatey `7zip.commandline` (`7z.exe`).
- .NET SDK: `dotnet-8.0-sdk` (verificar `dotnet --info`).
- Node.js: `nodejs` 24.x (verificar `node -v`).
- Git: `git` (`git --version`).
- Build Tools: `visualstudio2022buildtools` + `vswhere`.
- Windows SDK: instalación vía NuGet `Microsoft.Windows.SDK.BuildTools` (verificar `signtool.exe`).

## Orden sugerido de ejecución
1. **Configurar variables**: `Copy-Item configs\set-env.sample.ps1 configs\set-env.ps1` y editar
2. **Cargar variables**: `. .\configs\set-env.ps1` (en cada sesión)
3. `scripts/00-bootstrap/*` (validación y preparación)
4. `scripts/10-os-config/*` (incluye `115` rutas largas, `120` timezone/NTP, `170` activación)
5. `scripts/20-users-and-permissions/*` (usuario y permisos del runner)
6. `scripts/30-security-hardening/*` (firewall y seguridad)
7. `scripts/40-system-tools/*` (Chocolatey y herramientas base)
8. `scripts/50-build-toolchain/*` (SDK y herramientas de build)
9. `scripts/60-gitea-act-runner/*` (instalación y configuración del runner)
10. `scripts/70-maintenance/*` (opcional, según necesidad)

## Configuración de tiempo y NTP
- **Zona horaria**: `scripts/10-os-config/120-set-timezone-and-locale.ps1`
- **Servidor NTP**: configurar `GITEA_BOOTSTRAP_NTP_SERVER` (default: ntp.shoa.cl)
- **Sincronización**: automática con `w32tm /resync /force`
- **Importante**: El servicio `W32Time` debe estar corriendo para sincronización NTP

## Notas de reinicio
- **Recomendado**: Reiniciar después del grupo 10 (os-config) para aplicar timezone, pagefile y activación
- **Verificar servicio**: `Get-Service -Name "W32Time"` debe estar Running después del reinicio

## Red/Firewall
- WinRM opcional: `scripts/00-bootstrap/030-enable-winrm-optional.ps1 -Enable`.
- SSH opcional: `scripts/00-bootstrap/031-enable-ssh-optional.ps1 -Enable`.
- Reglas mínimas CI: `scripts/30-security-hardening/310-config-firewall-for-ci.ps1`.
- Exclusiones AV: `scripts/30-security-hardening/330-config-av-exclusions.ps1`.

## PATH y rutas largas
- Habilitar: `scripts/10-os-config/115-enable-long-paths.ps1`.
- PATH herramientas: `scripts/50-build-toolchain/550-config-path-for-build-tools.ps1`.
- Directorios temporales: `scripts/10-os-config/130-config-temp-folders.ps1`.

## Configuración del runner
1) Configurar variables en `configs/set-env.ps1`
2) Crear usuario: `scripts/20-users-and-permissions/200-create-runner-user.ps1`
3) Instalar act_runner: `scripts/60-gitea-act-runner/600-install-act-runner.ps1`
4) Generar config: `scripts/60-gitea-act-runner/630-config-act-runner-yaml.ps1`
5) Registrar runner: `scripts/60-gitea-act-runner/640-register-act-runner.ps1`
6) Crear script inicio: `scripts/60-gitea-act-runner/620-create-start-script.ps1`
7) Crear tarea programada: `scripts/60-gitea-act-runner/630-register-act-schtask.ps1`

## Verificación rápida
- **Herramientas**: `choco --version`, `dotnet --info`, `node -v`, `git --version`
- **Build Tools**: `vswhere -products Microsoft.VisualStudio.Product.BuildTools`
- **Windows SDK**: `signtool.exe` (debe estar en PATH)
- **Runner**: `act_runner --version` y logs en `C:\Logs\ActRunner`
- **Tarea programada**: `Get-ScheduledTask -TaskName "GiteaActRunner"`
- **Sincronización NTP**: `w32tm /query /status`

## Variables de entorno clave
```powershell
# Requeridas
GITEA_SERVER_URL = 'https://gitea.miempresa.com'
GITEA_RUNNER_TOKEN = 'glrt-abc123...'
RUNNER_NAME = 'win-runner-01'
GITEA_BOOTSTRAP_USER = 'gitea-runner'
GITEA_BOOTSTRAP_RUNNER_PASSWORD = 'ClaveSegura123!@#'

# Opcionales útiles
GITEA_BOOTSTRAP_TIMEZONE = 'UTC'
GITEA_BOOTSTRAP_NTP_SERVER = 'ntp.shoa.cl'
GITEA_BOOTSTRAP_INSTALL_DIR = 'C:\Tools'
GITEA_BOOTSTRAP_ACT_RUNNER_VERSION = '0.2.13'
```

## Troubleshooting rápido
- **Validación completa**: `.\scripts\00-bootstrap\000-validate-environment.ps1`
- **Problemas NTP**: `.\scripts\10-os-config\120-set-timezone-and-locale.ps1`
- **Logs del runner**: `Get-Content C:\Logs\ActRunner\*.log`
- **Estado del servicio**: `Get-Service -Name "W32Time"`

