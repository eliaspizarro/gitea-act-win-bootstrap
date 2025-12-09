# Overview

Este repositorio automatiza el bootstrap de un runner de Gitea `act_runner` en Windows (Server Core / Windows 10/11/Server) de forma 100% headless y **100% desatendida**, usando PowerShell y Chocolatey.

## Características Principales
- **Ejecución completamente desatendida**: Todos los 42 scripts soportan variables de entorno sin entradas interactivas
- **Configuración centralizada**: Sistema de variables de entorno con patrón `GITEA_BOOTSTRAP_*`
- **Validación automática**: Script de validación con auditoría completa de scripts
- **Documentación completa**: Referencia completa de 30+ variables de entorno

## Objetivos
- Preparar el sistema para CI (energía, hibernación, rutas largas, timezone, pagefile, temp, features).
- Instalar toolchain de build (Chocolatey, 7-Zip CLI, .NET SDK LTS, Node.js v24, Git, VS Build Tools, Windows SDK).
- Instalar y configurar `act_runner` con registro automático y script de inicio.
- Registrar inicio automático mediante Tarea Programada.
- **Proporcionar ejecución 100% desatendida**

## Prerrequisitos
- Ejecutar PowerShell como Administrador para pasos de sistema.
- Conectividad a `community.chocolatey.org` y fuentes de Microsoft/Gitea.
- Clave de activación (opcional), y URL/token de Gitea (necesarios para el runner).

## Orden recomendado de ejecución
1. **Configurar variables**: `Copy-Item configs\set-env.sample.ps1 configs\set-env.ps1` y editar valores
2. **Validar configuración**: `.\scripts\00-bootstrap\000-validate-environment.ps1`
3. scripts/00-bootstrap/*
4. scripts/10-os-config/* (incluye 115 rutas largas y 170 activación opcional)
5. scripts/40-system-tools/*
6. scripts/50-build-toolchain/*
7. scripts/20-users-and-permissions/*
8. scripts/30-security-hardening/* (opcional según políticas)
9. scripts/60-gitea-act-runner/*
10. scripts/70-maintenance/* (según necesidad)

## Flujo desatendido
1) **Configurar variables**: Copiar y editar `configs/set-env.sample.ps1`
2) **Validar**: Ejecutar script de validación para verificar configuración
3) **Bootstrap y config**: Ejecutar scripts del sistema sin parámetros interactivos
4) **Instalar herramientas**: Instalación vía Chocolatey completamente desatendida
5) **Configurar runner**: Registrar runner y crear tarea programada automáticamente

## Variables de entorno

### Variables Requeridas
- `GITEA_SERVER_URL`: URL completa del servidor Gitea
- `GITEA_RUNNER_TOKEN`: token del runner generado en Gitea
- `RUNNER_NAME`: nombre único del runner
- `GITEA_BOOTSTRAP_USER`: nombre de usuario local para el runner
- `GITEA_BOOTSTRAP_RUNNER_PASSWORD`: contraseña del usuario del runner

### Variables de Bootstrap (GITEA_BOOTSTRAP_*)
- `GITEA_BOOTSTRAP_TIMEZONE`: zona horaria del sistema
- `GITEA_BOOTSTRAP_TEMP_DIR`: directorio temporal personalizado
- `GITEA_BOOTSTRAP_INSTALL_DIR`: directorio base para herramientas
- `GITEA_BOOTSTRAP_PRODUCT_KEY`: clave de producto Windows
- Y 25+

### Variables del Runner (sin prefijo)
- `RUNNER_LABELS`: etiquetas separadas por coma
- `RUNNER_WORKDIR`: directorio de trabajo del runner

Se establecen con `configs/set-env.sample.ps1` y se consumen en todos los scripts para ejecución desatendida.

## Rutas e instaladores
- `C:\Tools\gitea-act-runner`: binarios y config del runner.
- `C:\Logs\ActRunner`: logs de ejecución.
- Instalación de herramientas exclusivamente en modo CLI (sin GUI).

## Validación y Auditoría
- **Script de validación**: `scripts/00-bootstrap/000-validate-environment.ps1`
- **Auditoría de scripts**: Verifica que todos los scripts sean compatibles desatendidos
- **Resultado**: 42/42 scripts compatibles (100%)

## Documentación
- `docs/ENVIRONMENT_VARIABLES.md`: Guía completa de variables de entorno
- Ejemplos de uso y patrones de implementación
- Guía de seguridad para variables sensibles
