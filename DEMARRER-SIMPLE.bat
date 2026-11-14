@echo off
REM ========================================
REM DEMARRAGE SIMPLE NOD N8N
REM ========================================
echo.
echo Demarrage des containers Docker...
cd /d h:\nod_n8n
docker compose up -d

echo.
echo Attente PostgreSQL (30 secondes)...
timeout /t 30 /nobreak

echo.
echo Demarrage du serveur Node.js...
start "Nod Server" cmd /k "pnpm exec tsx src/server/index.ts"

echo.
echo Ouverture de l'application...
timeout /t 5 /nobreak
start http://localhost:4310/#access=KXkl8AoKlM3iFaXdP9e9RjCAiyHIyAbbYdchI2DkaRU

echo.
echo ========================================
echo APPLICATION DEMARREE !
echo ========================================
echo.
echo URL: http://localhost:4310
echo Vault Key: IF3u9anoTHVqyMj31i/BNWxdGS6/MWxMjOAPAu6zONo=
echo.
echo Pour arreter:
echo   docker compose down
echo   (fermer la fenetre du serveur)
echo.
pause
