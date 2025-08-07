#!/bin/bash

# Script para instalar Fluentd con Helm
echo "Instalando Fluentd con Helm..."

# Agregar el repositorio de Fluentd
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

# Instalar Fluentd con configuración personalizada
helm install fluentd fluent/fluentd \
  --namespace monitoring \
  --create-namespace \
  -f values.yaml

echo "Fluentd instalado. Verificando estado..."
kubectl get pods -n monitoring -l app.kubernetes.io/name=fluentd
