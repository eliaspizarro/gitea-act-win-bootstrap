# Variables de Entorno - Ejecución Desatendida

## Estándar GITEA_BOOTSTRAP_*

Todos los scripts soportan ejecución desatendida usando variables de entorno. Las variables con prefijo `GITEA_BOOTSTRAP_*` son para configuración específica del bootstrap, mientras que las sin prefijo (`RUNNER_*`, `GITEA_SERVER_URL`) son para configuración runtime del runner. Las variables de entorno tienen prioridad sobre los parámetros de línea de comandos.

## Variables Requeridas

### Configuración del Servidor Gitea
| Variable | Propósito | Default | Scripts que usan |
|----------|-----------|---------|------------------|
| `GITEA_SERVER_URL` | URL completa del servidor Gitea | - | `set-env.sample.ps1` |
| `GITEA_RUNNER_TOKEN` | Token del runner generado en Gitea | - | `set-env.sample.ps1` |

### Configuración del Runner
| Variable | Propósito | Default | Scripts que usan |
|----------|-----------|---------|------------------|
| `RUNNER_NAME` | Nombre único del runner | - | `set-env.sample.ps1` |
| `RUNNER_LABELS` | Etiquetas del runner | `windows,core,win2025` | `set-env.sample.ps1` |
| `RUNNER_WORKDIR` | Directorio de trabajo | `C:\Tools\gitea-act-runner\work` | `set-env.sample.ps1` |
| `RUNNER_CONCURRENCY` | Número de trabajos simultáneos | `1` | `set-env.sample.ps1` |

### Configuración de Usuario del Runner
| Variable | Propósito | Default | Scripts que usan |
|----------|-----------|---------|------------------|
| `GITEA_BOOTSTRAP_USER` | Nombre de usuario local para el runner | `gitea-runner` | `200-*.ps1`, `210-*.ps1`, `220-*.ps1`, `230-*.ps1`, `240-*.ps1` |
| `GITEA_BOOTSTRAP_RUNNER_PASSWORD` | Contraseña del usuario del runner | - | `210-set-runner-user-password.ps1` |
| `GITEA_BOOTSTRAP_USER_GROUPS` | Grupos para el usuario (separados por ,) | `Users,Performance Log Users,Remote Desktop Users` | `220-add-runner-user-to-groups.ps1` |

## Variables Opcionales

### Activación de Windows
| Variable | Propósito | Default | Scripts que usan |
|----------|-----------|---------|------------------|
| `GITEA_BOOTSTRAP_CHECK_ONLY` | Solo verificar activación (true/false) | `false` | `170-windows-activation.ps1` |
| `GITEA_BOOTSTRAP_PRODUCT_KEY` | Clave de producto Windows | - | `170-windows-activation.ps1` |

### Configuración Regional
| Variable | Propósito | Default | Scripts que usan |
|----------|-----------|---------|------------------|
| `GITEA_BOOTSTRAP_TIMEZONE` | Zona horaria del sistema | `UTC` | `120-set-timezone-and-locale.ps1` |
| `GITEA_BOOTSTRAP_SYSTEM_LOCALE` | Configuración regional del sistema | - | `120-set-timezone-and-locale.ps1` |
| `GITEA_BOOTSTRAP_USER_LOCALE` | Configuración regional del usuario | - | `120-set-timezone-and-locale.ps1` |
| `GITEA_BOOTSTRAP_INPUT_LOCALE` | Lista de idiomas de entrada | - | `120-set-timezone-and-locale.ps1` |

### Directorios y Almacenamiento
| Variable | Propósito | Default | Scripts que usan |
|----------|-----------|---------|------------------|
| `GITEA_BOOTSTRAP_TEMP_DIR` | Directorio temporal personalizado | `C:\Temp` | `130-config-temp-folders.ps1` |
| `GITEA_BOOTSTRAP_TMP_DIR` | Directorio TMP personalizado | `C:\Temp` | `130-config-temp-folders.ps1` |
| `GITEA_BOOTSTRAP_PAGEFILE_SIZE` | Tamaño del pagefile en MB | - | `140-config-pagefile.ps1` |
| `GITEA_BOOTSTRAP_PAGEFILE_DRIVE` | Unidad del pagefile | `C:` | `140-config-pagefile.ps1` |

### Instalación de Herramientas
| Variable | Propósito | Default | Scripts que usan |
|----------|-----------|---------|------------------|
| `GITEA_BOOTSTRAP_INSTALL_DIR` | Directorio base para herramientas | `C:\Tools` | `600-*.ps1`, `610-*.ps1` |
| `GITEA_BOOTSTRAP_CHOCO_CACHE_DIR` | Directorio caché de Chocolatey | `D:\ChocoCache` | `400-install-chocolatey.ps1` |
| `GITEA_BOOTSTRAP_LOG_DIR` | Directorio base para logs | `C:\Logs` | `610-create-start-script.ps1` |
| `GITEA_BOOTSTRAP_DOTNET_CHANNEL` | Canal de .NET SDK | `8.0` | `420-install-dotnet-sdk.ps1` |

