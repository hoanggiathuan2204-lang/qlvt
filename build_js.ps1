# =====================================================================
# Build script: gộp tất cả JS trong js/ thành dist/app.min.js
# Chạy lại khi có thay đổi mã JS trong thư mục js/.
# Không cần node/npm/python - dùng PowerShell thuần.
#
# AN TOÀN: chỉ bỏ dòng comment // ở đầu dòng và trim khoảng trắng thừa.
# KHÔNG đụng vào /* */ hay nội dung bên trong chuỗi để tránh hỏng code.
# =====================================================================
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$jsRoot = Join-Path $root 'js'
$viewsRoot = Join-Path $jsRoot 'views'
$distDir = Join-Path $root 'dist'
$outFile = Join-Path $distDir 'app.min.js'

if (-not (Test-Path $distDir)) { New-Item -ItemType Directory -Path $distDir | Out-Null }

# Thứ tự load phải giữ đúng thứ tự phụ thuộc:
$files = @(
  (Join-Path $jsRoot 'config.js'),
  (Join-Path $jsRoot 'firebase.js'),
  (Join-Path $jsRoot 'store.js'),
  (Join-Path $jsRoot 'auth.js'),
  (Join-Path $jsRoot 'ui.js'),
  (Join-Path $jsRoot 'app.js'),
  (Join-Path $viewsRoot 'login.js'),
  (Join-Path $viewsRoot 'dashboard.js'),
  (Join-Path $viewsRoot 'materials.js'),
  (Join-Path $viewsRoot 'suppliers.js'),
  (Join-Path $viewsRoot 'products.js'),
  (Join-Path $viewsRoot 'deliveries.js'),
  (Join-Path $viewsRoot 'reports.js'),
  (Join-Path $viewsRoot 'notifications.js')
)

$sb = New-Object System.Text.StringBuilder
foreach ($f in $files) {
  if (Test-Path $f) {
    [void]$sb.AppendLine("// ===================== $([System.IO.Path]::GetFileName($f)) =====================")
    $lines = Get-Content -Encoding UTF8 $f
    foreach ($line in $lines) {
      $t = $line.Trim()
      # Bỏ dòng trống hoàn toàn
      if ($t -eq '') { continue }
      # Bỏ dòng comment // (chỉ khi dòng đó là comment thuần tuý)
      if ($t.StartsWith('//')) { continue }
      # Giữ nguyên nội dung, chỉ bỏ khoảng trắng thừa 2 đầu
      [void]$sb.AppendLine($line.Trim())
    }
    [void]$sb.AppendLine('')
  }
}

$minified = $sb.ToString()
[System.IO.File]::WriteAllText($outFile, $minified, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "BUILT -> $outFile  ($([math]::Round((Get-Item $outFile).Length/1KB,1)) KB)"
