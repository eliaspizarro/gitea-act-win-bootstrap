# Funciones helper para logging estandarizado de scripts
function Write-ScriptLog {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Start', 'End', 'Error')]
        [string]$Type,
        
        [Parameter(Mandatory=$false)]
        [string]$Message = '',
        
        [Parameter(Mandatory=$false)]
        [DateTime]$StartTime
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $scriptName = 'Unknown'
    $callStack = Get-PSCallStack
    
    # Buscar el primer script .ps1 en la pila de llamadas
    for ($i = 1; $i -lt $callStack.Count; $i++) {
        if ($callStack[$i].ScriptName -and $callStack[$i].ScriptName.EndsWith('.ps1')) {
            $scriptName = Split-Path -Leaf $callStack[$i].ScriptName
            break
        }
    }
    
    switch ($Type) {
        'Start' {
            Write-Host "[$timestamp] [INICIO] $scriptName" -ForegroundColor Cyan
        }
        'End' {
            $duration = ''
            if ($StartTime) {
                $elapsed = (Get-Date) - $StartTime
                $duration = " - Duracion: $($elapsed.TotalSeconds.ToString('F2'))s"
            }
            $successMsg = if ($Message) { " - $Message" } else { " - Completado exitosamente" }
            Write-Host "[$timestamp] [FIN] $scriptName$successMsg$duration" -ForegroundColor Green
        }
        'Error' {
            $errorMsg = if ($Message) { " - $Message" } else { " - Error durante ejecucion" }
            Write-Host "[$timestamp] [ERROR] $scriptName$errorMsg" -ForegroundColor Red
        }
    }
}

# Función para medir tiempo de ejecución
function Start-ScriptTimer {
    return Get-Date
}
