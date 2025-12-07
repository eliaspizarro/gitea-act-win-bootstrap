# Checklist de Hardening (Mínimo Viable)

Use esta lista como verificación rápida. Todas las acciones son reversibles y están automatizadas por `scripts/30-security-hardening/*`.

## 🔐 Variables de Entorno y Seguridad

### Variables Sensibles
- [ ] **Limpiar variables sensibles después del bootstrap**:
  ```powershell
  # Ejecutar después de completar el bootstrap
  Remove-Item Env:GITEA_BOOTSTRAP_PRODUCT_KEY
  Remove-Item Env:GITEA_BOOTSTRAP_RUNNER_PASSWORD
  Remove-Item Env:GITEA_BOOTSTRAP_AUTO_LOGON_PASSWORD
  [Environment]::SetEnvironmentVariable("GITEA_BOOTSTRAP_PRODUCT_KEY", $null, "Machine")
  [Environment]::SetEnvironmentVariable("GITEA_BOOTSTRAP_RUNNER_PASSWORD", $null, "Machine")
  [Environment]::SetEnvironmentVariable("GITEA_BOOTSTRAP_AUTO_LOGON_PASSWORD", $null, "Machine")
  ```

- [ ] **Usar almacenes de secretos en producción**: Considerar Azure Key Vault, HashiCorp Vault o similar en lugar de variables de entorno
- [ ] **Validar configuración antes de ejecutar**: `.\scripts\00-bootstrap\040-validate-environment.ps1`
- [ ] **No almacenar claves en el repositorio**: Usar templates `${VARIABLE_NAME}` en `set-env.sample.ps1`

### Permisos de Variables
- [ ] **Ejecutar configuración como administrador**: Variables de máquina requieren privilegios elevados
- [ ] **Verificar alcance de variables**: Distinguir entre variables de máquina y usuario
- [ ] **Auditar variables configuradas**: `Get-ChildItem Env: | Where-Object Name -like "GITEA_BOOTSTRAP_*"`

## Sistema/Protocolo
- [ ] Deshabilitar SMBv1 (320): `Set-SmbServerConfiguration -EnableSMB1Protocol $false` y feature SMB1 off.
- [ ] Forzar TLS 1.2/1.3, deshabilitar TLS 1.0/1.1 (320): claves SCHANNEL aplicadas.
- [ ] .NET fuerte cifrado (300): `SchUseStrongCrypto=1` en 32/64 bits.

## Firewall/Red
- [ ] Perfilar Firewall activo (310): `Set-NetFirewallProfile ... -Enabled True`.
- [ ] WinRM solo si se requiere (310): usar `GITEA_BOOTSTRAP_FIREWALL_ALLOW_WINRM = 'true'` explícitamente
- [ ] Excluir directorios sensibles del antivirus: Configurar `GITEA_BOOTSTRAP_AV_EXCLUSIONS`

## Antivirus/Exclusiones
- [ ] Definir exclusiones (330) para: `C:\CI`, `C:\Tools`, `C:\Logs`, `C:\Tools\gitea-act-runner\work`
- [ ] Evitar desactivar protección en tiempo real salvo casos puntuales
- [ ] Configurar exclusiones vía `GITEA_BOOTSTRAP_AV_EXCLUSIONS` en modo desatendido

## Servicios
- [ ] Deshabilitar servicios no requeridos (340): Fax, Xbox*, WSearch (si no se usa indexado local)
- [ ] Configurar usuario del runner sin privilegios elevados por defecto
- [ ] Conceder `SeServiceLogonRight` si operará como servicio/tarea (240)

## Cuentas y Permisos
- [ ] **Usuario del runner**: Configurar vía `GITEA_BOOTSTRAP_USER` y `GITEA_BOOTSTRAP_RUNNER_PASSWORD`
- [ ] **Grupos personalizados**: Usar `GITEA_BOOTSTRAP_USER_GROUPS` según necesidades específicas
- [ ] **ACLs correctas**: En `C:\CI\work` y `C:\CI\cache` (230)
- [ ] **Perfiles de usuario**: Configurar vía `GITEA_BOOTSTRAP_PROFILE_*` variables

## Registro/Logs
- [ ] Habilitar Script/Module Logging de PowerShell (010)
- [ ] Centralizar logs en `C:\Logs\*` (configurable vía `GITEA_BOOTSTRAP_LOG_DIR`)
- [ ] Configurar limpieza automática de logs: `GITEA_BOOTSTRAP_CLEANUP_OLDER_THAN_DAYS`

## Validaciones Rápidas

### Seguridad de Variables
```powershell
# Verificar variables sensibles limpiadas
$env:GITEA_BOOTSTRAP_PRODUCT_KEY -eq $null
$env:GITEA_BOOTSTRAP_RUNNER_PASSWORD -eq $null

# Verificar variables de máquina configuradas
[Environment]::GetEnvironmentVariable("GITEA_SERVER_URL", "Machine") -ne $null
```

### Sistema
- [ ] `Get-SmbServerConfiguration | Select EnableSMB1Protocol` devuelve False
- [ ] `reg query` de SCHANNEL muestra TLS 1.2/1.3 habilitado
- [ ] `Get-MpPreference` refleja exclusiones esperadas
- [ ] `Get-Service` muestra servicios deshabilitados según lo planificado

### Configuración Desatendida
```powershell
# Validar configuración completa
.\scripts\00-bootstrap\040-validate-environment.ps1

# Auditar scripts compatibles
.\scripts\00-bootstrap\040-validate-environment.ps1 -AuditScripts
```

## 🛡️ Recomendaciones de Hardening Adicional

### En Producción
1. **Usar CI/CD seguro**: Inyectar variables sensibles en tiempo de ejecución
2. **Rotación de credenciales**: Cambiar contraseñas regularmente
3. **Monitoreo de auditoría**: Revisar logs de configuración y acceso
4. **Segmentación de red**: Limitar conexiones salientes del runner

### Después del Bootstrap
1. **Limpiar variables sensibles inmediatamente**
2. **Eliminar archivos temporales con credenciales**
3. **Establecer políticas de retención de logs**
4. **Configurar alertas de seguridad**

### Validación Continua
```powershell
# Script de verificación de seguridad post-bootstrap
function Test-SecurityHardening {
    param()
    
    $issues = @()
    
    # Verificar variables sensibles
    if ($env:GITEA_BOOTSTRAP_PRODUCT_KEY) { $issues += "PRODUCT_KEY no limpiada" }
    if ($env:GITEA_BOOTSTRAP_RUNNER_PASSWORD) { $issues += "RUNNER_PASSWORD no limpiada" }
    
    # Verificar configuración de seguridad
    if ((Get-SmbServerConfiguration).EnableSMB1Protocol) { $issues += "SMBv1 habilitado" }
    
    if ($issues.Count -eq 0) {
        Write-Host "✅ Hardening verificado correctamente" -ForegroundColor Green
    } else {
        Write-Host "❌ Issues encontrados:" -ForegroundColor Red
        $issues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    }
}
```

