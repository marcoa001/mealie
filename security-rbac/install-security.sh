#!/bin/bash

# Script para instalar configuración de seguridad y RBAC
# Autor: Sistema de Seguridad
# Fecha: $(date)

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Instalación de Configuración de Seguridad y RBAC ===${NC}"

# Verificar si kubectl está disponible
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl no está instalado${NC}"
    exit 1
fi

# Función para crear namespace si no existe
create_namespace() {
    local namespace=$1
    if ! kubectl get namespace $namespace &> /dev/null; then
        echo -e "${YELLOW}Creando namespace $namespace...${NC}"
        kubectl create namespace $namespace
    else
        echo -e "${BLUE}Namespace $namespace ya existe${NC}"
    fi
}

# Crear namespaces necesarios
echo -e "${YELLOW}Creando namespaces...${NC}"
create_namespace "mealie-db"
create_namespace "monitoring"

# Aplicar Service Accounts
echo -e "${YELLOW}Aplicando Service Accounts...${NC}"
kubectl apply -f security-rbac/serviceaccounts.yaml

# Aplicar Roles y ClusterRoles
echo -e "${YELLOW}Aplicando Roles y ClusterRoles...${NC}"
kubectl apply -f security-rbac/roles.yaml

# Aplicar RoleBindings y ClusterRoleBindings
echo -e "${YELLOW}Aplicando RoleBindings y ClusterRoleBindings...${NC}"
kubectl apply -f security-rbac/rolebindings.yaml

# Aplicar Network Policies
echo -e "${YELLOW}Aplicando Network Policies...${NC}"
kubectl apply -f security-rbac/network-policies.yaml

# Verificar la instalación
echo -e "${YELLOW}Verificando la instalación...${NC}"
echo -e "${BLUE}Service Accounts:${NC}"
kubectl get serviceaccounts --all-namespaces | grep -E "(mealie|monitoring|postgres)"

echo -e "${BLUE}Roles:${NC}"
kubectl get roles --all-namespaces | grep -E "(mealie|monitoring)"

echo -e "${BLUE}ClusterRoles:${NC}"
kubectl get clusterroles | grep -E "(mealie|db-operator)"

echo -e "${BLUE}Network Policies:${NC}"
kubectl get networkpolicies --all-namespaces

echo -e "${GREEN}=== Instalación de seguridad completada ===${NC}"
echo -e "${YELLOW}Comandos útiles:${NC}"
echo "kubectl get serviceaccounts --all-namespaces"
echo "kubectl get roles --all-namespaces"
echo "kubectl get clusterroles"
echo "kubectl get networkpolicies --all-namespaces"
echo -e "${YELLOW}Para verificar permisos de un usuario:${NC}"
echo "kubectl auth can-i --as=mealie-admin get pods --all-namespaces"
echo "kubectl auth can-i --as=mealie-viewer get pods --all-namespaces" 