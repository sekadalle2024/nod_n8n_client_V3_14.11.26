@echo off
REM ========================================
REM DEMARRAGE COMPLET DU PROJET NOD (WSL2)
REM ========================================
REM Ce script demarre le projet Nod en utilisant Docker dans WSL2 Ubuntu-22.04
REM au lieu de Docker Desktop, pour reduire la consommation RAM de ~50%%
REM
REM Prerequis:
REM - WSL2 Ubuntu-22.04 installe
REM - Docker Engine installe dans WSL2
REM - Migration effectuee avec migrate-to-wsl2.ps1
REM
REM Auteur: Kiro AI Assistant
REM Date: Novembre 2026
REM ========================================

setlocal enabledelayedexpansion

echo ========================================
echo DEMARRAGE NOD (AVEC WSL2 DOCKER)
echo ========================================
echo.
echo Ce script va demarrer:
echo 1. WSL2 Ubuntu-22.04
echo 2. Docker daemon dans WSL2
echo 3. Les containers Docker (postgres, workspace, browser)
echo 4. Le serveur Node.js (port 4310)
echo.
echo Appuyez sur une touche pour continuer...
pause >nul

REM Configuration
set WSL_DISTRO=Ubuntu-22.04
set PROJECT_ROOT=h:\nod_n8n
set WSL_PROJECT=/mnt/h/nod_n8n

cd /d %PROJECT_ROOT%

REM ========================================
REM ETAPE 1: Verification et demarrage WSL2
REM ========================================
echo.
echo [1/6] Verification de WSL2 Ubuntu-22.04...

REM Verifier si WSL2 est installe
wsl --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERREUR] WSL2 n'est pas installe
    echo.
    echo ACTION REQUISE:
    echo 1. Installez WSL2: wsl --install
    echo 2. Installez Ubuntu: wsl --install -d Ubuntu-22.04
    echo 3. Lancez migrate-to-wsl2.ps1
    echo.
    pause
    exit /b 1
)

REM Verifier si Ubuntu-22.04 ou docker-desktop est disponible
REM Essayer d'abord docker-desktop (par defaut dans WSL2)
wsl --list --quiet 2>nul | findstr /B "docker-desktop" >nul
if !errorlevel! == 0 (
    echo [INFO] Utilisation de docker-desktop WSL2
    set WSL_DISTRO=docker-desktop
    set WSL_PROJECT=/mnt/h/nod_n8n
    goto :wsl_detected
)

REM Essayer Ubuntu-22.04
wsl --list --quiet 2>nul | findstr /B "Ubuntu-22.04" >nul
if !errorlevel! == 0 (
    echo [INFO] Utilisation de Ubuntu-22.04
    set WSL_DISTRO=Ubuntu-22.04
    set WSL_PROJECT=/home/root/nod
    goto :wsl_detected
)

echo.
echo [ERREUR] Aucune distribution WSL2 avec Docker disponible
echo.
echo ACTION REQUISE:
echo 1. Installez Ubuntu: wsl --install -d Ubuntu-22.04
echo 2. Lancez migrate-to-wsl2.ps1
echo.
pause
exit /b 1

:wsl_detected
echo [OK] Distribution WSL2: %WSL_DISTRO%

echo [OK] WSL2 et Ubuntu-22.04 sont installes

REM Verifier l'etat de Ubuntu-22.04
wsl --list --verbose 2>nul | findstr /C:"%WSL_DISTRO%" | findstr /C:"Running" >nul
if errorlevel 1 (
    echo [INFO] Demarrage de Ubuntu-22.04...
    wsl -d %WSL_DISTRO% --exec true 2>nul
    timeout /t 2 /nobreak >nul
    echo [OK] Ubuntu-22.04 demarre
) else (
    echo [OK] Ubuntu-22.04 est deja actif
)

REM ========================================
REM ETAPE 2: Verification et demarrage Docker
REM ========================================
echo.
echo [2/6] Verification du daemon Docker dans WSL2...

REM Verifier si Docker est installe dans WSL2
wsl -d %WSL_DISTRO% --exec bash -c "which docker" >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERREUR] Docker n'est pas installe dans WSL2
    echo.
    echo ACTION REQUISE:
    echo Lancez le script de migration:
    echo   powershell -ExecutionPolicy Bypass -File ".\Doc installation wsl2 ubuntu\migrate-to-wsl2.ps1"
    echo.
    pause
    exit /b 1
)

echo [OK] Docker est installe dans WSL2

