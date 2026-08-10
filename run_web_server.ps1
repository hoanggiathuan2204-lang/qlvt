# Start a lightweight static file server for the pure-web app
# Uses .NET HttpListener (no extra install needed on Windows)
$port = 8080
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Starting server at http://localhost:$port"
Write-Host "Root: $root"
Write-Host "Press Ctrl+C to stop."

# Use Python if available, else try .NET
$py = Get-Command python -ErrorAction SilentlyContinue
if ($py) {
    Push-Location $root
    python -m http.server $port
    Pop-Location
} else {
    # Fallback: npx serve
    Push-Location $root
    npx serve -l $port .
    Pop-Location
}

