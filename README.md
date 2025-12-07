# Gitea Act Runner Windows Bootstrap

[![Unattended Mode](https://img.shields.io/badge/Mode-100%25%20Unattended-brightgreen.svg)](docs/ENVIRONMENT_VARIABLES.md)
[![PowerShell](https://img.shields.io/badge/Shell-PowerShell-blue.svg)](https://docs.microsoft.com/powershell/)
[![Windows](https://img.shields.io/badge/Platform-Windows%20Server%20205%20%7C%20Windows%2010%2F11-lightgrey.svg)]()

Bootstrap automatizado y **100% desatendido** para Gitea `act_runner` en Windows Server 2025 / Windows 10/11 usando PowerShell y Chocolatey.

## ✅ Características Principales

- **🚀 Ejecución 100% desatendida**: Todos los 42 scripts funcionan sin entradas interactivas
- **⚙️ Configuración centralizada**: Sistema completo de variables de entorno
- **✅ Validación automática**: Script de validación con auditoría completa
- **📚 Documentación completa**: Guías detalladas y referencia de variables
- **🔧 Instalación headless**: Todo se instala en modo CLI sin GUI

## 🎯 Quick Start (Modo Desatendido)

### 1. Configurar Variables de Entorno
```powershell
# Copiar archivo de configuración
Copy-Item configs\set-env.sample.ps1 configs\set-env.ps1

# Editar con sus valores reales
notepad configs\set-env.ps1
```

**Variables requeridas mínimas**:
```powershell
GITEA_SERVER_URL = 'https://gitea.miempresa.com'
GITEA_RUNNER_TOKEN = 'glrt-abc123def456...'
RUNNER_NAME = 'win-runner-01'
GITEA_BOOTSTRAP_USER = 'gitea-runner'
GITEA_BOOTSTRAP_RUNNER_PASSWORD = 'ClaveSegura123!@#'
```

### 2. Cargar Variables de Entorno
```powershell
# Cargar las variables en la sesión actual de PowerShell (¡IMPORTANTE!)
. .\configs\set-env.ps1

# Verificar que las variables se cargaron correctamente
Get-ChildItem Env:GITEA_BOOTSTRAP_*
```

### 3. Validar Configuración
```powershell
# Ejecutar como administrador
Get-ChildItem ".\scripts\00-bootstrap\040-validate-environment.ps1" | ForEach-Object { & $_.FullName }
```

### 3. Ejecutar Bootstrap Completo

**Opción A: Ejecución por grupo (recomendado)**
```powershell
# Grupo 00: Bootstrap y validación
Get-ChildItem ".\scripts\00-bootstrap\*.ps1" | ForEach-Object { & $_.FullName }

# Grupo 10: Configuración del sistema operativo
Get-ChildItem ".\scripts\10-os-config\*.ps1" | ForEach-Object { & $_.FullName }

# Grupo 20: Usuarios y permisos
Get-ChildItem ".\scripts\20-users-and-permissions\*.ps1" | ForEach-Object { & $_.FullName }

# Grupo 30: Hardening de seguridad
Get-ChildItem ".\scripts\30-security-hardening\*.ps1" | ForEach-Object { & $_.FullName }

# Grupo 40: Herramientas del sistema
Get-ChildItem ".\scripts\40-system-tools\*.ps1" | ForEach-Object { & $_.FullName }

# Grupo 50: Toolchain de compilación
Get-ChildItem ".\scripts\50-build-toolchain\*.ps1" | ForEach-Object { & $_.FullName }

# Grupo 60: Gitea Act Runner
Get-ChildItem ".\scripts\60-gitea-act-runner\*.ps1" | ForEach-Object { & $_.FullName }

# Grupo 70: Mantenimiento (opcional)
Get-ChildItem ".\scripts\70-maintenance\*.ps1" | ForEach-Object { & $_.FullName }
```

**Opción B: Ejecución con PowerShell (automatizada)**
```powershell
# Ejecutar todos los scripts en orden automáticamente
Get-ChildItem -Path "scripts" -Recurse -Filter "*.ps1" | 
    Sort-Object { [int]($_.Name -split '-')[0] }, { [int]($_.Name -split '-')[1] } | 
    ForEach-Object { & $_.FullName }
```

### 4. Verificar Runner
```powershell
# El runner debería estar registrado y funcionando
Get-Service -Name "gitea-act-runner"
```

## 📋 Documentación

| Documento | Descripción |
|-----------|-------------|
| [📖 Variables de Entorno](docs/ENVIRONMENT_VARIABLES.md) | Referencia completa de 30+ variables |
| [📋 Overview](docs/overview.md) | Arquitectura y flujo detallado |
| [🔧 Activación](docs/activation-and-limitations.md) | Activación Windows desatendida |
| [🐛 Troubleshooting](docs/troubleshooting.md) | Problemas comunes y soluciones |
| [🛡️ Hardening](docs/hardening-checklist.md) | Seguridad y mejores prácticas |

### 🔗 Enlaces Rápidos
- [📁 Repositorio en GitHub](https://github.com/eliaspizarro/gitea-act-win-bootstrap)
- [⚙️ Configuración del Runner](docs/ENVIRONMENT_VARIABLES.md#gitea-runner-configuration)
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
- `GITEA_BOOTSTRAP_TIMEZONE`: Zona horaria (default: UTC)
- `GITEA_BOOTSTRAP_INSTALL_DIR`: Directorio de herramientas (default: C:\Tools)
- `GITEA_BOOTSTRAP_PRODUCT_KEY`: Clave de activación Windows
- `GITEA_BOOTSTRAP_FIREWALL_ALLOW_WINRM`: Permitir WinRM (default: false)

[📖 Ver todas las variables](docs/ENVIRONMENT_VARIABLES.md)

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

- ✅ **Scripts totales**: 42
- ✅ **Scripts desatendidos**: 42 (100%)
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

[Ver LICENSE](LICENSE) para detalles.

---

**🎯 Listo para producción**: Ejecución completamente desatendida con validación automática y documentación completa.