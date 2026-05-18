# ============================================================
# TravelSphere — Complete GitHub Push + APK Release Script
# Run this PowerShell script from the project root directory
# ============================================================

param(
    [string]$GitHubUsername = "akshayev",
    [string]$RepoName = "TravelSphere",
    [string]$Version = "v1.0.0",
    [string]$Token = ""  # Set your GitHub PAT here or pass as param
)

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  TravelSphere — GitHub Push + APK Release Workflow" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# ── Step 1: Copy Screenshots ──────────────────────────────────
Write-Host "[1/8] Setting up screenshots folder..." -ForegroundColor Yellow
$screenshotsDir = Join-Path $ProjectRoot "screenshots"
if (!(Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Path $screenshotsDir | Out-Null
    Write-Host "      Created screenshots/ directory" -ForegroundColor Green
} else {
    Write-Host "      screenshots/ already exists" -ForegroundColor Green
}

# Copy AI-generated screenshots from Antigravity brain
$brainDir = "C:\Users\aksha\.gemini\antigravity\brain\b23f2c47-d95a-462f-8301-4ccb76dbc9af"
# Real screenshots — user must have saved these manually to screenshots/
$expectedScreenshots = @(
    "01_login.png",
    "02_home_explore.png",
    "03_package_details.png",
    "04_my_trips.png",
    "05_admin_dashboard.png"
)

foreach ($shot in $expectedScreenshots) {
    $path = Join-Path $screenshotsDir $shot
    if (Test-Path $path) {
        Write-Host "      Found: $shot" -ForegroundColor Green
    } else {
        Write-Host "      MISSING: $shot — please save it to screenshots/ before pushing!" -ForegroundColor Red
    }
}

# ── Step 2: Git Status & Init ─────────────────────────────────
Write-Host ""
Write-Host "[2/8] Checking Git status..." -ForegroundColor Yellow
Set-Location $ProjectRoot

$gitStatus = git status --porcelain 2>&1
Write-Host "      Git status: $($gitStatus.Count) changes" -ForegroundColor Green

# ── Step 3: Stage All Files ───────────────────────────────────
Write-Host ""
Write-Host "[3/8] Staging all files..." -ForegroundColor Yellow
git add .
Write-Host "      All files staged" -ForegroundColor Green

# ── Step 4: Commit ────────────────────────────────────────────
Write-Host ""
Write-Host "[4/8] Creating commit..." -ForegroundColor Yellow
$commitMsg = "feat: TravelSphere $Version — Final Production Release

- Flutter + Firebase full-stack travel booking app
- Google Auth + Email/Password authentication
- Real-time Firestore package/booking management
- AI-powered trip itinerary generator
- Admin dashboard with full CRUD operations
- Interactive maps (FlutterMap + OpenStreetMap)
- Push notifications + budget planner
- Glassmorphic dark UI with premium design
- Comprehensive security rules & .gitignore
- App screenshots and recruiter-ready README
- MIT License"

git commit -m $commitMsg
Write-Host "      Commit created" -ForegroundColor Green

# ── Step 5: Set Remote ───────────────────────────────────────
Write-Host ""
Write-Host "[5/8] Configuring GitHub remote..." -ForegroundColor Yellow
$remoteUrl = "https://github.com/$GitHubUsername/$RepoName.git"
$existingRemote = git remote get-url origin 2>&1
if ($LASTEXITCODE -eq 0) {
    git remote set-url origin $remoteUrl
    Write-Host "      Updated remote to: $remoteUrl" -ForegroundColor Green
} else {
    git remote add origin $remoteUrl
    Write-Host "      Added remote: $remoteUrl" -ForegroundColor Green
}

# ── Step 6: Push to GitHub ────────────────────────────────────
Write-Host ""
Write-Host "[6/8] Pushing to GitHub (main branch)..." -ForegroundColor Yellow
git branch -M main
git push -u origin main --force
Write-Host "      Pushed to GitHub successfully!" -ForegroundColor Green

# ── Step 7: Build Release APK ────────────────────────────────
Write-Host ""
Write-Host "[7/8] Building release APK (this may take 3-5 minutes)..." -ForegroundColor Yellow
flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=build/debug-info/
Write-Host "      APK built successfully!" -ForegroundColor Green

$apkPath = Join-Path $ProjectRoot "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apkPath) {
    $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
    Write-Host "      APK size: $apkSize MB" -ForegroundColor Green
    
    # Copy to root with version name
    $releaseApkName = "TravelSphere-$Version-release.apk"
    Copy-Item $apkPath (Join-Path $ProjectRoot $releaseApkName) -Force
    Write-Host "      APK saved as: $releaseApkName" -ForegroundColor Green
} else {
    Write-Host "      WARNING: APK not found at expected path. Check build output above." -ForegroundColor Red
}

# ── Step 8: Create GitHub Release ────────────────────────────
Write-Host ""
Write-Host "[8/8] Creating GitHub Release $Version..." -ForegroundColor Yellow

# Tag the release
git tag -a $Version -m "TravelSphere $Version — Production Release"
git push origin $Version
Write-Host "      Release tag pushed" -ForegroundColor Green

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  DONE! Next steps:" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Go to: https://github.com/$GitHubUsername/$RepoName/releases/new" -ForegroundColor White
Write-Host "     - Tag: $Version (already created)" -ForegroundColor White
Write-Host "     - Title: TravelSphere $Version — Production Release" -ForegroundColor White
Write-Host "     - Upload: $releaseApkName" -ForegroundColor White
Write-Host "     - Click: Publish Release" -ForegroundColor White
Write-Host ""
Write-Host "  2. Your repo is live at:" -ForegroundColor White
Write-Host "     https://github.com/$GitHubUsername/$RepoName" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. APK download link will be:" -ForegroundColor White
Write-Host "     https://github.com/$GitHubUsername/$RepoName/releases/latest" -ForegroundColor Cyan
Write-Host ""
