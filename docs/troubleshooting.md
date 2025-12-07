# Troubleshooting

## Runner no levanta al inicio
- Ver tarea programada: `schtasks /Query /TN GiteaActRunner /V /FO LIST`
- Forzar ejecución: `schtasks /Run /TN GiteaActRunner`
- Revisar script: `C:\\Tools\\gitea-act-runner\\start-act-runner.ps1`
- Logs: `C:\\Logs\\ActRunner` y `Event Viewer` (Windows Core: `wevtutil qe System /c:50 /f:text`)

## `act_runner` no conecta a Gitea
- Validar YAML: `C:\\Tools\\gitea-act-runner\\config.yaml`
- Variables: ejecuta `configs\\set-env.sample.ps1` y vuelve a generar YAML (`630-config-act-runner-yaml.ps1`).
- Probar reachability: `Test-NetConnection host -Port 443`

## Problemas de PATH o binarios faltantes
- Ejecutar `scripts\\50-build-toolchain\\550-config-path-for-build-tools.ps1`
- Validar binarios: `dotnet --info`, `node -v`, `git --version`, `7z`, `signtool.exe`

## VS Build Tools no detectado
- `vswhere -products Microsoft.VisualStudio.Product.BuildTools`
- Reinstalar: `scripts\\40-system-tools\\440-install-vs-buildtools.ps1`

## `signtool.exe` no encontrado
- Ejecutar `scripts\\50-build-toolchain\\510-install-winsdk-10.0.26100.ps1`
- Validar rutas de Windows SDK bajo `C:\\Program Files (x86)\\Windows Kits\\10\\bin\\*`

## WinRM/Remoto (opcional)
- Habilitar: `scripts\\00-bootstrap\\030-enable-winrm-optional.ps1 -Enable`
- Regla firewall: `scripts\\30-security-hardening\\310-config-firewall-for-ci.ps1 -AllowWinRM`

## Rutas largas
- Ejecutar `scripts\\10-os-config\\115-enable-long-paths.ps1`
- Para Git: `git config --system core.longpaths true`

## Activación de Windows
- Ver estado: `scripts\\10-os-config\\170-windows-activation.ps1 -CheckOnly`
- Activar con MAK: `-ProductKey (Read-Host 'Key' -AsSecureString)`

## Chocolatey falla o timeouts
- Reintentar y validar conectividad a `community.chocolatey.org`
- Deshabilitar progreso: ya aplicado (400-install-chocolatey)

## Permisos/privilegios insuficientes
- Reintentar en PowerShell elevado.
- `SeServiceLogonRight`: ejecutar `scripts\\20-users-and-permissions\\240-config-service-logon-rights.ps1`

