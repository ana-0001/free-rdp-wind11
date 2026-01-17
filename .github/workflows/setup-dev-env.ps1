
# =========================================================
#  Windows 11 Dev Environment Bootstrap Script
#  Author: BomBa
# =========================================================

$ErrorActionPreference = "Stop"

function Wait-Step($sec = 3) {
    Write-Host "⏳ Waiting $sec seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds $sec
}

function Restart-PowerShell {
    Write-Host "♻ Restarting PowerShell session..." -ForegroundColor Cyan
    Start-Process powershell "-NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# =========================================================
# 1️⃣ Add Arabic (Egypt) Keyboard Layout
# =========================================================
Write-Host "🌍 Adding Arabic (Egypt) keyboard..." -ForegroundColor Green

$LangList = Get-WinUserLanguageList
if (-not ($LangList.LanguageTag -contains "ar-EG")) {
    $LangList.Add("ar-EG")
    Set-WinUserLanguageList $LangList -Force
    Write-Host "✅ Arabic (EG) added successfully"
} else {
    Write-Host "ℹ Arabic (EG) already exists"
}

Wait-Step 4

# =========================================================
# 2️⃣ Install Chocolatey (if missing)
# =========================================================
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "📦 Installing Chocolatey..." -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Wait-Step 5
    Restart-PowerShell
}

# =========================================================
# 3️⃣ Install Browsers & Set Chrome as Default
# =========================================================
Write-Host "🌐 Installing Browsers..." -ForegroundColor Green
choco install googlechrome firefox -y
Wait-Step 5

# Set Chrome as default browser
Start-Process "chrome.exe" "chrome://settings/defaultBrowser"

# =========================================================
# 4️⃣ Git
# =========================================================
Write-Host "🔧 Installing Git..." -ForegroundColor Green
choco install git -y
Wait-Step 3

# =========================================================
# 5️⃣ NVM + Node.js
# =========================================================
Write-Host "🟢 Installing NVM..." -ForegroundColor Green
choco install nvm -y
Wait-Step 2
nvm -v
Wait-Step 4

# =========================================================
# 6️⃣ restart-powershell
# =========================================================
Restart-PowerShell
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell `
      -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
      -Verb RunAs
}

Wait-Step 4

# =========================================================
# 7️⃣ Node.js
# =========================================================
nvm install 20.15.1
nvm use 20.15.1
Wait-Step 2
node -v
Wait-Step 3

# =========================================================
# 8️⃣ Yarn & PNPM
# =========================================================
Write-Host "📦 Installing Yarn & PNPM..." -ForegroundColor Green
npm install -g yarn pnpm
Wait-Step 2
yarn -v
Wait-Step 3

# =========================================================
# 9️⃣ VS Code & Notepad++
# =========================================================
Write-Host "🧑‍💻 Installing Dev Tools..." -ForegroundColor Green
choco install vscode notepadplusplus -y
Wait-Step 3

# - Windsurf
Write-Host "🌊 Checking Windsurf..." -ForegroundColor Cyan
$windsurfPath = "$env:LOCALAPPDATA\Programs\Windsurf\Windsurf.exe"
if (-not (Test-Path $windsurfPath)) {
    Write-Host "📦 Installing Windsurf (latest version)..." -ForegroundColor Green
    winget install --id Codeium.Windsurf -e --silent
    Start-Sleep -Seconds 5
    Write-Host "✅ Windsurf installed successfully."
} else {
    Write-Host "ℹ Windsurf is already installed."
}
Wait-Step 3
# Open Windsurf
Start-Process "$env:LOCALAPPDATA\Programs\Windsurf\Windsurf.exe"
Wait-Step 3


# =========================================================
# 1️⃣0️⃣ Antigravity (CLI tool assumption)
# =========================================================
Write-Host "🚀 Installing Antigravity..." -ForegroundColor Green
choco install antigravity -y -ErrorAction SilentlyContinue
Wait-Step 3

# =========================================================
# 1️⃣1️⃣ Install GitHub Desktop
# =========================================================
Write-Host "🐙 Checking GitHub Desktop..." -ForegroundColor Cyan

$githubDesktopPath = "$env:LOCALAPPDATA\GitHubDesktop\GitHubDesktop.exe"

if (-not (Test-Path $githubDesktopPath)) {
    Write-Host "📦 Installing GitHub Desktop..." -ForegroundColor Green
    winget install --id GitHub.GitHubDesktop -e --silent
    Start-Sleep -Seconds 5
    Write-Host "✅ GitHub Desktop installed successfully."
} else {
    Write-Host "ℹ GitHub Desktop is already installed."
}

# =========================================================
# 1️⃣2️⃣ Install Bruno 3.0.2 (Windows x64)
# =========================================================
Write-Host "🚀 Checking Bruno (API Client)..." -ForegroundColor Cyan

$brunoPath = "$env:LOCALAPPDATA\Programs\Bruno\Bruno.exe"

if (-not (Test-Path $brunoPath)) {
    Write-Host "📦 Installing Bruno (latest version)..." -ForegroundColor Green
    winget install --id Bruno.Bruno -e --silent
    Start-Sleep -Seconds 5
    Write-Host "✅ Bruno installed successfully."
} else {
    Write-Host "ℹ Bruno is already installed."
}
Wait-Step 3
# Open Bruno
# Start-Process "$env:LOCALAPPDATA\Programs\Bruno\Bruno.exe"







# =========================================================
# 1️⃣3️⃣ Install WSL 2 - Full Setup + Docker
# =========================================================

# Ensure Admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell `
      -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
      -Verb RunAs
    exit
}

