# cleandir.ps1

param (
    [string]$Path = ".",
    [string[]]$Excluidos = @(".gitignore", ".env", "README.md", "cleandir.ps1","cleandir-utf8.ps1")
)

Write-Host "ðŸ§¹ Limpiando contenido en: $Path"
Write-Host "â— Excluyendo: .git, $($Excluidos -join ', ')" -ForegroundColor Yellow
Write-Host ""

# Normalizar la ruta base
$Path = Resolve-Path -Path $Path

Get-ChildItem -Path $Path -Recurse -Force | Where-Object {
    $_.FullName -notmatch "\\.git($|\\)" -and
    $_.Name -notin $Excluidos
} | ForEach-Object {
    try {
        if ($_.PSIsContainer) {
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
        } else {
            Remove-Item -Path $_.FullName -Force -ErrorAction Stop
        }
        Write-Host "âœ” Eliminado: $($_.FullName)" -ForegroundColor Green
    } catch {
        Write-Warning "âŒ No se pudo eliminar: $($_.FullName) - $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "âœ… Limpieza completada." -ForegroundColor Cyan
