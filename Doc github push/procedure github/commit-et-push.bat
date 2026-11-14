@echo off
REM ====================================================================
REM Script: Commit ET Push TOUT-EN-UN
REM Description: Commit + Push vers GitHub en une seule commande
REM ====================================================================

cd /d "h:\nod_n8n"

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║      COMMIT ET PUSH VERS GITHUB - TOUT-EN-UN               ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Étape 1: Vérifier l'état
echo [1/4] État actuel...
git status --short
echo.

REM Étape 2: Ajouter les fichiers
echo [2/4] Ajout des fichiers modifiés...
git add .
echo ✓ Fichiers ajoutés
echo.

REM Étape 3: Commit
echo [3/4] Création du commit...
set /p COMMIT_MSG="Message du commit (ou Entrée pour message auto): "

if "%COMMIT_MSG%"=="" (
    set COMMIT_MSG=Sauvegarde nod_n8n - %date% %time%
)

git commit -m "%COMMIT_MSG%"
echo.

REM Étape 4: Push
echo [4/4] Push vers GitHub...
echo.
echo Repository: https://github.com/sekadalle2024/https-github.com-sekadalle2024-nod_n8n_client_V1_13.11.26.git
echo.

git push -u backup main

if %errorlevel% equ 0 (
    echo.
    echo ╔════════════════════════════════════════════════════════════╗
    echo ║              ✓ COMMIT ET PUSH RÉUSSIS                     ║
    echo ╚════════════════════════════════════════════════════════════╝
    echo.
    echo Votre code a été sauvegardé sur GitHub avec succès!
) else (
    echo.
    echo ╔════════════════════════════════════════════════════════════╗
    echo ║                ✗ ERREUR DURANT LE PUSH                    ║
    echo ╚════════════════════════════════════════════════════════════╝
    echo.
    echo Si le hook lefthook bloque, utilisez:
    echo   push-no-verify.bat
)

echo.
pause
