@echo off
REM ====================================================================
REM Script: Commit des modifications Git
REM Description: Ajoute et commite toutes les modifications locales
REM ====================================================================

cd /d "h:\nod_n8n"

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║         COMMIT DES MODIFICATIONS - NOD N8N                 ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Vérifier l'état actuel
echo [1/3] État actuel du repository...
git status --short
echo.

REM Ajouter tous les fichiers modifiés
echo [2/3] Ajout de tous les fichiers...
git add .
echo ✓ Fichiers ajoutés
echo.

REM Créer le commit avec un message
echo [3/3] Création du commit...
set /p COMMIT_MSG="Entrez le message du commit (ou appuyez sur Entrée pour le message par défaut): "

if "%COMMIT_MSG%"=="" (
    set COMMIT_MSG=Sauvegarde automatique - %date% %time%
)

git commit -m "%COMMIT_MSG%"

if %errorlevel% equ 0 (
    echo.
    echo ╔════════════════════════════════════════════════════════════╗
    echo ║                    ✓ COMMIT RÉUSSI                        ║
    echo ╚════════════════════════════════════════════════════════════╝
    echo.
    git log -1 --oneline
) else (
    echo.
    echo ╔════════════════════════════════════════════════════════════╗
    echo ║                    ✗ ERREUR COMMIT                        ║
    echo ╚════════════════════════════════════════════════════════════╝
    echo.
    echo Vérifiez qu'il y a des modifications à commiter.
)

echo.
pause
