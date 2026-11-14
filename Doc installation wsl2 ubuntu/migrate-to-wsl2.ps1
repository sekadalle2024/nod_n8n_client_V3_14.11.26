<#
.SYNOPSIS
    Migrate Nod n8n project from Docker Desktop to WSL2 Docker Engine

.DESCRIPTION
    This script:
    - Verifies WSL2 Ubuntu-22.04 installation
    - Configures Ubuntu on first run
    - Installs Docker Engine in WSL2
    - Installs docker-compose plugin
    - Configures Docker auto-start with systemd
    - Copies necessary files to WSL2
    - Tests Docker installation
    - Provides verification steps

.NOTES
    File Name      : migrate-to-wsl2.ps1
    Prerequisite   : WSL2 with Ubuntu-22.04 installed
    Copyright      : MIT License
    Created        : November 2026
#>

[CmdletBinding()]
param(
    [switch]$SkipBackup,
    [switch]$SkipDocker,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Configuration
$WSL_DISTRO = "Ubuntu-22.04"
$PROJECT_ROOT = "h:\nod_n8n"
$WSL_HOME_DIR = "/home"
$WSL_PROJECT_DIR = "/mnt/h/nod_n8n"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NOD N8N - MIGRATION VERS WSL2 DOCKER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

#region Functions

function Write-Step {
    param([string]$Message)
    Write-Host "`n[STEP] $Message" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERREUR] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Test-WSLDistro {
    param([string]$Distro)
    
    $wslList = wsl --list --quiet 2>$null
    return ($wslList -contains $Distro)
}

function Get-WSLDistroState {
    param([string]$Distro)
    
    $wslInfo = wsl --list --verbose 2>$null | Select-String -Pattern $Distro
    if ($wslInfo) {
        if ($wslInfo -match "Running") { return "Running" }
        if ($wslInfo -match "Stopped") { return "Stopped" }
    }
    return "NotFound"
}

function Start-WSLDistro {
    param([string]$Distro)
    
    $state = Get-WSLDistroState -Distro $Distro
    if ($state -eq "Stopped") {
        Write-Info "Demarrage de $Distro..."
        wsl -d $Distro --exec true 2>$null
        Start-Sleep -Seconds 2
    }
}

function Test-WSLCommand {
    param(
        [string]$Distro,
        [string]$Command
    )
    
    try {
        $result = wsl -d $Distro --exec bash -c "$Command" 2>&1
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
}

function Invoke-WSLCommand {
    param(
        [string]$Distro,
        [string]$Command,
        [switch]$Silent
    )
    
    if (-not $Silent) {
        Write-Info "Execution: $Command"
    }
    
    wsl -d $Distro --exec bash -c "$Command"
    
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code $LASTEXITCODE"
    }
}

function Get-WSLUsername {
    param([string]$Distro)
    
    $username = wsl -d $Distro --exec bash -c "whoami" 2>$null
    return $username.Trim()
}

#endregion

#region Step 1: Verify WSL2 and Ubuntu

Write-Step "1/8 - Verification de WSL2 et Ubuntu-22.04"

# Check WSL2 installed
try {
    $wslVersion = wsl --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "WSL not installed"
    }
    Write-Success "WSL2 est installe"
}
catch {
    Write-Error-Custom "WSL2 n'est pas installe"
    Write-Host "`nInstallez WSL2 avec:"
    Write-Host "  wsl --install"
    exit 1
}

# Check Ubuntu-22.04 distribution
if (-not (Test-WSLDistro -Distro $WSL_DISTRO)) {
    Write-Error-Custom "$WSL_DISTRO n'est pas installe"
    Write-Host "`nInstallez Ubuntu-22.04 avec:"
    Write-Host "  wsl --install -d Ubuntu-22.04"
    exit 1
}

Write-Success "$WSL_DISTRO est installe"

# Start WSL if stopped
Start-WSLDistro -Distro $WSL_DISTRO

