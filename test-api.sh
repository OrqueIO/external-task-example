#!/bin/bash

# Script de test pour l'API REST OrqueIO
BASE_URL="http://localhost:8080/engine-rest"

echo "======================================"
echo "OrqueIO External Task - API Test"
echo "======================================"
echo ""

# 1. Lister les définitions de processus
echo "1. Liste des processus déployés:"
curl -s $BASE_URL/process-definition | json_pp 2>/dev/null || curl -s $BASE_URL/process-definition
echo ""
echo ""

# 2. Démarrer une instance
echo "2. Démarrage d'une nouvelle instance de processus..."
RESPONSE=$(curl -s -X POST $BASE_URL/process-definition/key/ExternalTaskProcess/start \
  -H "Content-Type: application/json" \
  -d '{"variables":{"inputData":{"value":"Test from API Script","type":"String"}}}')

echo "$RESPONSE" | json_pp 2>/dev/null || echo "$RESPONSE"

# Extraire l'ID de l'instance
INSTANCE_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
echo ""
echo "Instance ID: $INSTANCE_ID"
echo ""

# 3. Attendre que le worker traite la tâche
echo "3. Attente du traitement par le worker (5 secondes)..."
sleep 5
echo ""

# 4. Vérifier l'historique
echo "4. Historique de l'instance:"
if [ -n "$INSTANCE_ID" ]; then
  curl -s "$BASE_URL/history/process-instance/$INSTANCE_ID" | json_pp 2>/dev/null || curl -s "$BASE_URL/history/process-instance/$INSTANCE_ID"
else
  curl -s "$BASE_URL/history/process-instance?finished=true" | json_pp 2>/dev/null || curl -s "$BASE_URL/history/process-instance?finished=true"
fi
echo ""
echo ""

# 5. Obtenir les variables
echo "5. Variables de l'instance:"
if [ -n "$INSTANCE_ID" ]; then
  curl -s "$BASE_URL/history/variable-instance?processInstanceId=$INSTANCE_ID" | json_pp 2>/dev/null || curl -s "$BASE_URL/history/variable-instance?processInstanceId=$INSTANCE_ID"
fi
echo ""
echo ""

echo "======================================"
echo "Test terminé!"
echo "======================================"