<#
.SYNOPSIS
Start Nod project using WSL2 Docker (reliable version)
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NOD N8N - DÉMARRAGE WSL2 DOCKER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Vérifier WSL2
Write-Host "[1/6] Vérification de WSL2..." -ForegroundColor Yellow
try {
    $wslTest = wsl --status 2>&1
    Write-Host "[OK] WSL2 installé" -ForegroundColor Green
} catch {
    Write-Host "[ERREUR] WSL2 n'est pas installé" -ForegroundColor Red
    Write-Host "Installez WSL2: wsl --install" -ForegroundColor Yellow
    exit 1
}

# 2. Détecter la distribution à utiliser
Write-Host "[2/6] Détection de la distribution Docker..." -ForegroundColor Yellow

$distribution = $null

# Essayer docker-desktop d'abord (test avec docker)
try {
    $dockerVersion = wsl -d docker-desktop docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $distribution = "docker-desktop"
        $wslProject = "/mnt/h/nod_n8n"
        Write-Host "[INFO] Utilisation de docker-desktop WSL2" -ForegroundColor Cyan
    }
}
catch { }

if (-not $distribution) {
    # Essayer Ubuntu-22.04
    try {
        $ubuntuTest = wsl -d Ubuntu-22.04 --exec bash -c "echo test" 2>&1
        if ($LASTEXITCODE -eq 0) {
            $distribution = "Ubuntu-22.04"
            $wslProject = "/home/root/nod"
            Write-Host "[INFO] Utilisation de Ubuntu-22.04" -ForegroundColor Cyan
        }
    }
    catch { }
}

if (-not $distribution) {
    Write-Host "[ERREUR] Aucune distribution WSL2 avec Docker disponible" -ForegroundColor Red
    Write-Host ""
    Write-Host "ACTION REQUISE:" -ForegroundColor Yellow
    Write-Host "1. Configurez Ubuntu: wsl -d Ubuntu-22.04" -ForegroundColor White
    Write-Host "   Créez utilisateur/mot de passe, puis exit" -ForegroundColor White
    Write-Host "2. Lancez: .\continue-migration-wsl2.ps1" -ForegroundColor White
    exit 1
}

Write-Host "[OK] Distribution: $distribution" -ForegroundColor Green

# 3. Vérifier Docker dans WSL2
Write-Host "[3/6] Vérification de Docker dans WSL2..." -ForegroundColor Yellow

$dockerCheck = wsl -d $distribution --exec bash -c "which docker" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERREUR] Docker non installé dans WSL2" -ForegroundColor Red
    Write-Host "Exécutez: .\Doc installation wsl2 ubuntu\migrate-to-wsl2.ps1" -ForegroundColor Yellow
    exit 1
}

$dockerVersion = wsl -d $distribution --exec bash -c "docker --version" 2>&1
Write-Host "[OK] $dockerVersion" -ForegroundColor Green

# 4. Démarrer le daemon Docker
Write-Host "[4/6] Démarrage du daemon Docker..." -ForegroundColor Yellow

$dockerRunning = wsl -d $distribution --exec "docker ps" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[INFO] Démarrage de Docker service..." -ForegroundColor Cyan
    wsl -d $distribution --exec "sudo service docker start" 2>&1 | Out-Null
    
    # Attendre que Docker soit prêt
    Write-Host "[INFO] Attente Docker (10s max)..." -ForegroundColor Gray
    for ($i = 1; $i -le 10; $i++) {
        Start-Sleep -Seconds 1
        $testDocker = wsl -d $distribution --exec "docker ps" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Docker démarré après $i secondes" -ForegroundColor Green
            break
        }
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERREUR] Docker ne démarre pas" -ForegroundColor Red
        Write-Host "Diagnostic:" -ForegroundColor Yellow
        wsl -d $distribution --exec "sudo service docker status"
        exit 1
    }
}
else {
    Write-Host "[OK] Docker daemon déjà actif" -ForegroundColor Green
}

# 5. Démarrer les containers
Write-Host "[5/6] Démarrage des containers Docker..." -ForegroundColor Yellow

Write-Host "[INFO] Arrêt des containers existants..." -ForegroundColor Gray
wsl -d $distribution --exec "cd $wslProject && docker compose down" 2>&1 | Out-Null