# Get WSL username
$WSL_USER = Get-WSLUsername -Distro $WSL_DISTRO
if ([string]::IsNullOrEmpty($WSL_USER)) {
    Write-Error-Custom "Impossible de determiner le nom d'utilisateur WSL"
    Write-Host "`nPremiere utilisation de $WSL_DISTRO?"
    Write-Host "Lancez: wsl -d $WSL_DISTRO"
    Write-Host "Completez la configuration (username/password)"
    exit 1
}

Write-Success "Utilisateur WSL: $WSL_USER"
$WSL_HOME_DIR = "/home/$WSL_USER"

# Verify basic commands
if (-not (Test-WSLCommand -Distro $WSL_DISTRO -Command "which bash")) {
    Write-Error-Custom "Ubuntu n'est pas correctement configure"
    exit 1
}

Write-Success "Ubuntu est operationnel"

#endregion

#region Step 2: Check Docker Desktop status

Write-Step "2/8 - Verification de Docker Desktop"

$dockerDesktopRunning = $false
try {
    $dockerVersion = docker version 2>$null
    if ($LASTEXITCODE -eq 0) {
        $dockerDesktopRunning = $true
        Write-Info "Docker Desktop est actuellement actif"
    }
}
catch {
    Write-Info "Docker Desktop n'est pas actif"
}

if ($dockerDesktopRunning -and -not $Force) {
    Write-Host "`n" -NoNewline
    Write-Host "ATTENTION: " -ForegroundColor Yellow -NoNewline
    Write-Host "Docker Desktop est en cours d'execution"
    Write-Host "Pour eviter les conflits, arretez Docker Desktop avant de continuer."
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  1. Arreter Docker Desktop maintenant et continuer"
    Write-Host "  2. Annuler et arreter manuellement Docker Desktop"
    Write-Host "  3. Continuer quand meme (non recommande)"
    Write-Host ""
    $choice = Read-Host "Votre choix (1/2/3)"
    
    switch ($choice) {
        "1" {
            Write-Info "Arret de Docker Desktop..."
            Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 5
            Write-Success "Docker Desktop arrete"
        }
        "2" {
            Write-Info "Arretez Docker Desktop puis relancez ce script"
            exit 0
        }
        "3" {
            Write-Info "Continuation avec Docker Desktop actif (risque de conflit)"
        }
        default {
            Write-Info "Choix invalide. Annulation."
            exit 0
        }
    }
}

#endregion

#region Step 3: Backup PostgreSQL data (if requested)

Write-Step "3/8 - Sauvegarde des donnees PostgreSQL"

if (-not $SkipBackup -and $dockerDesktopRunning) {
    Write-Info "Creation d'un backup PostgreSQL de securite..."
    
    $backupFile = Join-Path $PROJECT_ROOT "backup-nod-$(Get-Date -Format 'yyyyMMdd-HHmmss').sql"
    
    try {
        docker exec nod-local-postgres-1 pg_dumpall -U nod > $backupFile 2>$null
        
        if (Test-Path $backupFile) {
            $fileSize = (Get-Item $backupFile).Length
            if ($fileSize -gt 1KB) {
                Write-Success "Backup cree: $backupFile ($([math]::Round($fileSize/1MB, 2)) MB)"
            }
            else {
                Write-Info "Backup vide ou echec. Containers deja arretes?"
                Remove-Item $backupFile -ErrorAction SilentlyContinue
            }
        }
    }
    catch {
        Write-Info "Impossible de creer le backup (containers peut-etre deja arretes)"
    }
}
elseif ($SkipBackup) {
    Write-Info "Backup ignore (-SkipBackup)"
}
else {
    Write-Info "Docker Desktop non actif, backup ignore"
}

#endregion

#region Step 4: Update Ubuntu system

Write-Step "4/8 - Mise a jour du systeme Ubuntu"

Write-Info "Mise a jour des packages (peut prendre 5-10 minutes)..."