REM Verifier si Docker daemon tourne
wsl -d %WSL_DISTRO% --exec bash -c "docker ps" >nul 2>&1
if errorlevel 1 (
    echo [INFO] Demarrage du daemon Docker...
    wsl -d %WSL_DISTRO% --exec sudo service docker start >nul 2>&1
    
    REM Attendre que Docker soit pret (max 10 secondes)
    set /a docker_wait=0
    :wait_docker
    wsl -d %WSL_DISTRO% --exec bash -c "docker ps" >nul 2>&1
    if errorlevel 1 (
        set /a docker_wait+=1
        if !docker_wait! LSS 10 (
            timeout /t 1 /nobreak >nul
            goto wait_docker
        ) else (
            echo.
            echo [ERREUR] Docker daemon ne demarre pas
            echo.
            echo DIAGNOSTIC:
            wsl -d %WSL_DISTRO% --exec sudo service docker status
            echo.
            echo SOLUTIONS:
            echo 1. Verifiez les logs: wsl -d %WSL_DISTRO% sudo journalctl -u docker -n 50
            echo 2. Redemarrez WSL2: wsl --shutdown
            echo 3. Relancez ce script
            echo.
            pause
            exit /b 1
        )
    )
    echo [OK] Docker daemon demarre
) else (
    echo [OK] Docker daemon est deja actif
)

REM Afficher version Docker
for /f "tokens=*" %%i in ('wsl -d %WSL_DISTRO% --exec bash -c "docker --version" 2^>nul') do (
    echo [INFO] %%i
)

REM ========================================
REM ETAPE 3: Demarrage des containers Docker
REM ========================================
echo.
echo [3/6] Demarrage des containers Docker depuis WSL2...

REM Changer vers le repertoire projet dans WSL2 et lancer compose
wsl -d %WSL_DISTRO% --exec bash -c "cd %WSL_PROJECT% && docker compose up -d"

if errorlevel 1 (
    echo.
    echo [ERREUR] Echec du demarrage des containers
    echo.
    echo DIAGNOSTIC:
    wsl -d %WSL_DISTRO% --exec bash -c "cd %WSL_PROJECT% && docker compose logs --tail=20"
    echo.
    echo SOLUTIONS:
    echo 1. Verifiez compose.yaml: wsl -d %WSL_DISTRO% ls -la %WSL_PROJECT%/compose.yaml
    echo 2. Verifiez .env: wsl -d %WSL_DISTRO% ls -la %WSL_PROJECT%/.env
    echo 3. Verifiez les logs: wsl -d %WSL_DISTRO% docker compose -f %WSL_PROJECT%/compose.yaml logs
    echo.
    pause
    exit /b 1
)

echo [OK] Containers demarres
echo.
echo [INFO] Attente de la stabilisation initiale (15 secondes)...
timeout /t 15 /nobreak >nul

REM ========================================
REM ETAPE 4: Verification des containers
REM ========================================
echo.
echo [4/6] Verification des containers...

REM Afficher les containers en cours
echo [INFO] Containers actifs:
wsl -d %WSL_DISTRO% --exec bash -c "docker ps --format 'table {{.Names}}\t{{.Status}}' | grep nod"

REM Compter les containers nod running
for /f %%i in ('wsl -d %WSL_DISTRO% --exec bash -c "docker ps --filter name^=nod --format {{.Names}} | wc -l" 2^>nul') do set CONTAINER_COUNT=%%i

if "%CONTAINER_COUNT%"=="4" (
    echo [OK] 4 containers nod demarres
) else (
    echo [INFO] %CONTAINER_COUNT% containers nod demarres (4 attendus^)
    echo [INFO] Certains containers peuvent encore demarrer...
)

