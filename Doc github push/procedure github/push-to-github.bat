@echo off
REM ====================================================================
REM Script: Push vers GitHub
REM Description: Pousse le code vers le repository GitHub (backup)
REM Repository: https://github.com/sekadalle2024/https-github.com-sekadalle2024-nod_n8n_client_V1_13.11.26.git
REM ====================================================================

cd /d "h:\nod_n8n"

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║         PUSH VERS GITHUB - NOD N8N CLIENT V1               ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Vérifier l'état
echo [1/4] Vérification de l'état du repository...
git status
echo.

REM Afficher les remotes
echo [2/4] Remotes configurés:
git remote -v
echo.

REM Afficher les derniers commits
echo [3/4] Derniers commits:
git log -3 --oneline
echo.

REM Confirmer le push
echo [4/4] Push vers GitHub...
echo.
echo Repository cible: backup (V1)
echo URL: https://github.com/sekadalle2024/https-github.com-sekadalle2024-nod_n8n_client_V1_13.11.26.git
echo.
echo ATTENTION: Une fenêtre d'authentification GitHub peut s'ouvrir.
echo.
set /p CONFIRM="Voulez-vous continuer le push? (o/n): "

if /i "%CONFIRM%"=="o" (
    echo.
    echo Push en cours...
    git push -u backup main
    
    if %errorlevel% equ 0 (
        echo.
        echo ╔════════════════════════════════════════════════════════════╗
        echo ║                    ✓ PUSH RÉUSSI                          ║
        echo ╚════════════════════════════════════════════════════════════╝
        echo.
        echo Votre code a été poussé vers GitHub avec succès!
        echo URL: https://github.com/sekadalle2024/https-github.com-sekadalle2024-nod_n8n_client_V1_13.11.26
    ) else (
        echo.
        echo ╔════════════════════════════════════════════════════════════╗
        echo ║                    ✗ ERREUR PUSH                          ║
        echo ╚════════════════════════════════════════════════════════════╝
        echo.
        echo Le push a échoué. Causes possibles:
        echo   • Erreurs TypeScript (hook lefthook)
        echo   • Problème d'authentification GitHub
        echo   • Pas de connexion internet
        echo.
        echo Pour bypasser le hook lefthook, utilisez:
        echo   git push -u backup main --no-verify
    )
) else (
    echo.
    echo Push annulé.
)

echo.
pause
