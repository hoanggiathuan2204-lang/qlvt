# Deploy the pure web app to gh-pages branch cleanly.
# Creates a fresh temporary git repo so the existing repo state stays untouched.
$ErrorActionPreference = "Stop"

$sourceDir  = "D:\qlvt-web-pure"
$remoteUrl  = "https://github.com/hoanggiathuan2204-lang/qlvt.git"
$tmpDir     = "D:\qlvt\build\gh-pages-deploy"
$baseHref   = "/qlvt/"

if (-not (Test-Path "$sourceDir\index.html")) {
    Write-Error "Source not found at $sourceDir. Check the path."
    exit 1
}

# ── Clean temp dir ─────────────────────────────
if (Test-Path $tmpDir) {
    Remove-Item -Path $tmpDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tmpDir | Out-Null

# ── Copy ONLY the web app output ─────────────
Write-Host "Copying $sourceDir to $tmpDir..." -ForegroundColor Cyan
Copy-Item -Path "$sourceDir\*" -Destination $tmpDir -Recurse -Force

# Ensure .nojekyll so GitHub Pages doesn't run Jekyll
Set-Content -Path "$tmpDir\.nojekyll" -Value ""

# ── Init fresh git repo ────────────────────────
Set-Location $tmpDir
git init -b gh-pages 2>$null
git config user.name "Developer"
git config user.email "dev@example.com"
git add -A
git commit -m "Deploy pure web app to gh-pages"
git remote add origin $remoteUrl 2>$null
git remote set-url origin $remoteUrl

Write-Host "Pushing to origin/gh-pages (force)..." -ForegroundColor Cyan
git push origin gh-pages --force

Write-Host "Done! Clearing temp dir..." -ForegroundColor Green
Set-Location $sourceDir
Remove-Item -Path $tmpDir -Recurse -Force
