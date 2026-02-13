@echo off
REM Script pour tester manuellement les external tasks (Windows)

set BASE_URL=http://localhost:8080/engine-rest

echo ======================================
echo Test Manuel External Task
echo ======================================
echo.

REM 1. Demarrer une instance
echo 1. Demarrage d'une instance de processus...
curl -X POST %BASE_URL%/process-definition/key/ExternalTaskProcess/start -H "Content-Type: application/json" -d "{\"variables\":{\"inputData\":{\"value\":\"Manual Test\",\"type\":\"String\"}}}"
echo.
echo.

REM 2. Attendre
echo 2. Attente (2 secondes)...
timeout /t 2 /nobreak >nul
echo.

REM 3. Lister les external tasks
echo 3. Liste des external tasks disponibles:
curl %BASE_URL%/external-task
echo.
echo.

REM 4. Fetch and Lock
echo 4. Fetch and Lock de la tache...
curl -X POST %BASE_URL%/external-task/fetchAndLock -H "Content-Type: application/json" -d "{\"workerId\":\"manual-worker\",\"maxTasks\":1,\"topics\":[{\"topicName\":\"process-data\",\"lockDuration\":60000}]}" > task.json
type task.json
echo.
echo.

echo IMPORTANT: Copiez l'ID de la tache ci-dessus
echo.

REM 5. Completer la tache (remplacez TASK_ID par l'ID reel)
echo 5. Pour completer la tache, executez:
echo curl -X POST %BASE_URL%/external-task/TASK_ID/complete -H "Content-Type: application/json" -d "{\"workerId\":\"manual-worker\",\"variables\":{\"processedData\":{\"value\":\"MANUALLY PROCESSED\",\"type\":\"String\"},\"status\":{\"value\":\"SUCCESS\",\"type\":\"String\"}}}"
echo.
echo Remplacez TASK_ID par l'ID de la tache
echo.

echo ======================================
echo Test termine!
echo ======================================
pause