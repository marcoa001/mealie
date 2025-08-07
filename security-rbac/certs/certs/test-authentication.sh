#!/bin/bash

echo "🧪 Probando autenticación de usuarios..."

USERS=("mealie-admin" "mealie-developer" "mealie-viewer" "monitoring-admin" "db-operator" "test1")

for user in "${USERS[@]}"; do
    echo "Probando usuario: $user"
    kubectl config use-context "${user}-context"
    
    if kubectl get pods --all-namespaces > /dev/null 2>&1; then
        echo "✅ $user: Autenticación exitosa"
    else
        echo "❌ $user: Error de autenticación"
    fi
done

echo "🏁 Pruebas completadas"
