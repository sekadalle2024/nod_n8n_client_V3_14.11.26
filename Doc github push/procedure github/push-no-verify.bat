@echo off
REM ====================================================================
REM Script: Push vers GitHub SANS VÉRIFICATION
REM Description: Pousse le code en bypassant le hook lefthook (lint)
REM Utiliser SEULEMENT si le hook bloque à cause d'erreurs non-bloquantes
REM ====================================================================

cd /d "h:\nod_n8n"

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║    PUSH VERS GITHUB (SANS HOOK) - NOD N8N CLIENT V1        ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

echo ⚠️  ATTENTION: Ce script bypasse les vérifications TypeScript
echo ⚠️  Utilisez-le SEULEMENT si vous êtes certain de votre code
echo.

set /p CONFIRM="Êtes-vous sûr de vouloir continuer? (o/n): "

if /i "%CONFIRM%"=="o" (
    echo.
    echo [1/2] Commit des modifications...
    git add .
    git commit -m "Push sans vérification - %date% %time%"
    
    echo.
    echo [2/2] Push vers GitHub (bypass hook)...
    git push -u backup main --no-verify
    
    if %errorlevel% equ 0 (
        echo.
        echo ╔════════════════════════════════════════════════════════════╗
        echo ║                    ✓ PUSH RÉUSSI                          ║
        echo ╚════════════════════════════════════════════════════════════╝
        echo.
        echo Code poussé vers GitHub avec succès (sans vérification)!
    ) else (
        echo.
        echo ╔════════════════════════════════════════════════════════════╗
        echo ║                    ✗ ERREUR PUSH                          ║
        echo ╚════════════════════════════════════════════════════════════╝
    )
) else (
    echo.
    echo Push annulé.
)

echo.
pause