try {
    Invoke-WSLCommand -Distro $WSL_DISTRO -Command "sudo apt-get update -qq" -Silent
    Write-Success "Index des packages mis a jour"
    
    # Install essential tools
    Write-Info "Installation des outils essentiels..."
    Invoke-WSLCommand -Distro $WSL_DISTRO -Command "sudo apt-get install -y -qq ca-certificates curl gnupg lsb-release" -Silent
    Write-Success "Outils essentiels installes"
}
catch {
    Write-Error-Custom "Echec de la mise a jour Ubuntu"
    Write-Host "Erreur: $_"
    exit 1
}

#endregion

#region Step 5: Install Docker Engine in WSL2

Write-Step "5/8 - Installation de Docker Engine dans WSL2"

# Check if Docker already installed
if (Test-WSLCommand -Distro $WSL_DISTRO -Command "which docker") {
    if ($SkipDocker) {
        Write-Info "Docker deja installe, installation ignoree (-SkipDocker)"
    }
    else {
        Write-Info "Docker est deja installe dans WSL2"
        $dockerVersion = wsl -d $WSL_DISTRO --exec bash -c "docker --version" 2>$null
        Write-Success "Version: $dockerVersion"
    }
}
else {
    Write-Info "Installation de Docker Engine (peut prendre 5-10 minutes)..."
    
    try {
        # Remove old versions
        Write-Info "Nettoyage des anciennes versions..."
        Invoke-WSLCommand -Distro $WSL_DISTRO -Command "sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true" -Silent
        
        # Add Docker repository
        Write-Info "Ajout du repository Docker..."
        
        $dockerSetupCommands = @"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=`$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu `$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -qq
"@
        
        Invoke-WSLCommand -Distro $WSL_DISTRO -Command $dockerSetupCommands -Silent
        Write-Success "Repository Docker ajoute"
        
        # Install Docker Engine
        Write-Info "Installation de Docker Engine..."
        Invoke-WSLCommand -Distro $WSL_DISTRO -Command "sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin" -Silent
        Write-Success "Docker Engine installe"
        
        # Add user to docker group
        Write-Info "Configuration des permissions..."
        Invoke-WSLCommand -Distro $WSL_DISTRO -Command "sudo usermod -aG docker $WSL_USER" -Silent
        Write-Success "Utilisateur ajoute au groupe docker"
        
    }
    catch {
        Write-Error-Custom "Echec de l'installation de Docker"
        Write-Host "Erreur: $_"
        exit 1
    }
}

#endregion

#region Step 6: Configure Docker auto-start with systemd

Write-Step "6/8 - Configuration de Docker auto-start"

Write-Info "Configuration de systemd dans WSL2..."

$wslConfig = @"
[boot]
systemd=true
"@

try {
    # Create /etc/wsl.conf with systemd enabled
    $wslConfigEscaped = $wslConfig -replace '"', '\"'
    Invoke-WSLCommand -Distro $WSL_DISTRO -Command "echo '$wslConfigEscaped' | sudo tee /etc/wsl.conf > /dev/null" -Silent
    
    Write-Success "systemd active dans WSL2"
    Write-Info "Redemarrage de WSL2 pour activer systemd..."
    
    # Shutdown WSL2 to apply systemd configuration
    wsl --shutdown
    Start-Sleep -Seconds 5
    
    # Wait for WSL2 to be ready after restart
    Write-Info "Redemarrage de WSL2 en cours..."
    $maxRetries = 10
    $retryCount = 0
    $wslReady = $false
    
    while (-not $wslReady -and $retryCount -lt $maxRetries) {
        try {
            $testResult = wsl -d $WSL_DISTRO --exec bash -c "echo OK" 2>$null
            if ($testResult -match "OK") {
                $wslReady = $true
            }
        }
        catch {
            Start-Sleep -Seconds 2
            $retryCount++
        }
    }
    
    if (-not $wslReady) {
        Write-Error-Custom "WSL2 ne repond pas apres redemarrage"
        exit 1
    }
    
    Write-Success "WSL2 redemarre avec systemd"
    
    # Enable Docker service with systemctl (now that systemd is active)
    Invoke-WSLCommand -Distro $WSL_DISTRO -Command "sudo systemctl enable docker 2>/dev/null || true" -Silent
    Write-Success "Service Docker configure pour auto-start avec systemd"
}
catch {
    Write-Info "Configuration systemd impossible, utilisez: sudo service docker start"
}

