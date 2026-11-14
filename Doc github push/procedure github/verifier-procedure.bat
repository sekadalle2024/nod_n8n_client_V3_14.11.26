@echo off
REM ====================================================================
REM Script: Vérification de la Procédure GitHub
REM Description: Vérifie que tous les fichiers et configurations sont OK
REM ====================================================================

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║      VÉRIFICATION PROCÉDURE GITHUB                         ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

cd /d "h:\nod_n8n"

REM 1. Vérifier Git
echo [1/6] Vérification Git...
where git >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Git installé
    git --version
) else (
    echo ✗ Git NON installé
    echo   Installez Git: https://git-scm.com/download/win
)
echo.

REM 2. Vérifier Repository
echo [2/6] Vérification Repository...
if exist ".git" (
    echo ✓ Repository Git initialisé
) else (
    echo ✗ Pas un repository Git
)
echo.

REM 3. Vérifier Remotes
echo [3/6] Vérification Remotes...
git remote -v 2>nul | findstr "backup" >nul
if %errorlevel% equ 0 (
    echo ✓ Remote 'backup' configuré
    git remote get-url backup
) else (
    echo ✗ Remote 'backup' NON configuré
)
echo.

REM 4. Vérifier Scripts
echo [4/6] Vérification Scripts...
set SCRIPT_COUNT=0
if exist "Doc github push\procedure github\commit-et-push.bat" (
    set /a SCRIPT_COUNT+=1
)
if exist "Doc github push\procedure github\commit-changes.bat" (
    set /a SCRIPT_COUNT+=1
)
if exist "Doc github push\procedure github\push-to-github.bat" (
    set /a SCRIPT_COUNT+=1
)
if exist "Doc github push\procedure github\push-no-verify.bat" (
    set /a SCRIPT_COUNT+=1
)
if exist "Doc github push\procedure github\install-github-cli.bat" (
    set /a SCRIPT_COUNT+=1
)
if exist "Doc github push\procedure github\commit-final-session.bat" (
    set /a SCRIPT_COUNT+=1
)
echo ✓ Scripts trouvés: %SCRIPT_COUNT%/6
echo.

REM 5. Vérifier Documentation
echo [5/6] Vérification Documentation...
set DOC_COUNT=0
if exist "Doc github push\procedure github\00-README-AGENTS.md" (
    set /a DOC_COUNT+=1
)
if exist "Doc github push\procedure github\01-MEMO-PROBLEMES-SOLUTIONS.md" (
    set /a DOC_COUNT+=1
)
if exist "Doc github push\procedure github\03-GUIDE-GIT-GITHUB.md" (
    set /a DOC_COUNT+=1
)
if exist "Doc github push\procedure github\QUICK-START.md" (
    set /a DOC_COUNT+=1
)
if exist "Doc github push\procedure github\INDEX.md" (
    set /a DOC_COUNT+=1
)
echo ✓ Documents trouvés: %DOC_COUNT%/5
echo.

REM 6. Vérifier État Git
echo [6/6] État du Repository...
git status --short
if %errorlevel% equ 0 (
    echo.
    echo Derniers commits:
    git log -3 --oneline
) else (
    echo ✗ Erreur lors de la vérification
)
echo.

REM Résumé
echo ════════════════════════════════════════════════════════════
echo RÉSUMÉ
echo ════════════════════════════════════════════════════════════
echo.
if %SCRIPT_COUNT% equ 6 (
    echo ✓ Tous les scripts sont en place
) else (
    echo ⚠ Scripts manquants: %SCRIPT_COUNT%/6
)

if %DOC_COUNT% geq 4 (
    echo ✓ Documentation complète
) else (
    echo ⚠ Documentation incomplète: %DOC_COUNT%/5
)
echo.

echo ════════════════════════════════════════════════════════════
echo PROCHAINES ÉTAPES
echo ════════════════════════════════════════════════════════════
echo.
echo 1. Lisez: Doc github push\procedure github\00-README-AGENTS.md
echo 2. Lisez: Doc github push\procedure github\01-MEMO-PROBLEMES-SOLUTIONS.md
echo 3. Exécutez: commit-et-push.bat (dans PowerShell utilisateur)
echo.

pause
