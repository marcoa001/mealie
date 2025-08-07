#!/bin/bash

# Script para generar certificados SSL para usuarios de Mealie
# Basado en el proceso usado para crear test1
# Usa la CA de minikube para firmar los certificados

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔐 Generando certificados SSL para usuarios de Mealie...${NC}"

# Crear directorio de certificados si no existe
mkdir -p certs

# Detectar la ubicación de la CA de Kubernetes
detect_kubernetes_ca() {
    # Intentar diferentes ubicaciones comunes
    if [ -f "$HOME/.minikube/ca.crt" ] && [ -f "$HOME/.minikube/ca.key" ]; then
        CA_CERT="$HOME/.minikube/ca.crt"
        CA_KEY="$HOME/.minikube/ca.key"
        echo -e "${GREEN}✅ CA encontrada en: ~/.minikube/${NC}"
    elif [ -f "/home/adminuser/.minikube/ca.crt" ] && [ -f "/home/adminuser/.minikube/ca.key" ]; then
        CA_CERT="/home/adminuser/.minikube/ca.crt"
        CA_KEY="/home/adminuser/.minikube/ca.key"
        echo -e "${GREEN}✅ CA encontrada en: /home/adminuser/.minikube/${NC}"
    else
        echo -e "${RED}❌ No se encontró la CA de Kubernetes${NC}"
        echo "Buscando en configuraciones alternativas..."
        
        # Buscar en el kubeconfig actual
        KUBECONFIG_PATH=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.certificate-authority}')
        if [ -n "$KUBECONFIG_PATH" ] && [ -f "$KUBECONFIG_PATH" ]; then
            CA_CERT="$KUBECONFIG_PATH"
            # Intentar encontrar la clave correspondiente
            CA_KEY=$(dirname "$KUBECONFIG_PATH")/ca.key
            if [ -f "$CA_KEY" ]; then
                echo -e "${GREEN}✅ CA encontrada en: $KUBECONFIG_PATH${NC}"
            else
                echo -e "${RED}❌ No se encontró la clave privada de la CA${NC}"
                exit 1
            fi
        else
            echo -e "${RED}❌ No se pudo detectar la CA de Kubernetes${NC}"
            echo "Por favor, asegúrate de que minikube esté ejecutándose y la CA esté disponible"
            exit 1
        fi
    fi
}

# Función para generar certificado de usuario (siguiendo el proceso de test1)
generate_user_cert() {
    local username=$1
    local user_key="certs/${username}.key"
    local user_csr="certs/${username}.csr"
    local user_cert="certs/${username}.crt"

    echo -e "${YELLOW}📝 Generando certificado para usuario: ${username}${NC}"

    # PASO 1: Crear clave privada
    echo "1. Creando clave privada..."
    openssl genrsa -out "$user_key" 2048

    # PASO 2: Crear CSR
    echo "2. Creando Certificate Signing Request (CSR)..."
    openssl req -new -key "$user_key" -out "$user_csr" \
        -subj "/CN=${username}/O=mealie"

    # PASO 3: Firmar CSR con la CA de Kubernetes
    echo "3. Firmando CSR con la CA de Kubernetes..."
    openssl x509 -req -in "$user_csr" -CA "$CA_CERT" -CAkey "$CA_KEY" \
        -CAcreateserial -out "$user_cert" -days 365

    echo -e "${GREEN}✅ Certificado generado para: ${username}${NC}"
}

# Función para crear usuario y contexto en kubectl
create_kubectl_user_and_context() {
    local username=$1
    local user_cert="certs/${username}.crt"
    local user_key="certs/${username}.key"

    echo -e "${YELLOW}🔧 Creando usuario y contexto para: ${username}${NC}"

    # Obtener el nombre del cluster actual
    local cluster_name=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
    
    # Crear usuario con kubectl config
    kubectl config set-credentials "$username" \
        --client-certificate="$user_cert" \
        --client-key="$user_key"

    # Crear contexto
    kubectl config set-context "${username}-context" \
        --cluster="$cluster_name" \
        --user="$username"

    echo -e "${GREEN}✅ Usuario y contexto creados para: ${username}${NC}"
}

# Función para crear kubeconfig independiente
create_kubeconfig() {
    local username=$1
    local user_cert="certs/${username}.crt"
    local user_key="certs/${username}.key"
    local kubeconfig="certs/${username}-kubeconfig.yaml"

    echo -e "${YELLOW}📄 Creando kubeconfig independiente para: ${username}${NC}"

    # Obtener información del cluster
    local cluster_name=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
    local cluster_server=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
    local ca_data=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

    # Si no hay certificate-authority-data, usar el archivo
    if [ -z "$ca_data" ]; then
        local ca_file=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.certificate-authority}')
        if [ -f "$ca_file" ]; then
            ca_data=$(cat "$ca_file" | base64 -w 0)
        fi
    fi

    # Obtener certificados en base64
    local cert_b64=$(cat "$user_cert" | base64 -w 0)
    local key_b64=$(cat "$user_key" | base64 -w 0)

    cat > "$kubeconfig" << EOF
apiVersion: v1
kind: Config
clusters:
- name: ${cluster_name}
  cluster:
    server: ${cluster_server}
    certificate-authority-data: ${ca_data}
contexts:
- name: ${username}-context
  context:
    cluster: ${cluster_name}
    user: ${username}
current-context: ${username}-context
users:
- name: ${username}
  user:
    client-certificate-data: ${cert_b64}
    client-key-data: ${key_b64}
EOF

    echo -e "${GREEN}📄 Kubeconfig creado: ${kubeconfig}${NC}"
}

# Lista de usuarios definidos en rolebindings.yaml
USERS=("mealie-admin" "mealie-developer" "mealie-viewer" "monitoring-admin" "db-operator" "test1")

# Detectar CA de Kubernetes
detect_kubernetes_ca

# Generar certificados para cada usuario
for user in "${USERS[@]}"; do
    generate_user_cert "$user"
done

# Crear usuarios y contextos en kubectl
for user in "${USERS[@]}"; do
    create_kubectl_user_and_context "$user"
done

# Crear kubeconfigs independientes
for user in "${USERS[@]}"; do
    create_kubeconfig "$user"
done

# Mostrar contextos disponibles
echo -e "${GREEN}📋 Contextos disponibles:${NC}"
kubectl config get-contexts

# Crear script de prueba
cat > certs/test-authentication.sh << 'EOF'
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
EOF

chmod +x certs/test-authentication.sh

echo -e "${GREEN}🎉 Generación de certificados completada!${NC}"
echo ""
echo -e "${GREEN}📋 Resumen de lo creado:${NC}"
echo "📁 Certificados: certs/*.crt"
echo "🔑 Claves privadas: certs/*.key"
echo "📄 Kubeconfigs: certs/*-kubeconfig.yaml"
echo "🔧 Usuarios y contextos agregados a kubectl config"
echo ""
echo -e "${GREEN}📋 Comandos útiles:${NC}"
echo "• Ver contextos: kubectl config get-contexts"
echo "• Cambiar contexto: kubectl config use-context mealie-admin-context"
echo "• Probar autenticación: ./certs/test-authentication.sh"
echo "• Usar kubeconfig específico: kubectl --kubeconfig=certs/mealie-admin-kubeconfig.yaml get pods"
echo ""
echo -e "${YELLOW}⚠️  Nota: Los certificados tienen validez de 365 días${NC}" 