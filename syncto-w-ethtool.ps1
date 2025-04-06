# sync-to-w-ethtool.ps1

# 1. Ruta a los repos
$origin = "." 
$dest   = "..\w-ethtool"

# 2. Cambiar a rama w-ethtool
Set-Location $origin
git checkout w-ethtool
git pull

# 3. Copiar archivos (sin .git)
robocopy $origin $dest /MIR /XD ".git" /NFL /NDL /NJH /NJS /NC /NS /NP

# Confirmar en consola
Write-Host "-OK- Archivos sincronizados con /MIR (mirror exacto)"

# 4. Subir cambios
Set-Location $dest
git add .
git commit -m "Sincronización desde prj-network"
git push

#5. Volver a la rama de trabajo
