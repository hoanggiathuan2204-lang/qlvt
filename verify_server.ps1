# Verify the static server serves the app correctly
$ErrorActionPreference = 'Stop'
$port = 8081

# Start the .NET server in a background process
$serverPath = 'd:\qlvt-web-pure\serve.ps1'
$proc = Start-Process -FilePath 'powershell' -ArgumentList '-ExecutionPolicy','Bypass','-File',$serverPath -WorkingDirectory 'd:\qlvt-web-pure' -WindowStyle Hidden -PassThru
Start-Sleep -Seconds 3

try {
    $r = Invoke-WebRequest -Uri "http://localhost:$port/" -UseBasicParsing -TimeoutSec 5
    Write-Output ("HTTP " + $r.StatusCode)
    Write-Output ("Length: " + $r.Content.Length)
    Write-Output ("Contains title QLVT: " + $r.Content.Contains('QLVT'))
    Write-Output ("Contains config.js: " + $r.Content.Contains('js/config.js'))
} catch {
    Write-Output ("ERROR: " + $_.Exception.Message)
} finally {
    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    Get-Process -Name powershell -ErrorAction SilentlyContinue | Where-Object { $_.Id -eq $proc.Id } | Stop-Process -Force -ErrorAction SilentlyContinue
}
