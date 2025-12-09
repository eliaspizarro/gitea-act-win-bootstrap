# Troubleshooting

## 🔧 Problemas con Variables de Entorno

### Variables no configuradas o vacías
**Síntomas**: Scripts usan valores por defecto en lugar de valores personalizados
```powershell
# Verificar variables configuradas
Get-ChildItem Env: | Where-Object Name -like "GITEA_BOOTSTRAP_*"
Get-ChildItem Env: | Where-Object Name -like "RUNNER_*"

# Verificar variables específicas
Write-Host "GITEA_SERVER_URL: $env:GITEA_SERVER_URL"
Write-Host "GITEA_RUNNER_TOKEN: $env:GITEA_RUNNER_TOKEN"
```

**Solución**: Ejecutar `.\configs\set-env.ps1` como administrador

### Script de validación falla
**Síntomas**: `000-validate-environment.ps1` reporta variables faltantes
```powershell
# Ejecutar validación detallada
.\scripts\00-bootstrap\000-validate-environment.ps1 -Verbose

# Listar variables requeridas
.\scripts\00-bootstrap\000-validate-environment.ps1 -ListRequired
```

**Solución**: Configurar variables faltantes en `configs\set-env.ps1`

### Variables con strings vacíos
**Síntomas**: Scripts ignoran variables aunque estén configuradas
**Causa**: Variables configuradas como string vacío no sobrescriben parámetros
```powershell
# Verificar si las variables están vacías
if ([string]::IsNullOrWhiteSpace($env:GITEA_BOOTSTRAP_TIMEZONE)) {
    Write-Host "TIMEZONE está vacío o nulo"
}
```

**Solución**: Asegurar que las variables tengan valores no vacíos

### Permisos insuficientes para variables de máquina
**Síntomas**: Variables no persisten después de reiniciar
```powershell
# Verificar si las variables son de máquina o usuario
[Environment]::GetEnvironmentVariable("GITEA_SERVER_URL", "Machine")
[Environment]::GetEnvironmentVariable("GITEA_SERVER_URL", "User")
```

**Solución**: Ejecutar scripts como administrador

## 🌐 Zona Horaria y Grupos (Multiidioma)

### Zona horaria no se aplica
**Síntomas**: El sistema mantiene la zona horaria anterior después de ejecutar el script
**Causa**: `GITEA_BOOTSTRAP_TIMEZONE` debe ser un ID en inglés, no el nombre localizado
```powershell
# Listar IDs disponibles (en inglés)
tzutil /l

# Ejemplo de configuración correcta
$env:GITEA_BOOTSTRAP_TIMEZONE = 'Pacific SA Standard Time'  # para Chile continental
# o
$env:GITEA_BOOTSTRAP_TIMEZONE = 'UTC'
```

**Solución**: Usar un ID devuelto por `tzutil /l`. No usar nombres localizados.

### El runner no tiene privilegios de administrador
**Síntomas**: En workflows, `IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)` devuelve $false
**Causa**: El usuario no fue agregado al grupo Administradores por nombre localizado
```powershell
# Verificar si el usuario está en el grupo localizado
Get-LocalGroupMember -Group 'Administradores' | Where-Object { $_.Name -like "*\$env:GITEA_BOOTSTRAP_USER" }

# Verificar propietario del proceso act_runner
Get-CimInstance Win32_Process -Filter "Name='act_runner.exe'" | ForEach-Object {
  $owner = Invoke-CimMethod -InputObject $_ -MethodName GetOwner
  [PSCustomObject]@{ PID = $_.ProcessId; Usuario = "$($owner.Domain)\$($owner.User)" }
}
```

**Solución**: Usar SIDs o alias independientes del idioma
```powershell
# Opción 1: SIDs (recomendado)
$env:GITEA_BOOTSTRAP_USER_GROUPS = 'S-1-5-32-545,S-1-5-32-559,S-1-5-32-544'  # Users, PerfLog, Admins

# Opción 2: Alias (ingles o español)
$env:GITEA_BOOTSTRAP_USER_GROUPS = 'Users,Performance Log Users,Administrators'

# Aplicar cambios
.\scripts\20-users-and-permissions\220-add-runner-user-to-groups.ps1

# Refrescar token de la tarea
Stop-ScheduledTask -TaskName "GiteaActRunner"
Start-ScheduledTask -TaskName "GiteaActRunner"
```

