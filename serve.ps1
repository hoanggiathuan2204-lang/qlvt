param(
  [int]$Port = 8080,
  [string]$ListenHost = "+"
)
# Self-contained static file server using .NET HttpListener
# No Python/Node required. Run:
#   powershell -ExecutionPolicy Bypass -File serve.ps1
#   powershell -ExecutionPolicy Bypass -File serve.ps1 -Port 8080 -ListenHost localhost
$root = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://${ListenHost}:${Port}/")
$listener.Start()
Write-Host "Serving $root at http://${ListenHost}:${Port}/  (Ctrl+C to stop)"

while ($listener.IsListening) {
    try {
        $ctx = $listener.GetContext()
        $req = $ctx.Request
        $resp = $ctx.Response
        $path = $req.Url.AbsolutePath
        if ($path -eq '/' -or $path -eq '') { $path = '/index.html' }
        $rel = $path.TrimStart('/').Replace('/', [System.IO.Path]::DirectorySeparatorChar)
        $file = Join-Path $root $rel
        if ([System.IO.File]::Exists($file)) {
            $bytes = [System.IO.File]::ReadAllBytes($file)
            $ext = [System.IO.Path]::GetExtension($file).ToLower()
            $mime = switch ($ext) {
                '.html' { 'text/html; charset=utf-8' }
                '.js'   { 'application/javascript; charset=utf-8' }
                '.css'  { 'text/css; charset=utf-8' }
                '.json' { 'application/json' }
                '.png'  { 'image/png' }
                '.ico'  { 'image/x-icon' }
                '.svg'  { 'image/svg+xml' }
                '.woff2'{ 'font/woff2' }
                default { 'application/octet-stream' }
            }
            $resp.ContentType = $mime
            $resp.ContentLength64 = $bytes.Length
            $resp.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $resp.StatusCode = 404
            $msg = [System.Text.Encoding]::UTF8.GetBytes('Not found')
            $resp.ContentLength64 = $msg.Length
            $resp.OutputStream.Write($msg, 0, $msg.Length)
        }
    } catch {
        $resp.StatusCode = 500
    } finally {
        $resp.Close()
    }
}
