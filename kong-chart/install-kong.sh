#!/bin/bash

set -e

echo "Instalando Kong ..."

# Verificar prerequisitos
if ! command -v helm &> /dev/null; then
    echo "Helm no está instalado"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo "kubectl no está instalado"
    exit 1
fi

# Verificar namespace
if ! kubectl get namespace kong &> /dev/null; then
    echo "Creando namespace kong..."
    kubectl create namespace kong
fi

# Instalar/actualizar Kong base
echo "Instalando Kong Gateway..."
helm upgrade --install kong kong/kong -n kong -f values.yaml --wait --timeout=10m

# Esperar que Kong esté listo
echo "Esperando que Kong esté listo..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=kong -n kong --timeout=300s

# Aplicar plugins y consumidores manualmente
echo "Aplicando plugins y consumidores..."
kubectl apply -f templates/plugins/rate-limiting.yaml
kubectl apply -f templates/plugins/basic-auth.yaml
kubectl apply -f templates/consumers.yaml

# Verificar instalación
echo "✅ Verificando instalación..."
kubectl get pods -n kong
kubectl get kongclusterplugin

echo ""
echo "Kong instalado correctamente"
echo ""
echo "Comandos útiles:"
echo "   kubectl get pods -n kong"
echo "   kubectl get kongclusterplugin"
echo "   kubectl logs -n kong -l app.kubernetes.io/name=kong"
echo ""
echo "Para acceder a Mealie:"
echo "   curl -H 'Host: mealie.local' -u consumer-1:consumer-1-pass http://192.168.49.2:31021/" 