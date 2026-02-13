@echo off
REM Script de test pour l'API REST OrqueIO (Windows)

set BASE_URL=http://localhost:8080/engine-rest

echo ======================================
echo OrqueIO External Task - API Test
echo ======================================
echo.

echo 1. Liste des processus deployes:
curl -s %BASE_URL%/process-definition
echo.
echo.

echo 2. Demarrage d'une nouvelle instance de processus...
curl -X POST %BASE_URL%/process-definition/key/ExternalTaskProcess/start -H "Content-Type: application/json" -d "{\"variables\":{\"inputData\":{\"value\":\"Test from Windows\",\"type\":\"String\"}}}"
echo.
echo.

echo 3. Attente du traitement (5 secondes)...
timeout /t 5 /nobreak >nul
echo.

echo 4. Historique des instances:
curl -s "%BASE_URL%/history/process-instance?finished=true"
echo.
echo.

echo 5. Variables historiques:
curl -s %BASE_URL%/history/variable-instance
echo.
echo.

echo ======================================
echo Test termine!
echo ======================================
pause