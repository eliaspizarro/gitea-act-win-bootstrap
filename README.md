# Gitea Act Runner Windows Bootstrap

[![Unattended Mode](https://img.shields.io/badge/Mode-100%25%20Unattended-brightgreen.svg)](docs/ENVIRONMENT_VARIABLES.md)
[![PowerShell](https://img.shields.io/badge/Shell-PowerShell-blue.svg)](https://docs.microsoft.com/powershell/)
[![Windows](https://img.shields.io/badge/Platform-Windows%20Server%20205%20%7C%20Windows%2010%2F11-lightgrey.svg)]()

Bootstrap automatizado y **100% desatendido** para Gitea `act_runner` en Windows Server 2025 / Windows 10/11 usando PowerShell, Chocolatey y NuGet.

## ✅ Características Principales

- **🚀 Ejecución 100% desatendida**: Todos los 43 scripts funcionan sin entradas interactivas
- **⚙️ Configuración centralizada**: Sistema completo de variables de entorno
- **✅ Validación automática**: Script de validación con auditoría completa
- **📚 Documentación completa**: Guías detalladas y referencia de variables
- **🔧 Instalación headless**: Todo se instala en modo CLI sin GUI

## 🎯 Quick Start (Modo Desatendido)

### 📥 Descargar Última Versión

```powershell
# Descargar el release más reciente
Invoke-WebRequest -Uri "https://github.com/eliaspizarro/gitea-act-win-bootstrap/archive/refs/heads/main.zip" -OutFile "gitea-act-win-bootstrap-main.zip"

# Extraer el archivo
Expand-Archive -Path "gitea-act-win-bootstrap-main.zip" -DestinationPath "." -Force

# Entrar al directorio del proyecto
cd gitea-act-win-bootstrap-main
```

### 1. Configurar Variables de Entorno
```powershell
# Copiar archivo de configuración
Copy-Item configs\set-env.sample.ps1 configs\set-env.ps1

# Editar el archivo configs\set-env.ps1 con la información correspondiente
```

**Variables requeridas mínimas**:
```powershell
GITEA_SERVER_URL = 'https://gitea.miempresa.com'
GITEA_RUNNER_TOKEN = 'glrt-abc123def456...'
RUNNER_NAME = 'win-runner-01'
GITEA_BOOTSTRAP_USER = 'gitea-runner'
GITEA_BOOTSTRAP_RUNNER_PASSWORD = 'ClaveSegura123!@#'
```

### 2. Cargar Variables de Entorno (Temporales - Solo Sesión Actual)
```powershell
# Cargar las variables en la sesión actual de PowerShell
# NOTA: Las variables son temporales y solo duran esta sesión
. .\configs\set-env.ps1
```

> **⚠️ Importante**: Las variables de entorno ahora son temporales (Process scope) y no persisten tras reiniciar PowerShell o el sistema. Debe ejecutar `.\configs\set-env.ps1` en cada nueva sesión.

### 3. Validar Configuración
```powershell
# Ejecutar como administrador
& ".\scripts\00-bootstrap\000-validate-environment.ps1"
```

### 3. Ejecutar Bootstrap Completo

**Opción A: Ejecución por grupo (recomendado)**

#### Grupo 00: Bootstrap y validación
```powershell
Get-ChildItem ".\scripts\00-bootstrap\*.ps1" | ForEach-Object { & $_.FullName }
```

#### Grupo 10: Configuración del sistema operativo
```powershell
Get-ChildItem ".\scripts\10-os-config\*.ps1" | ForEach-Object { & $_.FullName }
```

#### Grupo 20: Usuarios y permisos
```powershell
Get-ChildItem ".\scripts\20-users-and-permissions\*.ps1" | ForEach-Object { & $_.FullName }
```

#### Grupo 30: Hardening de seguridad
```powershell
Get-ChildItem ".\scripts\30-security-hardening\*.ps1" | ForEach-Object { & $_.FullName }
```

#### Grupo 40: Herramientas del sistema
```powershell
Get-ChildItem ".\scripts\40-system-tools\*.ps1" | ForEach-Object { & $_.FullName }
```

#### Grupo 50: Toolchain de compilación
```powershell
Get-ChildItem ".\scripts\50-build-toolchain\*.ps1" | ForEach-Object { & $_.FullName }
```

#### Grupo 60: Gitea Act Runner
```powershell
Get-ChildItem ".\scripts\60-gitea-act-runner\*.ps1" | ForEach-Object { & $_.FullName }
```

#### Grupo 70: Mantenimiento (opcional)
```powershell
Get-ChildItem ".\scripts\70-maintenance\*.ps1" | ForEach-Object { & $_.FullName }
```

*Nota: El script 180-install-windows-updates.ps1 instala actualizaciones sin reinicio automático para permitir ejecución continua del batch.*

**Opción B: Ejecución con PowerShell (automatizada)**
```powershell
# Ejecutar todos los scripts en orden automáticamente
Get-ChildItem -Path "scripts" -Recurse -Filter "*.ps1" | 
    Where-Object { $_.FullName -notmatch '\\lib\\' -and $_.Name -match '^\d{3}-.*\.ps1$' } |
    Sort-Object { [int]($_.Name -split '-')[0] } | 
    ForEach-Object { & $_.FullName }
```

### 4. Verificar Runner
Verificar que la tarea programada existe y está configurada.

```powershell
Get-ScheduledTask -TaskName "GiteaActRunner" | Select-Object TaskName, State, Actions
```

### 5. Administrar Tarea del Runner

**Iniciar la tarea del runner**
```powershell
Start-ScheduledTask -TaskName "GiteaActRunner"
```

**Detener la tarea del runner (antes de reiniciar el servidor)**
```powershell
Stop-ScheduledTask -TaskName "GiteaActRunner"
```

**Ver estado de la tarea**
```powershell
Get-ScheduledTask -TaskName "GiteaActRunner" | Select-Object State, LastRunTime
```

**Ver usuario del proceso act_runner**
```powershell
Get-CimInstance Win32_Process -Filter "Name='act_runner.exe'" | ForEach-Object {
  $owner = Invoke-CimMethod -InputObject $_ -MethodName GetOwner
  [PSCustomObject]@{
    PID     = $_.ProcessId
    Usuario = "$($owner.Domain)\$($owner.User)"
  }
}
```

**Ver logs del runner**
### 6. Administrar Procesos del Act Runner

**Ver procesos act_runner activos**
```powershell
Get-Process -Name "act_runner" -ErrorAction SilentlyContinue | Select-Object Id, StartTime, CPU
```

**Terminar proceso específico (reemplazar ID)**
```powershell
Stop-Process -Id 1234 -Force -ErrorAction SilentlyContinue
```

**Terminar todos los procesos act_runner**
```powershell
Get-Process -Name "act_runner" -ErrorAction SilentlyContinue | Stop-Process -Force
```

**Verificar que no queden procesos activos**
```powershell
Get-Process -Name "act_runner" -ErrorAction SilentlyContinue
```

## 📋 Documentación

| Documento | Descripción |
|-----------|-------------|
| [📋 Overview](docs/overview.md) | Arquitectura y flujo detallado |
| [🔧 Activación](docs/activation-and-limitations.md) | Activación Windows desatendida |
| [🐛 Troubleshooting](docs/troubleshooting.md) | Problemas comunes y soluciones |
| [🛡️ Hardening](docs/hardening-checklist.md) | Seguridad y mejores prácticas |

### 🔗 Enlaces Rápidos
- [📁 Repositorio en GitHub](https://github.com/eliaspizarro/gitea-act-win-bootstrap)
- [⚙️ Configuración del Runner](configs/set-env.sample.ps1)
- [🔒 Guía de Seguridad](docs/hardening-checklist.md)
- [❓ Preguntas Frecuentes](docs/troubleshooting.md)

## 🏗️ Arquitectura

```
gitea-act-win-bootstrap/
├── configs/
│   └── set-env.sample.ps1          # Configuración centralizada
├── scripts/
│   ├── 00-bootstrap/               # Scripts de validación y preparación
│   ├── 10-os-config/               # Configuración del sistema
│   ├── 20-users-and-permissions/   # Usuarios y permisos
│   ├── 30-security-hardening/      # Seguridad y firewall
│   ├── 40-system-tools/            # Chocolatey y herramientas
│   ├── 50-build-toolchain/         # SDK y herramientas de build
│   ├── 60-gitea-act-runner/        # Instalación del runner
│   └── 70-maintenance/             # Limpieza y mantenimiento
└── docs/                           # Documentación completa
```

## 🔧 Variables de Entorno Clave

### Requeridas
- `GITEA_SERVER_URL`: URL del servidor Gitea
- `GITEA_RUNNER_TOKEN`: Token del runner
- `RUNNER_NAME`: Nombre único del runner
- `GITEA_BOOTSTRAP_USER`: Usuario local
- `GITEA_BOOTSTRAP_RUNNER_PASSWORD`: Contraseña del usuario

### Opcionales Populares
- `GITEA_BOOTSTRAP_TIMEZONE`: ID de zona horaria de Windows en inglés (default: UTC). Liste IDs con: `tzutil /l`
- `GITEA_BOOTSTRAP_NTP_SERVER`: Servidor NTP para sincronización (default: ntp.shoa.cl)
- `GITEA_BOOTSTRAP_INSTALL_DIR`: Directorio de herramientas (default: C:\Tools)
- `GITEA_BOOTSTRAP_ACT_RUNNER_VERSION`: Versión de act_runner (default: 0.2.13)
- `GITEA_BOOTSTRAP_WINSDK_VERSION`: Versión específica del Windows SDK (default: 10.0.26100.6901)
- `GITEA_BOOTSTRAP_AV_EXCLUSIONS`: Variables de entorno para exclusiones AV (default: GITEA_BOOTSTRAP_INSTALL_DIR,GITEA_BOOTSTRAP_TEMP_DIR,GITEA_BOOTSTRAP_LOG_DIR,GITEA_BOOTSTRAP_PROFILE_BASE_DIR)
- `GITEA_BOOTSTRAP_PRODUCT_KEY`: Clave de activación Windows
- `GITEA_BOOTSTRAP_FIREWALL_ALLOW_WINRM`: Permitir WinRM (default: false)
- `GITEA_BOOTSTRAP_USER_GROUPS`: Grupos locales para el usuario del runner. Acepta SIDs (recomendado, p. ej., `S-1-5-32-544`) o alias independientes del idioma (`Administrators`,`Users`,`Performance Log Users`). Ver lista completa de SSID estándar below.

**Nota**: El Windows SDK se instala vía NuGet para mayor precisión de versiones. [Ver versiones disponibles](https://www.nuget.org/packages/Microsoft.Windows.SDK.BuildTools)

[📖 Ver configuración completa en configs/set-env.sample.ps1](configs/set-env.sample.ps1)

## 📋 Grupos Locales y SSID Estándar (Windows Server 2025)

Lista completa de grupos locales y sus SSID correspondientes en una instalación limpia de Windows Server 2025 Core:

| Nombre del Grupo | SSID | Descripción |
|------------------|------|-------------|
| Administradores | S-1-5-32-544 | Acceso completo al sistema |
| Usuarios | S-1-5-32-545 | Usuarios estándar del sistema |
| Invitados | S-1-5-32-546 | Acceso limitado para invitados |
| Usuarios avanzados | S-1-5-32-547 | Permisos elevados limitados |
| Operadores de cuentas | S-1-5-32-548 | Gestión de cuentas de usuario |
| Operadores de servidor | S-1-5-32-549 | Administración del servidor |
| Opers. de impresión | S-1-5-32-550 | Administración de impresoras |
| Operadores de copia de seguridad | S-1-5-32-551 | Ejecutar backups y restauraciones |
| Duplicadores | S-1-5-32-552 | Replicación de dominio |
| Operadores de configuración de red | S-1-5-32-556 | Configuración de red |
| Usuarios del monitor de sistema | S-1-5-32-558 | Monitoreo de rendimiento |
| Usuarios del registro de rendimiento | S-1-5-32-559 | Acceso a logs de rendimiento |
| Usuarios COM distribuidos | S-1-5-32-562 | Acceso a DCOM distribuido |
| Operadores criptográficos | S-1-5-32-569 | Operaciones criptográficas |
| IIS_IUSRS | S-1-5-32-568 | Usuarios de IIS |
| Lectores del registro de eventos | S-1-5-32-573 | Acceso a logs de eventos |
| Acceso DCOM a Serv. de certif. | S-1-5-32-574 | DCOM para servicios de certificados |
| Servidores de acceso remoto RDS | S-1-5-32-575 | Servidores RDS de acceso remoto |
| Servidores de extremo RDS | S-1-5-32-576 | Servidores RDS endpoint |
| Servidores de administración RDS | S-1-5-32-577 | Servidores RDS administración |
| Administradores de Hyper-V | S-1-5-32-578 | Administración de Hyper-V |
| Operadores de asistencia de control de acceso | S-1-5-32-579 | Asistencia de control de acceso |
| Usuarios de administración remota | S-1-5-32-580 | Administración remota |
| Usuarios de escritorio remoto | S-1-5-32-555 | Acceso vía Escritorio Remoto |
| Usuarios de OpenSSH | S-1-5-32-585 | Usuarios de OpenSSH |
| Propietarios del dispositivo | S-1-5-32-583 | Propietarios de dispositivos |
| Operadores de hardware en modo usuario | S-1-5-32-584 | Acceso a hardware en modo usuario |
| Storage Replica Administrators | S-1-5-32-582 | Administración de Storage Replica |
| System Managed Accounts Group | S-1-5-32-581 | Cuentas gestionadas por el sistema |

**Uso recomendado**: Para máxima compatibilidad internacional, use los SSID en lugar de los nombres de grupo (que varían según el idioma del sistema).

## 🚀 Flujo de Ejecución

1. **Configurar** → Copiar y editar `set-env.sample.ps1`
2. **Validar** → Ejecutar script de validación
3. **Bootstrap** → Scripts del sistema y herramientas
4. **Runner** → Instalar y configurar act_runner
5. **Mantenimiento** → Scripts de limpieza según necesidad

## 🛡️ Seguridad

⚠️ **Importante**: Las variables de entorno se almacenan como texto plano. Después del bootstrap:

```powershell
# Limpiar variables sensibles
Remove-Item Env:GITEA_BOOTSTRAP_PRODUCT_KEY
Remove-Item Env:GITEA_BOOTSTRAP_RUNNER_PASSWORD
[Environment]::SetEnvironmentVariable("GITEA_BOOTSTRAP_PRODUCT_KEY", $null, "Machine")
[Environment]::SetEnvironmentVariable("GITEA_BOOTSTRAP_RUNNER_PASSWORD", $null, "Machine")
```

## 📊 Estado del Proyecto

- ✅ **Scripts totales**: 43
- ✅ **Scripts desatendidos**: 43 (100%)
- ✅ **Variables de entorno**: 30+
- ✅ **Documentación completa**
- ✅ **Validación automática**

## 🤝 Contribuciones

1. Fork el repositorio
2. Crear feature branch
3. Seguir patrones de variables de entorno `GITEA_BOOTSTRAP_*`
4. Actualizar documentación
5. Submit Pull Request

## 📄 Licencia

Este proyecto está licenciado bajo la **MIT License**, que permite:

- ✅ **Uso comercial**: Puedes vender el software
- ✅ **Distribución**: Puedes compartir copias  
- ✅ **Modificación**: Puedes modificar el código
- ✅ **Sublicenciamiento**: Puedes licenciar a terceros
- ✅ **Uso sin restricciones**: Uso privado o comercial

[Ver LICENSE](LICENSE) para detalles completos.

---

**🎯 Listo para producción**: Ejecución completamente desatendida con validación automática y documentación completa.