function Wait-Step($sec = 4) {
    Write-Host "⏳ Waiting $sec seconds..."
    Start-Sleep -Seconds $sec
}

Write-Host "🧠 Installing WSL 2..." -ForegroundColor Green

# Enable required Windows features
$features = @(
    "Microsoft-Windows-Subsystem-Linux",
    "VirtualMachinePlatform"
)

$rebootRequired = $false

foreach ($feature in $features) {
    $state = (Get-WindowsOptionalFeature -Online -FeatureName $feature).State
    if ($state -ne "Enabled") {
        Write-Host "⚙ Enabling: $feature"
        Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart
        $rebootRequired = $true
    }
}

Wait-Step

# Set WSL2 as default
wsl --set-default-version 2 2>$null

# Install Ubuntu if not exists
if (-not (wsl -l -q 2>$null | Select-String "Ubuntu")) {
    Write-Host "📦 Installing Ubuntu..."
    wsl --install -d Ubuntu
    $rebootRequired = $true
}

Wait-Step 5

# Reboot if needed
if ($rebootRequired) {
    Write-Host "🔄 Reboot required to complete WSL installation." -ForegroundColor Yellow
    Start-Sleep 10
    Restart-Computer -Force
}

Write-Host "✅ WSL 2 installation completed successfully!" -ForegroundColor Cyan

Wait-Step 5

# =========================================================
# 1️⃣1️⃣ Docker + Docker Desktop
# =========================================================

Write-Host "🐳 Installing Docker & Docker Desktop..." -ForegroundColor Green

# Enable required Windows features
$features = @(
    "Microsoft-Windows-Subsystem-Linux",
    "VirtualMachinePlatform"
)

foreach ($feature in $features) {
    if ((Get-WindowsOptionalFeature -Online -FeatureName $feature).State -ne "Enabled") {
        Write-Host "⚙ Enabling feature: $feature"
        Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart
    }
}

Wait-Step 5

# Install WSL2 Kernel
Write-Host "🧠 Installing WSL2 Kernel..."
wsl --install -n Ubuntu 2>$null
Wait-Step 5

# Install Docker Desktop
choco install docker-desktop -y
Wait-Step 8

# Start Docker Desktop
Write-Host "🚀 Starting Docker Desktop..."
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Wait for Docker to be ready
Write-Host "⏳ Waiting for Docker Engine..."
$maxRetries = 30
$retry = 0

while ($retry -lt $maxRetries) {
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        docker info > $null 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker is running!"
            break
        }
    }
    Start-Sleep -Seconds 5
    $retry++
}

if ($retry -eq $maxRetries) {
    Write-Host "⚠ Docker did not start in expected time. Please check manually." -ForegroundColor Yellow
}

Write-Host "🐳 Docker installation completed."

Wait-Step 5

Write-Host "🔄 System reboot required to finalize Docker & WSL setup." -ForegroundColor Cyan
Start-Sleep 10
Restart-Computer -Force

# =========================================================
# ✅ Done
# =========================================================
Write-Host ""
Write-Host "🎉 Development environment setup completed successfully!" -ForegroundColor Green
Write-Host "🔁 Please reboot Windows to apply all changes." -ForegroundColor Cyan
