@echo off
REM ====================================================================
REM Script: Push vers Repository V3
REM Description: Premier push vers le nouveau repository V3
REM Repository: https://github.com/sekadalle2024/nod_n8n_client_V3_14.11.26.git
REM ====================================================================

cd /d "h:\nod_n8n"

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║         PUSH VERS REPOSITORY V3 (14.11.26)                 ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Vérifier l'état
echo [1/5] Vérification de l'état du repository...
git status --short
echo.

REM Afficher les remotes
echo [2/5] Remotes configurés:
git remote -v | findstr "v3"
echo.

REM Vérifier s'il y a des modifications à commiter
git diff-index --quiet HEAD --
if %errorlevel% neq 0 (
    echo [3/5] Modifications détectées, création du commit...
    git add .
    git commit -m "feat: Sauvegarde V3 - Procédure GitHub complète + documentation" -m "- Dossier 'Doc github push/procedure github' complet
- 8 fichiers de documentation (50+ pages)
- 7 scripts automatisés
- Mémo des 5 problèmes résolus
- Guide Git complet
- Corrections TypeScript appliquées"
    echo.
) else (
    echo [3/5] Aucune modification à commiter
    echo.
)

REM Afficher les derniers commits
echo [4/5] Derniers commits:
git log -3 --oneline
echo.

REM Confirmer le push
echo [5/5] Push vers GitHub V3...
echo.
echo Repository cible: v3
echo URL: https://github.com/sekadalle2024/nod_n8n_client_V3_14.11.26.git
echo.
echo ⚠️  ATTENTION: C'est le PREMIER push vers ce repository.
echo     Une fenêtre d'authentification GitHub peut s'ouvrir.
echo.
set /p CONFIRM="Voulez-vous continuer le push? (o/n): "

if /i "%CONFIRM%"=="o" (
    echo.
    echo Push en cours (cela peut prendre quelques minutes)...
    echo.
    
    REM Premier push avec --set-upstream
    git push -u v3 main
    
    if %errorlevel% equ 0 (
        echo.
        echo ╔════════════════════════════════════════════════════════════╗
        echo ║                    ✓ PUSH RÉUSSI                          ║
        echo ╚════════════════════════════════════════════════════════════╝
        echo.
        echo Votre code a été poussé vers GitHub V3 avec succès!
        echo.
        echo Repository: https://github.com/sekadalle2024/nod_n8n_client_V3_14.11.26
        echo.
        echo Vérifiez sur GitHub que tout est bien présent.
    ) else (
        echo.
        echo ╔════════════════════════════════════════════════════════════╗
        echo ║                    ✗ ERREUR PUSH                          ║
        echo ╚════════════════════════════════════════════════════════════╝
        echo.
        echo Le push a échoué. Causes possibles:
        echo   • Erreurs TypeScript (hook lefthook)
        echo   • Problème d'authentification GitHub
        echo   • Repository n'existe pas ou permissions insuffisantes
        echo   • Pas de connexion internet
        echo.
        echo Solutions:
        echo   1. Vérifier que le repository existe sur GitHub
        echo   2. Corriger les erreurs TypeScript: pnpm run lint
        echo   3. OU bypasser le hook: git push -u v3 main --no-verify
        echo   4. Vérifier l'authentification: gh auth status
    )
) else (
    echo.
    echo Push annulé.
)

echo.
echo ════════════════════════════════════════════════════════════
echo REMOTES CONFIGURÉS:
echo ════════════════════════════════════════════════════════════
git remote -v
echo.
pause
