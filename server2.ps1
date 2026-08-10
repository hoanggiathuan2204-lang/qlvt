Add-Type -AssemblyName System.Net.HttpListener

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8081/")
$listener.Start()
Write-Host "Server running at http://localhost:8081/"

Start-Process "C:\Program Files\Google\Chrome\Application\chrome.exe" "http://localhost:8081/"

$basePath = "D:\qlvt-web-pure"

while ($true) {
    try {
        $ctx = $listener.GetContext()
        $path = $ctx.Request.Url.LocalPath
        if ($path -eq "/") { $path = "/index.html" }
        
        $filePath = Join-Path $basePath $path.TrimStart("/")
        if (-not (Test-Path $filePath)) { $filePath = Join-Path $basePath "index.html" }
        
        $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
        $contentType = switch ($ext) {
            ".html" { "text/html" }
            ".js" { "application/javascript" }
            ".css" { "text/css" }
            ".json" { "application/json" }
            ".png" { "image/png" }
            ".jpg" { "image/jpeg" }
            ".svg" { "image/svg+xml" }
            ".woff" { "font/woff" }
            ".woff2" { "font/woff2" }
            default { "application/octet-stream" }
        }
        
        $content = Get-Content $filePath -Raw -Encoding Byte
        
        $ctx.Response.ContentType = $contentType
        $ctx.Response.ContentLength64 = $content.Length
        $ctx.Response.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        $ctx.Response.Headers.Add("Pragma", "no-cache")
        $ctx.Response.Headers.Add("Expires", "0")
        $ctx.Response.OutputStream.Write($content, 0, $content.Length)
        $ctx.Response.Close()
    } catch {
        Write-Host "Error: $_"
    }
}