### Perfiles de Usuario
| Variable | Propósito | Default | Scripts que usan |
|----------|-----------|---------|------------------|
| `GITEA_BOOTSTRAP_PROFILE_BASE_DIR` | Directorio base para perfiles | `C:\CI` | `230-config-user-profile-folders.ps1` |
| `GITEA_BOOTSTRAP_PROFILE_WORK_DIR` | Nombre del subdirectorio de trabajo | `work` | `230-config-user-profile-folders.ps1` |
| `GITEA_BOOTSTRAP_PROFILE_CACHE_DIR` | Nombre del subdirectorio de caché | `cache` | `230-config-user-profile-folders.ps1` |

### Seguridad
| Variable | Propósito | Default | Scripts que usan |
|----------|-----------|---------|------------------|
| `GITEA_BOOTSTRAP_AV_EXCLUSIONS` | Directorios a excluir del antivirus | `C:\Tools;D:\Temp;C:\Tools\gitea-act-runner\work` | `330-config-av-exclusions.ps1` |
| `GITEA_BOOTSTRAP_FIREWALL_ALLOW_WINRM` | Permitir WinRM en firewall | `false` | `310-config-firewall-for-ci.ps1` |

### Limpieza y Mantenimiento
| Variable | Propósito | Default | Scripts que usan |
|----------|-----------|---------|------------------|
| `GITEA_BOOTSTRAP_CLEANUP_PATHS` | Directorios para limpieza | `C:\CI,C:\Logs,C:\Tools\gitea-act-runner` | `700-cleanup-build-artifacts.ps1` |
| `GITEA_BOOTSTRAP_CLEANUP_OLDER_THAN_DAYS` | Días para eliminar archivos | `14` | `700-cleanup-build-artifacts.ps1` |
| `GITEA_BOOTSTRAP_TEMP_CLEANUP_OLDER_THAN_DAYS` | Días para limpieza de temporales Windows | `7` | `710-cleanup-windows-temp.ps1` |
| `GITEA_BOOTSTRAP_EXPORT_OUTPUT_DIR` | Directorio para exportar estado | `C:\Logs` | `730-export-runner-state.ps1` |
| `GITEA_BOOTSTRAP_EXPORT_INCLUDE_DIAGNOSTICS` | Incluir diagnóstico en exportación | `false` | `730-export-runner-state.ps1` |

### Opciones Avanzadas (Opcional)
| Variable | Propósito | Default | Scripts que usan |
|----------|-----------|---------|------------------|
| `GITEA_BOOTSTRAP_ENABLE_WINRM` | Habilitar WinRM para administración remota | `false` | `030-enable-winrm-optional.ps1` |
| `GITEA_BOOTSTRAP_AUTO_LOGON_ENABLE` | Habilitar auto-logon de Windows | `false` | `160-config-auto-logon-optional.ps1` |
| `GITEA_BOOTSTRAP_AUTO_LOGON_USER` | Usuario para auto-logon | - | `160-config-auto-logon-optional.ps1` |
| `GITEA_BOOTSTRAP_AUTO_LOGON_PASSWORD` | Contraseña para auto-logon | - | `160-config-auto-logon-optional.ps1` |
| `GITEA_BOOTSTRAP_AUTO_LOGON_DOMAIN` | Dominio para auto-logon | - | `160-config-auto-logon-optional.ps1` |

## Uso

### Configurar variables de entorno
```powershell
# Copiar archivo de configuración
Copy-Item configs\set-env.sample.ps1 configs\set-env.ps1

# Editar con valores reales
notepad configs\set-env.ps1

# Ejecutar configuración (como administrador)
.\configs\set-env.ps1
```

### Validar configuración
```powershell
# Listar variables requeridas
.\scripts\00-bootstrap\040-validate-environment.ps1 -ListRequired

# Validar configuración actual
.\scripts\00-bootstrap\040-validate-environment.ps1

# Validar sin variables opcionales
.\scripts\00-bootstrap\040-validate-environment.ps1 -SkipOptional

# Auditar scripts para detectar entradas interactivas
.\scripts\00-bootstrap\040-validate-environment.ps1 -AuditScripts
```

### Ejecutar scripts desatendidos
```powershell
# Verificar activación
.\scripts\10-os-config\170-windows-activation.ps1

# Activar Windows
.\scripts\10-os-config\170-windows-activation.ps1

# Crear usuario
.\scripts\20-users-and-permissions\200-create-runner-user.ps1

# Configurar zona horaria
.\scripts\10-os-config\120-set-timezone-and-locale.ps1
```

## Scripts Modificados

Los siguientes scripts han sido estandarizados para variables de entorno (21 total):

