@echo off
REM ====================================================================
REM Script: Installation GitHub CLI (gh)
REM Description: Installe GitHub CLI pour faciliter les opérations Git
REM ====================================================================

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║         INSTALLATION GITHUB CLI (gh)                       ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

echo [1/3] Vérification de GitHub CLI...
where gh >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ GitHub CLI est déjà installé!
    echo.
    gh --version
    echo.
    goto :END
)

echo GitHub CLI n'est pas installé.
echo.

echo [2/3] Installation via winget...
echo (Cela peut prendre 2-3 minutes)
echo.

winget install --id GitHub.cli --silent --accept-package-agreements --accept-source-agreements

if %errorlevel% equ 0 (
    echo.
    echo ╔════════════════════════════════════════════════════════════╗
    echo ║              ✓ INSTALLATION RÉUSSIE                       ║
    echo ╚════════════════════════════════════════════════════════════╝
    echo.
    echo [3/3] Vérification de l'installation...
    
    REM Rafraîchir le PATH
    call refreshenv.cmd 2>nul
    
    where gh >nul 2>&1
    if %errorlevel% equ 0 (
        gh --version
        echo.
        echo Pour vous authentifier avec GitHub:
        echo   gh auth login
    ) else (
        echo.
        echo ⚠ Installation complétée mais 'gh' non trouvé dans le PATH
        echo Fermez et rouvrez votre terminal PowerShell
    )
) else (
    echo.
    echo ╔════════════════════════════════════════════════════════════╗
    echo ║                ✗ ERREUR D'INSTALLATION                    ║
    echo ╚════════════════════════════════════════════════════════════╝
    echo.
    echo Installation manuelle:
    echo 1. Visitez: https://cli.github.com/
    echo 2. Téléchargez l'installeur Windows
    echo 3. Exécutez l'installeur
)

:END
echo.
echo ════════════════════════════════════════════════════════════
echo APRÈS INSTALLATION, utilisez ces commandes:
echo.
echo   gh auth login              - S'authentifier avec GitHub
echo   gh repo view               - Voir les infos du repository
echo   gh pr create               - Créer une Pull Request
echo   gh issue list              - Lister les issues
echo ════════════════════════════════════════════════════════════
echo.
pause
