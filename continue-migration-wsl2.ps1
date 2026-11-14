<#
.SYNOPSIS
Continue WSL2 migration after Ubuntu configuration
#>

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "SUITE MIGRATION WSL2 (après configuration Ubuntu)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Vérifier que Ubuntu est configuré
Write-Host "`n[1/4] Vérification d'Ubuntu-22.04..." -ForegroundColor Yellow
$ubuntuTest = wsl -d Ubuntu-22.04 --exec "echo 'Ubuntu configured' && whoami" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERREUR] Ubuntu non configuré ou inaccessible" -ForegroundColor Red
    Write-Host "Exécutez d'abord: wsl -d Ubuntu-22.04" -ForegroundColor Yellow
    Write-Host "Créez un utilisateur et mot de passe, puis exit" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Ubuntu configuré - Utilisateur: $ubuntuTest" -ForegroundColor Green

# 2. Terminer l'installation Docker dans WSL2
Write-Host "`n[2/4] Installation Docker dans WSL2..." -ForegroundColor Yellow
wsl -d Ubuntu-22.04 --exec bash -c @'
# Mettre à jour les packages
echo "Mise à jour des packages..."
apt update && apt upgrade -y

# Installer Docker
echo "Installation de Docker..."
apt install -y docker.io docker-compose

# Ajouter l'utilisateur au groupe docker
echo "Configuration des permissions Docker..."
usermod -aG docker $USER

# Configurer systemd pour WSL2
echo "Configuration systemd..."
if [ ! -f /etc/wsl.conf ]; then
    echo "[boot]" > /etc/wsl.conf
    echo "systemd=true" >> /etc/wsl.conf
fi

echo "Redémarrage nécessaire pour systemd..."
'@

Write-Host "[OK] Docker installé dans WSL2" -ForegroundColor Green

# 3. Redémarrer WSL2
Write-Host "`n[3/4] Redémarrage WSL2..." -ForegroundColor Yellow
wsl --shutdown
Start-Sleep -Seconds 5
wsl -d Ubuntu-22.04 --exec "echo 'WSL2 redémarré' && docker --version"

# 4. Tester le démarrage avec WSL2
Write-Host "`n[4/4] Test du script de démarrage WSL2..." -ForegroundColor Yellow
cd "h:\nod_n8n\Doc demarrer container & serveur"
.\demarrer-tout-projet-wsl2.bat

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "MIGRATION COMPLÈTE !" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "`nProchaines étapes :"
Write-Host "1. Vérifiez l'état des containers : docker ps"
Write-Host "2. Lancez le serveur : pnpm exec tsx src/server/index.ts"
Write-Host "3. Ouvrez : http://localhost:4310/#access=KXkl8AoKlM3iFaXdP9e9RjCAiyHIyAbbYdchI2DkaRU"
Write-Host "`nÉconomie RAM attendue : ~50% (2-3 GB vs 4-6 GB)" -ForegroundColor Yellow