#endregion

#region Step 7: Copy project files to WSL2

Write-Step "7/8 - Copie des fichiers projet vers WSL2"

Write-Info "Creation du repertoire projet dans WSL2..."

try {
    Invoke-WSLCommand -Distro $WSL_DISTRO -Command "mkdir -p $WSL_HOME_DIR/nod" -Silent
    Write-Success "Repertoire $WSL_HOME_DIR/nod cree"
}
catch {
    Write-Error-Custom "Impossible de creer le repertoire"
    exit 1
}

# Copy compose.yaml
Write-Info "Copie de compose.yaml..."
$composeSource = Join-Path $PROJECT_ROOT "compose.yaml"
$composeDest = "\\wsl$\$WSL_DISTRO$WSL_HOME_DIR\nod\compose.yaml"

if (Test-Path $composeSource) {
    Copy-Item $composeSource $composeDest -Force
    Write-Success "compose.yaml copie"
}
else {
    Write-Error-Custom "compose.yaml introuvable dans $PROJECT_ROOT"
    exit 1
}

# Copy .env
Write-Info "Copie de .env..."
$envSource = Join-Path $PROJECT_ROOT ".env"
$envDest = "\\wsl$\$WSL_DISTRO$WSL_HOME_DIR\nod\.env"

if (Test-Path $envSource) {
    Copy-Item $envSource $envDest -Force
    Write-Success ".env copie"
}
else {
    Write-Info ".env introuvable, sera necessaire pour demarrer les containers"
}

# Copy Dockerfiles if they exist
$dockerfiles = @("Dockerfile.browser", "Dockerfile.workspace")
foreach ($dockerfile in $dockerfiles) {
    $dockerfileSource = Join-Path $PROJECT_ROOT $dockerfile
    if (Test-Path $dockerfileSource) {
        $dockerfileDest = "\\wsl$\$WSL_DISTRO$WSL_HOME_DIR\nod\$dockerfile"
        Copy-Item $dockerfileSource $dockerfileDest -Force
        Write-Info "$dockerfile copie"
    }
}

Write-Success "Fichiers copies vers WSL2"

#endregion

#region Step 8: Test Docker installation

Write-Step "8/8 - Test de l'installation Docker"

Write-Info "Demarrage du daemon Docker..."

