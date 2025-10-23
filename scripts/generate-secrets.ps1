# GitHub Actions Secrets Generator Script
# Run this in PowerShell to generate all required secrets

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub Actions Secrets Generator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if files exist
# Get the project root (go up 2 levels from scripts folder)
$scriptDir = $PSScriptRoot
$projectRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)

# Alternative: If above doesn't work, use current directory
if (-not (Test-Path (Join-Path $projectRoot ".env"))) {
    $projectRoot = Get-Location
}

Write-Host "Project Root: $projectRoot" -ForegroundColor Magenta
Write-Host ""

$envFile = Join-Path $projectRoot ".env"
$serviceAccountJson = Join-Path $projectRoot "android\asaan-rishta-chat-d848bdbc2a5e.json"
$keystoreFile = Join-Path $projectRoot "android\app\upload-keystore.jks"
$keyProperties = Join-Path $projectRoot "android\key.properties"

Write-Host "Checking files..." -ForegroundColor Yellow
Write-Host ""

# 1. ENV_FILE
if (Test-Path $envFile) {
    Write-Host "✅ Found .env file" -ForegroundColor Green
    Write-Host ""
    Write-Host "SECRET NAME: ENV_FILE" -ForegroundColor Cyan
    Write-Host "SECRET VALUE:" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    Get-Content $envFile
    Write-Host "----------------------------------------"
    Write-Host ""
} else {
    Write-Host "❌ .env file not found at: $envFile" -ForegroundColor Red
    Write-Host ""
}

# 2. PLAY_STORE_SERVICE_ACCOUNT_JSON
if (Test-Path $serviceAccountJson) {
    Write-Host "✅ Found service account JSON" -ForegroundColor Green
    Write-Host ""
    Write-Host "SECRET NAME: PLAY_STORE_SERVICE_ACCOUNT_JSON" -ForegroundColor Cyan
    Write-Host "SECRET VALUE:" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    Get-Content $serviceAccountJson
    Write-Host "----------------------------------------"
    Write-Host ""
} else {
    Write-Host "❌ Service account JSON not found at: $serviceAccountJson" -ForegroundColor Red
    Write-Host ""
}

# 3. UPLOAD_KEYSTORE_BASE64
if (Test-Path $keystoreFile) {
    Write-Host "✅ Found keystore file" -ForegroundColor Green
    Write-Host ""
    Write-Host "SECRET NAME: UPLOAD_KEYSTORE_BASE64" -ForegroundColor Cyan
    Write-Host "SECRET VALUE:" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    $base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($keystoreFile))
    Write-Host $base64
    Write-Host "----------------------------------------"
    Write-Host ""
} else {
    Write-Host "❌ Keystore file not found at: $keystoreFile" -ForegroundColor Red
    Write-Host ""
}

# 4. KEY_PROPERTIES
if (Test-Path $keyProperties) {
    Write-Host "✅ Found key.properties" -ForegroundColor Green
    Write-Host ""
    Write-Host "SECRET NAME: KEY_PROPERTIES" -ForegroundColor Cyan
    Write-Host "SECRET VALUE:" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    Get-Content $keyProperties
    Write-Host "----------------------------------------"
    Write-Host ""
} else {
    Write-Host "❌ key.properties not found at: $keyProperties" -ForegroundColor Red
    Write-Host ""
}