### Grupos no encontrados
**Síntomas**: El script 220 no agrega el usuario a ningún grupo
**Causa**: Nombres de grupos no coinciden con el idioma del sistema
```powershell
# Ver nombres de grupos localizados
Get-LocalGroup | Select-Object Name | Sort-Object Name

# Probar resolución manual
.\scripts\20-users-and-permissions\220-add-runner-user-to-groups.ps1 -Verbose
```

**Solución**: Usar SIDs o alias como se muestra arriba.

**Solución**: Ejecutar `set-env.ps1` como administrador

## 🚀 Problemas de Ejecución Desatendida

### Scripts piden entradas interactivas
**Síntomas**: Scripts solicitan `Read-Host` o parámetros manualmente
```powershell
# Auditar scripts para detectar problemas
.\scripts\00-bootstrap\000-validate-environment.ps1 -AuditScripts
```

**Solución**: Configurar variables de entorno antes de ejecutar scripts

### Activación Windows falla en modo desatendido
**Síntomas**: `170-windows-activation.ps1` no activa automáticamente
```powershell
# Verificar configuración de activación
Write-Host "CHECK_ONLY: $env:GITEA_BOOTSTRAP_CHECK_ONLY"
Write-Host "PRODUCT_KEY configurada: $(-not [string]::IsNullOrWhiteSpace($env:GITEA_BOOTSTRAP_PRODUCT_KEY))"

# Verificar estado manualmente
.\scripts\10-os-config\170-windows-activation.ps1 -CheckOnly
```

**Solución**: Configurar `GITEA_BOOTSTRAP_PRODUCT_KEY` y `GITEA_BOOTSTRAP_CHECK_ONLY = 'false'`

### Runner no se registra con Gitea
**Síntomas**: `act_runner` no aparece en la interfaz de Gitea
```powershell
# Probar conexión manualmente
Test-NetConnection $env:GITEA_SERVER_URL -Port 443

# Verificar token
if ([string]::IsNullOrWhiteSpace($env:GITEA_RUNNER_TOKEN)) {
    Write-Error "GITEA_RUNNER_TOKEN no está configurada"
}
```

**Solución**: Verificar `GITEA_SERVER_URL` y `GITEA_RUNNER_TOKEN`

## Problemas de Instalación

### Chocolatey falla o timeouts
- Reintentar y validar conectividad a `community.chocolatey.org`
- Verificar `GITEA_BOOTSTRAP_CHOCO_CACHE_DIR` si está configurada
- Deshabilitar progreso: ya aplicado (400-install-chocolatey)

### Herramientas no se instalan en directorio personalizado
**Síntomas**: Herramientas se instalan en `C:\Tools` en lugar de directorio personalizado
```powershell
# Verificar directorio de instalación
Write-Host "INSTALL_DIR: $env:GITEA_BOOTSTRAP_INSTALL_DIR"

# Verificar si el directorio existe
Test-Path $env:GITEA_BOOTSTRAP_INSTALL_DIR
```

**Solución**: Configurar `GITEA_BOOTSTRAP_INSTALL_DIR` antes de instalar herramientas

## 👤 Problemas de Usuarios y Permisos

### Usuario del runner no se crea
**Síntomas**: Scripts fallan con "usuario no existe"
```powershell
# Verificar configuración de usuario
Write-Host "Usuario: $env:GITEA_BOOTSTRAP_USER"
Get-LocalUser -Name $env:GITEA_BOOTSTRAP_USER -ErrorAction SilentlyContinue

# Verificar contraseña configurada
if ([string]::IsNullOrWhiteSpace($env:GITEA_BOOTSTRAP_RUNNER_PASSWORD)) {
    Write-Error "GITEA_BOOTSTRAP_RUNNER_PASSWORD no está configurada"
}
```

**Solución**: Configurar `GITEA_BOOTSTRAP_USER` y `GITEA_BOOTSTRAP_RUNNER_PASSWORD`

### Permisos insuficientes para servicio
**Síntomas**: Runner no puede iniciar como servicio
```powershell
# Verificar derechos de logon
.\scripts\20-users-and-permissions\240-config-service-logon-rights.ps1

# Verificar grupos del usuario
Get-LocalGroupMember -Group "Users" | Where-Object Name -like "*$env:GITEA_BOOTSTRAP_USER*"
```

**Solución**: Ejecutar script de derechos de logon y verificar `GITEA_BOOTSTRAP_USER_GROUPS`

## 🌐 Problemas de Red y Conectividad

### `act_runner` no conecta a Gitea
- Variables: ejecuta `configs\set-env.sample.ps1` para configurar conexión
- Probar reachability: `Test-NetConnection $env:GITEA_SERVER_URL -Port 443`

