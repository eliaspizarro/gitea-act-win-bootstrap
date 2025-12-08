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
    $scriptName = $PSCmdlet.MyInvocation.MyCommand.Name
    
    switch ($Type) {
        'Start' {
            Write-Host "[$timestamp] [INICIO] $scriptName" -ForegroundColor Cyan
        }
        'End' {
            $duration = ''
            if ($StartTime) {
                $elapsed = (Get-Date) - $StartTime
                $duration = " - Duración: $($elapsed.TotalSeconds.ToString('F2'))s"
            }
            $successMsg = if ($Message) { " - $Message" } else { " - Completado exitosamente" }
            Write-Host "[$timestamp] [FIN] $scriptName$successMsg$duration" -ForegroundColor Green
        }
        'Error' {
            $errorMsg = if ($Message) { " - $Message" } else { " - Error durante ejecución" }
            Write-Host "[$timestamp] [ERROR] $scriptName$errorMsg" -ForegroundColor Red
        }
    }
}

# Función para medir tiempo de ejecución
function Start-ScriptTimer {
    return Get-Date
}
