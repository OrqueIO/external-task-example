#!/bin/bash

# Script pour tester manuellement les external tasks
BASE_URL="http://localhost:8080/engine-rest"

echo "======================================"
echo "Test Manuel External Task"
echo "======================================"
echo ""

# 1. Démarrer une instance
echo "1. Démarrage d'une instance de processus..."
START_RESPONSE=$(curl -s -X POST $BASE_URL/process-definition/key/ExternalTaskProcess/start \
  -H "Content-Type: application/json" \
  -d '{"variables":{"inputData":{"value":"Manual Test","type":"String"}}}')

echo "$START_RESPONSE" | json_pp 2>/dev/null || echo "$START_RESPONSE"
INSTANCE_ID=$(echo "$START_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
echo ""
echo "Instance ID: $INSTANCE_ID"
echo ""

# 2. Attendre un peu
echo "2. Attente (2 secondes)..."
sleep 2
echo ""

# 3. Lister les external tasks
echo "3. Liste des external tasks disponibles:"
curl -s "$BASE_URL/external-task" | json_pp 2>/dev/null || curl -s "$BASE_URL/external-task"
echo ""
echo ""

# 4. Fetch and Lock
echo "4. Fetch and Lock de la tâche..."
FETCH_RESPONSE=$(curl -s -X POST $BASE_URL/external-task/fetchAndLock \
  -H "Content-Type: application/json" \
  -d '{
    "workerId": "manual-worker",
    "maxTasks": 1,
    "topics": [
      {
        "topicName": "process-data",
        "lockDuration": 60000
      }
    ]
  }')

echo "$FETCH_RESPONSE" | json_pp 2>/dev/null || echo "$FETCH_RESPONSE"
TASK_ID=$(echo "$FETCH_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
echo ""
echo "Task ID: $TASK_ID"
echo ""

# 5. Compléter la tâche
if [ -n "$TASK_ID" ]; then
  echo "5. Complétion de la tâche $TASK_ID..."
  curl -X POST "$BASE_URL/external-task/$TASK_ID/complete" \
    -H "Content-Type: application/json" \
    -d '{
      "workerId": "manual-worker",
      "variables": {
        "processedData": {
          "value": "MANUALLY PROCESSED DATA",
          "type": "String"
        },
        "status": {
          "value": "SUCCESS",
          "type": "String"
        }
      }
    }'
  echo ""
  echo "Tâche complétée avec succès!"
  echo ""
else
  echo "Erreur: Aucune tâche trouvée ou déjà traitée par le worker automatique"
  echo ""
fi

# 6. Vérifier les variables finales
echo "6. Variables finales de l'instance:"
sleep 2
if [ -n "$INSTANCE_ID" ]; then
  curl -s "$BASE_URL/history/variable-instance?processInstanceId=$INSTANCE_ID" | json_pp 2>/dev/null || curl -s "$BASE_URL/history/variable-instance?processInstanceId=$INSTANCE_ID"
fi
echo ""
echo ""

echo "======================================"
echo "Test terminé!"
echo "======================================"