### Firewall bloquea conexiones
**Síntomas**: Conexiones externas fallan
```powershell
# Verificar configuración de firewall
Write-Host "Allow WinRM: $env:GITEA_BOOTSTRAP_FIREWALL_ALLOW_WINRM"

# Verificar reglas de firewall
Get-NetFirewallRule -DisplayName "Windows Remote Management*"
```

**Solución**: Configurar `GITEA_BOOTSTRAP_FIREWALL_ALLOW_WINRM = 'true'` si se necesita WinRM

## 🔧 Problemas de Sistema

### Sincronización NTP falla
**Síntomas**: El servidor no sincroniza la hora con el servidor NTP configurado
```powershell
# Verificar configuración NTP actual
w32tm /query /configuration

# Verificar estado de sincronización
w32tm /query /status

# Verificar servidor NTP configurado
Write-Host "NTP Server: $env:GITEA_BOOTSTRAP_NTP_SERVER"
```

**Solución**: 
1. Verificar que `GITEA_BOOTSTRAP_NTP_SERVER` esté configurado correctamente
2. Ejecutar manualmente el script de configuración de zona horaria y NTP:
   ```powershell
   .\scripts\10-os-config\120-set-timezone-and-locale.ps1
   ```
3. Verificar conectividad al servidor NTP:
   ```powershell
   Test-NetConnection $env:GITEA_BOOTSTRAP_NTP_SERVER -Port 123
   ```

### Servidor NTP no responde
**Síntomas**: Timeout al intentar sincronizar con el servidor NTP
```powershell
# Probar sincronización manual
w32tm /resync /rediscover

# Cambiar a servidor NTP alternativo
w32tm /config /manualpeerlist:"pool.ntp.org" /syncfromflags:manual /update
w32tm /resync /force
```

**Solución**: Configurar un servidor NTP alternativo en `GITEA_BOOTSTRAP_NTP_SERVER`

### Runner no levanta al inicio
- Ver tarea programada: `schtasks /Query /TN GiteaActRunner /V /FO LIST`
- Forzar ejecución: `schtasks /Run /TN GiteaActRunner`
- Revisar script: `C:\Tools\gitea-act-runner\start-act-runner.ps1`
- Logs: `C:\Logs\ActRunner` y `Event Viewer` (Windows Core: `wevtutil qe System /c:50 /f:text`)

### Problemas de PATH o binarios faltantes
- Ejecutar `scripts\50-build-toolchain\550-config-path-for-build-tools.ps1`
- Validar binarios: `dotnet --info`, `node -v`, `git --version`, `7z`, `signtool.exe`

### VS Build Tools no detectado
- `vswhere -products Microsoft.VisualStudio.Product.BuildTools`
- Reinstalar: `scripts\40-system-tools\440-install-vs-buildtools.ps1`

### `signtool.exe` no encontrado
- Ejecutar `scripts\50-build-toolchain\510-install-winsdk-10.0.26100.ps1`
- Validar rutas de Windows SDK bajo `C:\Program Files (x86)\Windows Kits\10\bin\*`

### Rutas largas
- Ejecutar `scripts\10-os-config\115-enable-long-paths.ps1`
- Para Git: `git config --system core.longpaths true`

## 🛠️ Herramientas de Diagnóstico

### Script de validación completo
```powershell
# Validación completa con diagnóstico
.\scripts\00-bootstrap\000-validate-environment.ps1

# Auditoría de scripts
.\scripts\00-bootstrap\000-validate-environment.ps1 -AuditScripts

# Solo variables requeridas
.\scripts\00-bootstrap\000-validate-environment.ps1 -SkipOptional
```

### Verificación de estado final
```powershell
# Verificar servicio del runner
Get-Service -Name "gitea-act-runner" -ErrorAction SilentlyContinue

# Verificar archivo de registro del runner
Get-Content C:\Tools\gitea-act-runner\.runner

# Verificar variables de entorno configuradas
Get-ChildItem Env: | Where-Object Name -like "GITEA*" | Sort-Object Name
```

## 📞 Obtener Ayuda

1. **Ejecutar validación**: `.\scripts\00-bootstrap\000-validate-environment.ps1`
2. **Revisar logs**: `C:\Logs\ActRunner\`
3. **Verificar variables**: `Get-ChildItem Env: | Where-Object Name -like "GITEA*"`
4. **Consultar documentación**: `docs\ENVIRONMENT_VARIABLES.md`
5. **Ejecutar auditoría**: `.\scripts\00-bootstrap\000-validate-environment.ps1 -AuditScripts`

