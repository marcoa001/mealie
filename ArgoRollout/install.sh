#!/bin/bash

# Script de instalación para Argo Rollouts con Canary releases
echo "🚀 Instalando Argo Rollouts con configuración Canary..."

# Crear namespace si no existe
kubectl create namespace argo-rollouts --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace mealie-app --dry-run=client -o yaml | kubectl apply -f -

# Instalar Argo Rollouts si no está instalado
if ! kubectl get deployment -n argo-rollouts argo-rollouts >/dev/null 2>&1; then
    echo "📦 Instalando Argo Rollouts..."
    kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
fi

# Esperar a que Argo Rollouts esté listo
echo "⏳ Esperando a que Argo Rollouts esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/argo-rollouts -n argo-rollouts

# Aplicar los AnalysisTemplates
echo "📊 Aplicando AnalysisTemplates..."
kubectl apply -f analysis-templates.yaml

# Aplicar los servicios
echo "🔌 Aplicando servicios..."
kubectl apply -f service.yaml

# Aplicar el rollout
echo "🔄 Aplicando rollout Canary..."
kubectl apply -f rollout.yaml

# Aplicar el ingress
echo "🌐 Aplicando ingress..."
kubectl apply -f ingress.yaml

echo "✅ Instalación completada!"
echo ""
echo "📋 Comandos útiles:"
echo "  Ver estado del rollout: kubectl argo rollouts get rollout mealie-canary -n mealie-app"
echo "  Promover rollout: kubectl argo rollouts promote mealie-canary -n mealie-app"
echo "  Revertir rollout: kubectl argo rollouts undo mealie-canary -n mealie-app"
echo "  Ver logs: kubectl argo rollouts logs -f mealie-canary -n mealie-app"
echo ""
echo "🌍 La aplicación estará disponible en: http://mealie.local"