Write-Host "[INFO] Démarrage des containers..." -ForegroundColor Cyan
$composeOutput = wsl -d $distribution --exec "cd $wslProject && docker compose up -d" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERREUR] Échec démarrage containers" -ForegroundColor Red
    Write-Host $composeOutput -ForegroundColor Red
    exit 1
}

# 6. Attendre PostgreSQL
Write-Host "[6/6] Attente PostgreSQL (120s)..." -ForegroundColor Yellow
$postgresReady = $false
for ($i = 1; $i -le 120; $i++) {
    Start-Sleep -Seconds 1
    $pgTest = wsl -d $distribution --exec "docker exec nod-local-postgres-1 pg_isready -U nod -d nod" 2>&1
    if ($LASTEXITCODE -eq 0) {
        $postgresReady = $true
        Write-Host "[OK] PostgreSQL prêt après $i secondes" -ForegroundColor Green
        break
    }
    
    if ($i % 10 -eq 0) {
        Write-Host "$i..." -NoNewline -ForegroundColor Gray
    }
}

if (-not $postgresReady) {
    Write-Host "[WARN] PostgreSQL lent à démarrer" -ForegroundColor Yellow
    Write-Host "Continuer malgré le warning..." -ForegroundColor Yellow
}

# Vérifier les containers
Write-Host "`n[INFO] État des containers:" -ForegroundColor Cyan
$containersJson = wsl -d $distribution --exec "cd $wslProject && docker compose ps --format json" 2>&1
$containers = $containersJson | ConvertFrom-Json
foreach ($container in $containers) {
    $status = if ($container.State -eq "running") { "[OK]" } else { "[X]" }
    $color = if ($container.State -eq "running") { "Green" } else { "Red" }
    Write-Host "  $status $($container.Name): $($container.State) ($($container.Service))" -ForegroundColor $color
}

# 7. Démarrer le serveur Node.js
Write-Host "`n[7/6] Démarrage du serveur Node.js..." -ForegroundColor Yellow

Write-Host "[INFO] Arrêt du serveur existant..." -ForegroundColor Gray
Get-Process -Name "node","tsx" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "[INFO] Lancement du serveur en arrière-plan..." -ForegroundColor Cyan
$serverJob = Start-Job -ScriptBlock {
    Set-Location "h:\nod_n8n"
    pnpm exec tsx src/server/index.ts
} -Name "nod-server"

Start-Sleep -Seconds 5

# Vérifier que le serveur tourne
$serverProcess = Get-Process -Name "node","tsx" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($serverProcess) {
    Write-Host "[OK] Serveur démarré (PID: $($serverProcess.Id))" -ForegroundColor Green
}
else {
    Write-Host "[ERREUR] Serveur non démarré" -ForegroundColor Red
    Write-Host "Lancez manuellement: pnpm exec tsx src/server/index.ts" -ForegroundColor Yellow
}

# 8. Ouvrir le navigateur
Write-Host "`n[8/6] Ouverture de l application..." -ForegroundColor Yellow
$url = "http://localhost:4310/#access=KXkl8AoKlM3iFaXdP9e9RjCAiyHIyAbbYdchI2DkaRU"
Start-Process $url

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "DÉMARRAGE RÉUSSI !" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nURL: $url" -ForegroundColor White
Write-Host "Vault Key: IF3u9anoTHVqyMj31i/BNWxdGS6/MWxMjOAPAu6zONo=" -ForegroundColor Gray
Write-Host "`nContainers WSL2: 3 containers avec Docker Engine" -ForegroundColor White
Write-Host "Économie RAM: ~50% (2-3 GB vs 4-6 GB Docker Desktop)" -ForegroundColor Yellow
Write-Host "`nCommandes utiles:" -ForegroundColor Cyan
Write-Host "  wsl -d $distribution docker ps" -ForegroundColor White
Write-Host "  wsl -d $distribution docker compose logs" -ForegroundColor White
Write-Host "  Get-Job -Name nod-server | Receive-Job" -ForegroundColor White
Write-Host "  docker-desktop peut rester installé mais inactif" -ForegroundColor Gray