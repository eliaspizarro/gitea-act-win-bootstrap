# Activación y Limitaciones

## Formas de activación admitidas
- KMS (recomendado en entornos corporativos).
- MAK (clave por equipo). Nunca almacenes la clave en el repositorio.
- Retail (clave de venta individual). Formato: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX

## ✅ Activación Desatendida (Modo Automático)

### Usando Variables de Entorno
El script ahora soporta **activación completamente desatendida** usando variables de entorno:

```powershell
# Configurar variable de entorno
$env:GITEA_BOOTSTRAP_PRODUCT_KEY = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"

# Ejecutar activación desatendida
powershell -File scripts/10-os-config/170-windows-activation.ps1
```

### Variables de Entorno Disponibles
- `GITEA_BOOTSTRAP_PRODUCT_KEY`: Clave de producto (KMS/MAK/Retail)
- `GITEA_BOOTSTRAP_CHECK_ONLY`: `true` para solo verificar estado, `false` para activar

### Configuración Centralizada
Las variables se configuran en `configs/set-env.sample.ps1`:

```powershell
GITEA_BOOTSTRAP_CHECK_ONLY = 'false'
GITEA_BOOTSTRAP_PRODUCT_KEY = '${WINDOWS_PRODUCT_KEY}'
```

## Script de activación
- **Modo desatendido (recomendado)**:
  - Configurar variables de entorno primero
  - `powershell -File scripts/10-os-config/170-windows-activation.ps1`
- **Ver estado**:
  - `powershell -File scripts/10-os-config/170-windows-activation.ps1 -CheckOnly`
- **Activar con clave manual** (solo para testing):
  - `powershell -File scripts/10-os-config/170-windows-activation.ps1 -ProductKey (Read-Host 'Key' -AsSecureString)`

Notas del script:
- Usa `slmgr.vbs /dli`, `/ipk`, `/ato`.
- Compatible con claves KMS, MAK y Retail.
- En modo desatendido, lee la clave de `GITEA_BOOTSTRAP_PRODUCT_KEY`.
- La clave se recibe como `SecureString` en modo manual. Evita registrar la clave en logs o variables de texto plano.

## Seguridad de la clave
- No comitees claves ni tokens.
- Usa variables de entorno seguras o un almacén secreto (ej. kv/vault) para inyección temporal.
- Las claves retail deben protegerse igual que las claves MAK.
- **Modo desatendido**: La clave se almacena temporalmente como variable de entorno, limpiar después del bootstrap:
```powershell
Remove-Item Env:GITEA_BOOTSTRAP_PRODUCT_KEY
[Environment]::SetEnvironmentVariable("GITEA_BOOTSTRAP_PRODUCT_KEY", $null, "Machine")
```

## Limitaciones conocidas
- Windows Core/Server Core: sin GUI; todo debe ejecutarse en PowerShell/CLI.
- Ediciones de evaluación expiran; `-CheckOnly` ayuda a monitorear el estado.
- Activación requiere conectividad (para KMS/MAK/Retail online); en entornos aislados, considera activación offline.
- **Modo desatendido**: Requiere configuración previa de variables de entorno.

## Recomendaciones
- **Producción**: Usar siempre modo desatendido con variables de entorno.
- Automatiza `-CheckOnly` en mantenimiento para alertas tempranas.
- Documenta el origen de la clave (KMS/MAK/Retail) y ventanas de renovación.
- Para claves retail, guarda el respaldo físico/digital seguro fuera del repositorio.
- **Validación**: Ejecuta `.\scripts\00-bootstrap\000-validate-environment.ps1` para verificar configuración antes del bootstrap.

## Flujo de Activación Desatendida
1. **Configurar**: Editar `configs/set-env.ps1` con la clave de producto
2. **Validar**: Ejecutar script de validación
3. **Ejecutar**: `.\scripts\10-os-config\170-windows-activation.ps1`
4. **Verificar**: El script activará automáticamente sin intervención manual

