#!/bin/bash

echo "Instalando Argo Rollouts..."

# Crear namespace
kubectl create namespace argo-rollouts --dry-run=client -o yaml | kubectl apply -f -

# Instalar Argo Rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# Instalar Argo Rollouts Dashboard (opcional)
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/dashboard-install.yaml

# Verificar la instalación
echo "Verificando la instalación..."
kubectl get pods -n argo-rollouts

echo "Argo Rollouts instalado correctamente!"
echo "Para acceder al dashboard: kubectl -n argo-rollouts port-forward deployment/argo-rollouts-dashboard 3100:3100"
