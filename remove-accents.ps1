# Script para eliminar acentos de archivos .ps1 excepto en lineas de comentarios
# Uso: .\remove-accents.ps1 [-DryRun]

param(
    [switch]$DryRun
)

$scriptsDir = "scripts"

# Obtener todos los archivos .ps1
$ps1Files = Get-ChildItem -Path $scriptsDir -Recurse -Filter "*.ps1"

if ($DryRun) {
    Write-Host "=== MODO DRY-RUN: Solo muestra cambios, NO modifica archivos ===" -ForegroundColor Cyan
} else {
    Write-Host "=== MODO DE EJECUCION: Se aplicaran cambios a los archivos ===" -ForegroundColor Red
}

Write-Host "Procesando $($ps1Files.Count) archivos .ps1..." -ForegroundColor Cyan
Write-Host ""

$totalChanges = 0
$filesWithChanges = 0

foreach ($file in $ps1Files) {
    Write-Host "Procesando: $($file.FullName)" -ForegroundColor Yellow
    
    try {
        # Leer el archivo completo
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $lines = $content -split "`r`n"
        $modifiedLines = @()
        $fileChanges = 0
        $changedLines = @()
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            $trimmedLine = $line.TrimStart()
            
            # Si la linea comienza con # (despues de espacios), mantener acentos
            if ($trimmedLine.StartsWith("#")) {
                $modifiedLines += $line
            } else {
                # Eliminar acentos en lineas que no son comentarios usando escapes Unicode
                $originalLine = $line
                $newLine = $line
                $newLine = $newLine -replace '\u00E1', 'a'  # a con tilde
                $newLine = $newLine -replace '\u00E9', 'e'  # e con tilde
                $newLine = $newLine -replace '\u00ED', 'i'  # i con tilde
                $newLine = $newLine -replace '\u00F3', 'o'  # o con tilde
                $newLine = $newLine -replace '\u00FA', 'u'  # u con tilde
                $newLine = $newLine -replace '\u00C1', 'A'  # A con tilde
                $newLine = $newLine -replace '\u00C9', 'E'  # E con tilde
                $newLine = $newLine -replace '\u00CD', 'I'  # I con tilde
                $newLine = $newLine -replace '\u00D3', 'O'  # O con tilde
                $newLine = $newLine -replace '\u00DA', 'U'  # U con tilde
                $newLine = $newLine -replace '\u00F1', 'n'  # n con tilde
                $newLine = $newLine -replace '\u00D1', 'N'  # N con tilde
                
                $modifiedLines += $newLine
                
                if ($originalLine -ne $newLine) {
                    $fileChanges++
                    $totalChanges++
                    $changedLines += @{
                        LineNumber = $i + 1
                        Original = $originalLine
                        Modified = $newLine
                    }
                    
                    if ($DryRun) {
                        $lastChange = $changedLines[-1]
                        Write-Host "    Linea $($lastChange.LineNumber):" -ForegroundColor Gray
                        Write-Host "    - Original: $($lastChange.Original)" -ForegroundColor Red
                        Write-Host "    + Modificado: $($lastChange.Modified)" -ForegroundColor Green
                    }
                }
            }
        }
        
        # Mostrar y aplicar cambios segun el modo
        if ($fileChanges -gt 0) {
            $filesWithChanges++
            
            if ($DryRun) {
                Write-Host "  Se detectaron $fileChanges cambios en: $($file.Name)" -ForegroundColor Red
            } else {
                # Aplicar cambios al archivo
                $newContent = $modifiedLines -join "`r`n"
                Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
                Write-Host "  Archivo actualizado: $($file.Name) ($fileChanges cambios)" -ForegroundColor Green
            }
        } else {
            Write-Host "  Sin cambios en: $($file.Name)" -ForegroundColor Blue
        }
        
    } catch {
        Write-Host "  Error procesando $($file.FullName): $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Archivos analizados: $($ps1Files.Count)" -ForegroundColor White
Write-Host "Archivos con cambios: $filesWithChanges" -ForegroundColor Yellow
Write-Host "Total de lineas modificadas: $totalChanges" -ForegroundColor Yellow
Write-Host ""

if ($DryRun) {
    Write-Host "DRY-RUN completado. Ningun archivo fue modificado." -ForegroundColor Cyan
    Write-Host "Para aplicar los cambios, ejecute sin parametro: .\remove-accents.ps1" -ForegroundColor Cyan
} else {
    Write-Host "Proceso completado. Se aplicaron todos los cambios." -ForegroundColor Green
}