### Configuración del Sistema (8)
- `120-set-timezone-and-locale.ps1`
- `130-config-temp-folders.ps1`
- `140-config-pagefile.ps1`
- `160-config-auto-logon-optional.ps1`
- `170-windows-activation.ps1`
- `200-create-runner-user.ps1`
- `210-set-runner-user-password.ps1`
- `030-enable-winrm-optional.ps1`

### Usuarios y Permisos (3)
- `220-add-runner-user-to-groups.ps1`
- `230-config-user-profile-folders.ps1`
- `240-config-service-logon-rights.ps1`

### Seguridad (2)
- `310-config-firewall-for-ci.ps1`
- `330-config-av-exclusions.ps1`

### Herramientas (4)
- `400-install-chocolatey.ps1`
- `420-install-dotnet-sdk.ps1`
- `600-install-act-runner.ps1`
- `610-create-start-script.ps1`

### Mantenimiento (4)
- `700-cleanup-build-artifacts.ps1`
- `710-cleanup-windows-temp.ps1`
- `730-export-runner-state.ps1`
- `040-validate-environment.ps1` (script de validación)

## Scripts Pendientes

**✅ NINGUNO - 100% COMPLETO**

Todos los 42 scripts del proyecto ahora soportan ejecución completamente desatendida usando variables de entorno.

## Resumen del Proyecto

### ✅ Estado Final
- **Scripts totales**: 42
- **Scripts estandarizados**: 21
- **Scripts compatibles desatendidos**: 42 (100%)
- **Variables de entorno**: 30+
- **Documentación completa**: ✅

### 🎯 Características Clave
- **Ejecución completamente desatendida**: Todos los scripts funcionan sin entradas interactivas
- **Configuración centralizada**: `set-env.sample.ps1` con todas las variables necesarias
- **Validación automática**: Script `040-validate-environment.ps1` con auditoría completa
- **Patrón consistente**: `GITEA_BOOTSTRAP_*` para bootstrap, sin prefijo para runtime
- **Documentación completa**: Guías de uso, ejemplos y referencia de variables

### 🚀 Flujo de Uso Producción
1. **Configurar**: `Copy-Item configs\set-env.sample.ps1 configs\set-env.ps1`
2. **Editar**: Configurar URL Gitea, token, contraseña y opciones personalizadas
3. **Validar**: `.\scripts\00-bootstrap\040-validate-environment.ps1`
4. **Ejecutar**: Todos los scripts sin parámetros interactivos

### 🔧 Herramientas Incluidas
- **Validador de entorno**: Verifica variables requeridas y opcionales
- **Auditor de scripts**: Detecta scripts con entradas interactivas
- **Configurador central**: Establece variables de entorno de máquina/usuario
- **Documentación completa**: Referencia de todas las variables y ejemplos

## Seguridad

⚠️ **Advertencia de seguridad:**
- Las claves de producto y contraseñas en variables de entorno se almacenan como texto plano
- Las variables de máquina persisten entre reinicios
- **Recomendación:** Limpiar variables sensibles después del bootstrap:
```powershell
Remove-Item Env:GITEA_BOOTSTRAP_PRODUCT_KEY
Remove-Item Env:GITEA_BOOTSTRAP_RUNNER_PASSWORD
[Environment]::SetEnvironmentVariable("GITEA_BOOTSTRAP_PRODUCT_KEY", $null, "Machine")
[Environment]::SetEnvironmentVariable("GITEA_BOOTSTRAP_RUNNER_PASSWORD", $null, "Machine")
```

## Patrones de Implementación

### En scripts PowerShell
```powershell
# Priorizar variables de entorno (patrones actualizados)
$User = if ($env:GITEA_BOOTSTRAP_USER -and $env:GITEA_BOOTSTRAP_USER -ne '') { 
  $env:GITEA_BOOTSTRAP_USER 
} else { 
  $User 
}

# Para booleanos
$CheckOnly = if ($env:GITEA_BOOTSTRAP_CHECK_ONLY -eq 'true') { $true } else { $CheckOnly }

# Para arrays (separados por , o ;)
$Paths = $env:GITEA_BOOTSTRAP_CLEANUP_PATHS.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }

# Para datos sensibles
if ($env:GITEA_BOOTSTRAP_PRODUCT_KEY -and -not $ProductKey) {
  $ProductKey = ConvertTo-SecureString $env:GITEA_BOOTSTRAP_PRODUCT_KEY -AsPlainText -Force
}
```

## Extensión

Para agregar soporte de variables de entorno a nuevos scripts:
1. Usar prefijo `GITEA_BOOTSTRAP_` para configuración de bootstrap
2. Usar sin prefijo para configuración runtime (RUNNER_*, GITEA_*)
3. Priorizar variables sobre parámetros con validación de strings vacíos
4. Documentar en esta tabla
5. Agregar variable a `set-env.sample.ps1` si aplica
6. Actualizar script de validación `040-validate-environment.ps1`
