param (
    [string]$RangoIP = "192.169.100.0/24",
    [string]$ArchivoXML = "resultado.xml",
    [string]$ArchivoCSV = "reporte_red.csv"
)

Write-Host "-SCAN- Escaneando la red con escaneo de puertos: $RangoIP..." -ForegroundColor Cyan

# Ejecutar nmap con escaneo de puertos y salida en XML
$nmap = "nmap"
$nmapArgs = "-sS $RangoIP -p 1-1024 -T4 -oX $ArchivoXML"
Start-Process -FilePath $nmap -ArgumentList $nmapArgs -NoNewWindow -Wait

Write-Host "-OK- Escaneo completado. Procesando resultados..." -ForegroundColor Yellow

# Cargar XML
[xml]$xml = Get-Content $ArchivoXML

# Extraer hosts activos
$nmapHosts = $xml.nmaprun.host | Where-Object { $_.status.state -eq "up" }

# Generar reporte
$reporte = foreach ($h in $nmapHosts) {
    $ip = $h.address | Where-Object { $_.addrtype -eq "ipv4" } | Select-Object -ExpandProperty addr
    $mac = $h.address | Where-Object { $_.addrtype -eq "mac" } | Select-Object -ExpandProperty addr
    $vendor = $h.address | Where-Object { $_.addrtype -eq "mac" } | Select-Object -ExpandProperty vendor

    # Obtener puertos abiertos
    $ports = $h.ports.port | Where-Object { $_.state.state -eq "open" } |
        ForEach-Object { "$($_.portid)/$($_.protocol)" }

    $puertos = if ($ports) { $ports -join ", " } else { "Ninguno" }

    [PSCustomObject]@{
        IP      = $ip
        MAC     = $mac
        Vendor  = $vendor
        Puertos = $puertos
    }
}

# Verificar si se encontró algo
if ($reporte.Count -eq 0) {
    Write-Host "-WARNING- No se encontraron dispositivos activos." -ForegroundColor DarkYellow
} else {
    $reporte | Format-Table -AutoSize
    $reporte | Export-Csv -Path $ArchivoCSV -NoTypeInformation -Encoding UTF8
    Write-Host "-FOLDER- Reporte guardado en: $ArchivoCSV" -ForegroundColor Green
}
