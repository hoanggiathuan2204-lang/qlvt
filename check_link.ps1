try {
    $r = Invoke-WebRequest -Uri 'http://localhost:8080/' -UseBasicParsing -TimeoutSec 5
    Write-Output ('Status: ' + $r.StatusCode)
    Write-Output ('Length: ' + $r.Content.Length)
    Write-Output ('Contains app.min.js: ' + ($r.Content -match 'app.min.js'))
} catch {
    Write-Output ('ERROR: ' + $_.Exception.Message)
}