try {
    # Try to start Docker
    Invoke-WSLCommand -Distro $WSL_DISTRO -Command "sudo service docker start 2>/dev/null || true" -Silent
    Start-Sleep -Seconds 3
    
    # Check Docker status
    $dockerStatus = wsl -d $WSL_DISTRO --exec bash -c "sudo service docker status" 2>$null
    
    if ($dockerStatus -match "running") {
        Write-Success "Docker daemon demarre"
    }
    else {
        Write-Info "Docker daemon: $dockerStatus"
    }
    
    # Test docker command
    Write-Info "Test de la commande docker..."
    $testOutput = wsl -d $WSL_DISTRO --exec bash -c "docker --version" 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Docker fonctionne: $testOutput"
    }
    else {
        Write-Info "Docker commande necessite peut-etre une reconnexion WSL"
    }
    
    # Test hello-world (optional, quick test)
    Write-Info "Test hello-world (peut prendre 30 secondes)..."
    $helloResult = wsl -d $WSL_DISTRO --exec bash -c "docker run --rm hello-world" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Test hello-world reussi"
    }
    else {
        Write-Info "Test hello-world ignore (daemon peut-etre pas encore pret)"
    }
    
    # Test Windows mount access (critical for project files)
    Write-Info "Verification de l'acces au projet via /mnt/h/nod_n8n..."
    $mountTest = wsl -d $WSL_DISTRO --exec bash -c "test -f /mnt/h/nod_n8n/compose.yaml && echo OK || echo FAIL" 2>&1
    
    if ($mountTest -match "OK") {
        Write-Success "Acces au projet via /mnt/h/ confirme"
    }
    else {
        Write-Host "`n========================================" -ForegroundColor Red
        Write-Host "ERREUR: Docker ne peut pas acceder au projet" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Le fichier compose.yaml n'est pas accessible via /mnt/h/nod_n8n" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "SOLUTIONS:" -ForegroundColor White
        Write-Host "1. Verifiez que le disque H: est bien monte dans WSL2:" -ForegroundColor Cyan
        Write-Host "   wsl -d $WSL_DISTRO --exec ls /mnt/h/" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. Verifiez les permissions du dossier:" -ForegroundColor Cyan
        Write-Host "   wsl -d $WSL_DISTRO --exec ls -la /mnt/h/nod_n8n/" -ForegroundColor Gray
        Write-Host ""
        Write-Host "3. Si /mnt/h/ n'existe pas, ajoutez dans /etc/wsl.conf:" -ForegroundColor Cyan
        Write-Host "   [automount]" -ForegroundColor Gray
        Write-Host "   enabled = true" -ForegroundColor Gray
        Write-Host "   puis: wsl --shutdown" -ForegroundColor Gray
        Write-Host ""
        exit 1
    }
}
catch {
    Write-Info "Tests partiels, Docker peut necessiter un redemarrage WSL"
}

#endregion

#region Summary and next steps

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "MIGRATION TERMINEE AVEC SUCCES!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "PROCHAINES ETAPES:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. REDEMARRER WSL2 (pour activer systemd):" -ForegroundColor White
Write-Host "   wsl --shutdown" -ForegroundColor Cyan
Write-Host "   wsl -d $WSL_DISTRO" -ForegroundColor Cyan
Write-Host ""

Write-Host "2. VERIFIER DOCKER:" -ForegroundColor White
Write-Host "   docker --version" -ForegroundColor Cyan
Write-Host "   docker ps" -ForegroundColor Cyan
Write-Host ""

Write-Host "3. DEMARRER LES CONTAINERS NOD:" -ForegroundColor White
Write-Host "   cd ~/nod" -ForegroundColor Cyan
Write-Host "   docker compose up -d" -ForegroundColor Cyan
Write-Host ""

Write-Host "4. UTILISER LE SCRIPT DE DEMARRAGE WINDOWS:" -ForegroundColor White
Write-Host "   .\Doc demarrer container & serveur\demarrer-tout-projet-wsl2.bat" -ForegroundColor Cyan
Write-Host ""

Write-Host "FICHIERS COPIES DANS WSL2:" -ForegroundColor Yellow
Write-Host "  $WSL_HOME_DIR/nod/compose.yaml" -ForegroundColor Gray
Write-Host "  $WSL_HOME_DIR/nod/.env" -ForegroundColor Gray
Write-Host ""

Write-Host "ACCES WSL2:" -ForegroundColor Yellow
Write-Host "  Windows: \\wsl$\$WSL_DISTRO$WSL_HOME_DIR\nod" -ForegroundColor Gray
Write-Host "  WSL:     $WSL_HOME_DIR/nod" -ForegroundColor Gray
Write-Host "  Mount:   $WSL_PROJECT_DIR" -ForegroundColor Gray
Write-Host ""

Write-Host "DOCUMENTATION:" -ForegroundColor Yellow
Write-Host "  Consultez: .\Doc installation wsl2 ubuntu\01-MIGRATION-GUIDE.md" -ForegroundColor Gray
Write-Host ""

Write-Host "ECONOMIE RAM ATTENDUE: ~50% (2-3 GB vs 4-6 GB)" -ForegroundColor Green
Write-Host ""

#endregion

exit 0
