@echo off
REM ====================================================================
REM Script: Commit Final de Session
REM Description: Commit et push de toute la documentation créée
REM ====================================================================

cd /d "h:\nod_n8n"

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║         COMMIT FINAL - DOCUMENTATION COMPLÈTE              ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

echo [1/4] Fichiers modifiés...
git status --short
echo.

echo [2/4] Ajout de tous les fichiers...
git add .
echo ✓ Fichiers ajoutés
echo.

echo [3/4] Création du commit...
git commit -m "docs: Documentation Git/GitHub complète + récapitulatif session" -m "- Ajout 03-GUIDE-GIT-GITHUB.md (15 pages)
- Ajout install-github-cli.bat
- Mise à jour INDEX-DOCUMENTATION.md
- Ajout RECAPITULATIF-FINAL-SESSION.md
- Script commit-final-session.bat
- Tout prêt pour développement continu"

if %errorlevel% equ 0 (
    echo ✓ Commit créé avec succès
    echo.
    echo Dernier commit:
    git log -1 --oneline
) else (
    echo ⚠ Pas de changements à commiter (déjà fait)
)

echo.
echo [4/4] Push vers GitHub...
set /p DOPUSH="Voulez-vous pousser vers GitHub maintenant? (o/n): "

if /i "%DOPUSH%"=="o" (
    echo.
    echo Push en cours...
    git push -u backup main
    
    if %errorlevel% equ 0 (
        echo.
        echo ╔════════════════════════════════════════════════════════════╗
        echo ║              ✓ COMMIT ET PUSH RÉUSSIS                     ║
        echo ╚════════════════════════════════════════════════════════════╝
        echo.
        echo Votre travail est sauvegardé sur GitHub!
        echo URL: https://github.com/sekadalle2024/https-github.com-sekadalle2024-nod_n8n_client_V1_13.11.26
    ) else (
        echo.
        echo ⚠ Erreur lors du push
        echo Réessayez avec: push-to-github.bat
    )
) else (
    echo.
    echo Push annulé. Utilisez push-to-github.bat plus tard.
)

echo.
echo ════════════════════════════════════════════════════════════
echo SESSION TERMINÉE
echo ════════════════════════════════════════════════════════════
echo.
echo ✓ 5 scripts Git créés
echo ✓ 3 fichiers TypeScript corrigés
echo ✓ 15 pages de documentation Git
echo ✓ Récapitulatif complet généré
echo.
echo Consultez: RECAPITULATIF-FINAL-SESSION.md
echo.
pause