REM ========================================
REM ETAPE 5: Attente PostgreSQL ready
REM ========================================
echo.
echo [5/6] Attente de PostgreSQL (peut prendre jusqu'a 120 secondes avec fsync^)...

REM Detecter le nom du container PostgreSQL
echo [INFO] Detection du container PostgreSQL...
for /f "delims=" %%i in ('wsl -d %WSL_DISTRO% --exec bash -c "docker ps --filter name=postgres --filter name=nod --format {{.Names}} 2>/dev/null | head -n1"') do set POSTGRES_CONTAINER=%%i

if "%POSTGRES_CONTAINER%"=="" (
    echo [ERREUR] Container PostgreSQL introuvable
    echo.
    echo DIAGNOSTIC:
    wsl -d %WSL_DISTRO% --exec bash -c "docker ps -a --filter name=nod"
    echo.
    echo SOLUTIONS:
    echo 1. Verifiez que docker compose up a reussi
    echo 2. Verifiez les logs: wsl -d %WSL_DISTRO% docker compose logs
    echo.
    pause
    exit /b 1
)

echo [INFO] Container PostgreSQL detecte: %POSTGRES_CONTAINER%

REM Attendre que PostgreSQL soit pret (max 120 secondes)
set /a count=0
:wait_postgres
wsl -d %WSL_DISTRO% --exec bash -c "docker exec %POSTGRES_CONTAINER% pg_isready -U nod" >nul 2>&1
if errorlevel 1 (
    set /a count+=1
    if !count! LSS 120 (
        REM Afficher progression tous les 10 secondes
        set /a mod=!count! %% 10
        if !mod!==0 (
            echo [INFO] Attente PostgreSQL... (!count!/120s^)
        )
        timeout /t 1 /nobreak >nul
        goto wait_postgres
    ) else (
        echo.
        echo [ERREUR] PostgreSQL ne repond pas apres 120 secondes
        echo.
        echo DIAGNOSTIC:
        wsl -d %WSL_DISTRO% --exec bash -c "docker logs --tail=30 %POSTGRES_CONTAINER%"
        echo.
        echo SOLUTIONS:
        echo 1. PostgreSQL peut prendre 90-95s avec fsync active
        echo 2. Verifiez les logs complets: wsl -d %WSL_DISTRO% docker logs %POSTGRES_CONTAINER%
        echo 3. Verifiez l'etat: wsl -d %WSL_DISTRO% docker ps -a
        echo.
        pause
        exit /b 1
    )
)

echo [OK] PostgreSQL est pret (apres !count! secondes^)

REM Verifier que les 4 containers sont healthy ou running
wsl -d %WSL_DISTRO% --exec bash -c "docker ps --filter name=nod --format '{{.Names}}: {{.Status}}'"

REM ========================================
REM ETAPE 6: Demarrage du serveur Node.js
REM ========================================
echo.
echo [6/6] Demarrage du serveur Node.js...

REM Verification du fichier .env
if not exist .env (
    echo.
    echo [ERREUR] Fichier .env introuvable dans %PROJECT_ROOT%
    echo.
    echo Le fichier .env doit contenir:
    echo - DATABASE_URL=postgresql://nod:password@localhost:54329/nod
    echo - NOD_VAULT_KEY=...
    echo - GEMINI_API_KEY=... (ou autre model provider^)
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo SYSTEME DEMARRE AVEC SUCCES (WSL2^)!
echo ========================================
echo.
echo INFORMATIONS:
echo - Docker: WSL2 Ubuntu-22.04 (economie RAM ~50%%^)
echo - Containers: 4 (postgres, workspace, browser, workspace-network^)
echo - PostgreSQL: localhost:54329
echo - Serveur: http://localhost:4310
echo.
echo URL d'acces:
echo http://localhost:4310/#access=KXkl8AoKlM3iFaXdP9e9RjCAiyHIyAbbYdchI2DkaRU
echo.
echo Le serveur Node.js va maintenant demarrer...
echo Temps de demarrage estime: 30-60 secondes
echo.
echo IMPORTANT:
echo - NE FERMEZ PAS cette fenetre (le serveur y tourne^)
echo - Pour arreter le serveur: Ctrl+C
echo - Pour arreter les containers: wsl -d %WSL_DISTRO% docker compose -f %WSL_PROJECT%/compose.yaml down
echo - Pour arreter WSL2: wsl --shutdown
echo.
echo COMMANDES WSL2 UTILES:
echo - Voir containers: wsl -d %WSL_DISTRO% docker ps
echo - Logs compose: wsl -d %WSL_DISTRO% docker compose -f %WSL_PROJECT%/compose.yaml logs -f
echo - Entrer dans WSL2: wsl -d %WSL_DISTRO%
echo.
echo ========================================
echo LOGS DU SERVEUR (en temps reel):
echo ========================================
echo.

REM Demarrer le serveur Node.js (depuis Windows, qui accede a PostgreSQL via localhost:54329)
pnpm exec tsx src/server/index.ts

REM Si le serveur s'arrete
echo.
echo ========================================
echo Le serveur s'est arrete
echo ========================================
echo.
echo Les containers Docker continuent de tourner dans WSL2.
echo Pour les arreter: wsl -d %WSL_DISTRO% docker compose -f %WSL_PROJECT%/compose.yaml down
echo.
pause

endlocal
