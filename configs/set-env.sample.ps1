$ErrorActionPreference = 'Stop'

# Configuración de variables de entorno para ejecución desatendida del bootstrap
# IMPORTANTE: Copie este archivo a set-env.ps1 (sin .sample) antes de editar valores reales
# ADVERTENCIA: set-env.ps1 debe estar en .gitignore para evitar cometer credenciales
# Reemplace los valores ${...} con sus valores reales antes de ejecutar
#
# Documentación completa: docs/ENVIRONMENT_VARIABLES.md
#
# Ejemplo de valores completos:
# GITEA_SERVER_URL = 'https://gitea.miempresa.com'
# GITEA_RUNNER_TOKEN = 'glrt-xxxxxxxxxxxxxxxxxxxx'
# RUNNER_NAME = 'win-server-01-prod'
# GITEA_BOOTSTRAP_PRODUCT_KEY = 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX'
# GITEA_BOOTSTRAP_RUNNER_PASSWORD = 'MiClaveSegura123!@#'
#
# NOTA: Después de ejecutar este script, reinicie su sesión de PowerShell o reinicie
# el sistema para que las variables de entorno de máquina tomen efecto completo.

$envVars = @{
  # Configuración del servidor Gitea
  GITEA_SERVER_URL = 'https://TU_GITEA'                                     # URL completa de su servidor Gitea (ej: https://gitea.miempresa.com)
  GITEA_RUNNER_TOKEN = '${GITEA_RUNNER_TOKEN}'                              # Token del runner: vaya a Gitea → Settings → Actions → Runners → Generate token
  
  # Configuración del runner
  RUNNER_NAME = '${RUNNER_NAME}'                                            # Nombre único del runner (ej: win-server-01-prod, debe ser único en su organización)
  RUNNER_LABELS = 'windows,core,win2025'                                    # Etiquetas que determinan qué trabajos ejecuta este runner (ej: docker,build,deploy)
  RUNNER_WORKDIR = 'C:\Tools\gitea-act-runner\work'                         # Directorio donde se descargan y ejecutan los trabajos CI/CD
  
  # Activación de Windows Server 2025
  GITEA_BOOTSTRAP_CHECK_ONLY = 'false'                                      # 'true' para solo verificar estado de activación, 'false' para activar con la clave
  GITEA_BOOTSTRAP_PRODUCT_KEY = '${WINDOWS_PRODUCT_KEY}'                    # Clave de producto retail/MAK/KMS (formato: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX)
  
  # Configuración de usuario del runner
  GITEA_BOOTSTRAP_USER = 'gitea-runner'                                     # Nombre de usuario local que ejecutará el servicio del runner
  GITEA_BOOTSTRAP_RUNNER_PASSWORD = '${RUNNER_PASSWORD}'                    # Contraseña segura: mínimo 12 caracteres, mayúsculas, minúsculas, números y símbolos
  GITEA_BOOTSTRAP_USER_GROUPS = 'S-1-5-32-545,S-1-5-32-559'                 # Grupos por SID (independiente de idioma). Users=...545, PerfLog=...559
                                                                            # También se aceptan alias: 'Users,Performance Log Users,Administrators'. El script resolverá al nombre localizado.
                                                                            # NOTA: Para instalar paquetes MSI/software dinámicamente (ej: setup-python@v5), agregue Administrators (SID S-1-5-32-544),
                                                                            # pero considere riesgos de seguridad. Alternativa: Pre-instale herramientas durante bootstrap.
  
  # Configuración de carpetas de perfil de usuario
  GITEA_BOOTSTRAP_PROFILE_BASE_DIR = 'C:\CI'                                # Directorio base para perfiles de usuario (work, cache)
  GITEA_BOOTSTRAP_PROFILE_WORK_DIR = 'work'                                 # Nombre del subdirectorio de trabajo
  GITEA_BOOTSTRAP_PROFILE_CACHE_DIR = 'cache'                               # Nombre del subdirectorio de caché
  
  # Configuración regional y de zona horaria
  GITEA_BOOTSTRAP_TIMEZONE = 'UTC'                                          # ID de zona horaria de Windows (en inglés). Ej: 'UTC','Eastern Standard Time'
                                                                            # Liste IDs disponibles con: tzutil /l
  GITEA_BOOTSTRAP_SYSTEM_LOCALE = ''                                        # Configuración regional del sistema (ej: 'es-ES', 'en-US') - vacío para mantener actual
  GITEA_BOOTSTRAP_USER_LOCALE = ''                                          # Configuración regional del usuario (ej: 'es-ES', 'en-US') - vacío para mantener actual
  GITEA_BOOTSTRAP_INPUT_LOCALE = ''                                         # Lista de idiomas de entrada (ej: 'es-ES', 'en-US') - vacío para mantener actual
  GITEA_BOOTSTRAP_NTP_SERVER = 'ntp.shoa.cl'                                # Servidor NTP para sincronización de tiempo (ej: 'ntp.shoa.cl', 'pool.ntp.org')
  
  # Configuración de directorios temporales
  GITEA_BOOTSTRAP_TEMP_DIR = 'C:\Temp'                                      # Directorio temporal personalizado (dejar vacío para usar defaults del sistema)
  GITEA_BOOTSTRAP_TMP_DIR = 'C:\Temp'                                       # Directorio TMP personalizado (dejar vacío para usar defaults del sistema)
  
  # Configuración de pagefile
  GITEA_BOOTSTRAP_PAGEFILE_SIZE = ''                                        # Tamaño del pagefile en MB (ej: '8192') - vacío para gestión automática
  GITEA_BOOTSTRAP_PAGEFILE_DRIVE = 'C:'                                     # Unidad del pagefile (ej: 'C:', 'D:')
  
  # Configuración de instalación de herramientas
  GITEA_BOOTSTRAP_INSTALL_DIR = 'C:\Tools'                                  # Directorio base para instalación de herramientas
  GITEA_BOOTSTRAP_ACT_RUNNER_VERSION = '0.2.13'                             # Versión específica de act_runner a instalar (ej: 0.2.13)
  GITEA_BOOTSTRAP_CHOCO_CACHE_DIR = 'C:\ChocoCache'                         # Directorio caché de Chocolatey para optimizar descargas
  GITEA_BOOTSTRAP_LOG_DIR = 'C:\Logs'                                       # Directorio base para logs de servicios y aplicaciones
  GITEA_BOOTSTRAP_DOTNET_CHANNEL = '8.0'                                    # Canal de .NET SDK a instalar (ej: 6.0, 7.0, 8.0)
  GITEA_BOOTSTRAP_WINSDK_VERSION = '10.0.26100.6901'                        # Versión específica del Windows SDK a instalar vía NuGet
  GITEA_BOOTSTRAP_AV_EXCLUSIONS = 'GITEA_BOOTSTRAP_INSTALL_DIR,GITEA_BOOTSTRAP_TEMP_DIR,GITEA_BOOTSTRAP_LOG_DIR,GITEA_BOOTSTRAP_PROFILE_BASE_DIR'  # Variables de entorno para exclusiones AV (separadas por ,)
  
  # Configuración de firewall
  GITEA_BOOTSTRAP_FIREWALL_ALLOW_WINRM = 'false'                            # Permitir WinRM a través del firewall (true/false)
  
  # Configuración de limpieza y mantenimiento
  GITEA_BOOTSTRAP_CLEANUP_PATHS = 'C:\CI,C:\Logs,C:\Tools\gitea-act-runner' # Directorios para limpieza automática (separados por ,)
  GITEA_BOOTSTRAP_CLEANUP_OLDER_THAN_DAYS = '14'                            # Días de antigüedad para archivos a eliminar
  GITEA_BOOTSTRAP_TEMP_CLEANUP_OLDER_THAN_DAYS = '7'                        # Días para limpieza de archivos temporales de Windows
  
  # Configuración de exportación de estado
  GITEA_BOOTSTRAP_EXPORT_OUTPUT_DIR = 'C:\Logs'                             # Directorio para exportar estado del runner
  GITEA_BOOTSTRAP_EXPORT_INCLUDE_DIAGNOSTICS = 'false'                      # Incluir diagnóstico en exportación (true/false)
  
  # Configuración opcional de WinRM
  GITEA_BOOTSTRAP_ENABLE_WINRM = 'false'                                    # Habilitar WinRM para administración remota (true/false)
  
  # Configuración opcional de SSH
  GITEA_BOOTSTRAP_ENABLE_SSH = 'false'                                      # Habilitar servidor SSH para administración remota (true/false)
  GITEA_BOOTSTRAP_SSH_PORT = '22'                                           # Puerto SSH (ej: 22, 2222) - cambiar para seguridad
  GITEA_BOOTSTRAP_SSH_FIREWALL = 'true'                                     # Permitir SSH a través del firewall (true/false)
  
  # Configuración opcional de auto-logon
  GITEA_BOOTSTRAP_AUTO_LOGON_ENABLE = 'false'                               # Habilitar auto-logon de Windows (true/false)
  GITEA_BOOTSTRAP_AUTO_LOGON_USER = ''                                      # Usuario para auto-logon (dejar vacío para desactivar)
  GITEA_BOOTSTRAP_AUTO_LOGON_PASSWORD = ''                                  # Contraseña para auto-logon (dejar vacío para desactivar)
  GITEA_BOOTSTRAP_AUTO_LOGON_DOMAIN = ''                                    # Dominio para auto-logon (opcional)
}

foreach ($var in $envVars.GetEnumerator()) {
  try { 
    # Variables temporales solo para esta sesión (no persisten tras reinicio)
    [Environment]::SetEnvironmentVariable($var.Key, $var.Value, 'Process') 
  } 
  catch { 
    Write-Warning "No se pudo establecer variable temporal: $($var.Key)"
  }
  Set-Item -Path "Env:$($var.Key)" -Value $var.Value | Out-Null
}
