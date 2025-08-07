#!/bin/bash

# Script para instalar postgres-exporter usando Helm
# Autor: Sistema de Monitoreo
# Fecha: $(date)

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Instalación de Postgres Exporter ===${NC}"

# Verificar si Helm está instalado
if ! command -v helm &> /dev/null; then
    echo -e "${RED}Error: Helm no está instalado${NC}"
    exit 1
fi

# Verificar si el namespace existe
if ! kubectl get namespace mealie-db &> /dev/null; then
    echo -e "${YELLOW}Creando namespace mealie-db...${NC}"
    kubectl create namespace mealie-db
fi

# Agregar el repositorio de prometheus-community si no existe
if ! helm repo list | grep -q "prometheus-community"; then
    echo -e "${YELLOW}Agregando repositorio prometheus-community...${NC}"
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
fi

# Actualizar repositorios
echo -e "${YELLOW}Actualizando repositorios de Helm...${NC}"
helm repo update

# Verificar si el release ya existe
if helm list -n mealie-db | grep -q "postgres-exporter"; then
    echo -e "${YELLOW}El release postgres-exporter ya existe. Actualizando...${NC}"
    helm upgrade postgres-exporter prometheus-community/prometheus-postgres-exporter \
        -f postgres-exporter/values.yaml \
        -n mealie-db
else
    echo -e "${YELLOW}Instalando postgres-exporter...${NC}"
    helm install postgres-exporter prometheus-community/prometheus-postgres-exporter \
        -f postgres-exporter/values.yaml \
        -n mealie-db
fi

echo -e "${GREEN}=== Instalación completada ===${NC}"
echo -e "${YELLOW}Para verificar el estado:${NC}"
echo "kubectl get pods -n mealie-db -l app.kubernetes.io/name=prometheus-postgres-exporter"
echo -e "${YELLOW}Para ver los logs:${NC}"
echo "kubectl logs -n mealie-db -l app.kubernetes.io/name=prometheus-postgres-exporter"
echo -e "${YELLOW}Para acceder al servicio:${NC}"
echo "kubectl port-forward -n mealie-db svc/postgres-exporter-prometheus-postgres-exporter 9187:9187" 




#para ir al homepage-- kubectl get svc -n mealie-db y ver el puerto, hacer un port-forward y acceder a la pagina
#kubectl port-forward -n mealie-db svc/postgres-exporter-prometheus-postgres-exporter 9187:80 &
#localhost:9187/metrics