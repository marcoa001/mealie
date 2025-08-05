# Configuración de Seguridad y RBAC para Mealie

Este directorio contiene la configuración de seguridad, roles y network policies para la aplicación Mealie.

## 📁 Estructura de archivos

```
security-rbac/
├── roles.yaml                    # Roles y ClusterRoles
├── rolebindings.yaml             # RoleBindings y ClusterRoleBindings
├── serviceaccounts.yaml          # Service Accounts
├── network-policies.yaml         # Network Policies
├── install-security.sh           # Script de instalación
└── README.md                     # Esta documentación
```

## 🔐 Roles definidos

### Roles de Namespace
- **mealie-app-role**: Acceso de lectura a recursos de la aplicación en `mealie-db`
- **monitoring-role**: Acceso a recursos de monitoreo en `monitoring`

### ClusterRoles
- **mealie-admin-role**: Acceso administrativo global
- **mealie-readonly-role**: Acceso de solo lectura global
- **db-operator-role**: Acceso para operaciones de base de datos

## 👥 Usuarios y Grupos

### Usuarios
- `mealie-admin`: Administrador con acceso completo
- `mealie-developer`: Desarrollador con acceso limitado
- `mealie-viewer`: Usuario de solo lectura
- `monitoring-admin`: Administrador de monitoreo
- `db-operator`: Operador de base de datos

### Grupos
- `mealie-admins`: Grupo de administradores
- `mealie-viewers`: Grupo de usuarios de solo lectura

## 🌐 Network Policies

### mealie-db-network-policy
- Controla acceso a PostgreSQL
- Permite tráfico desde Mealie, postgres-exporter y pgAdmin
- Restringe tráfico saliente

### postgres-exporter-network-policy
- Controla acceso al postgres exporter
- Permite scraping desde Prometheus
- Restringe acceso a PostgreSQL

### monitoring-network-policy
- Controla acceso a Prometheus
- Permite tráfico desde Grafana
- Restringe acceso a exporters

### grafana-network-policy
- Controla acceso a Grafana
- Permite tráfico HTTP/HTTPS entrante
- Restringe tráfico saliente

## 🚀 Instalación

```bash
# Hacer ejecutable el script
chmod +x security-rbac/install-security.sh

# Ejecutar instalación
./security-rbac/install-security.sh
```

## 🔍 Verificación

### Verificar Service Accounts
```bash
kubectl get serviceaccounts --all-namespaces | grep -E "(mealie|monitoring|postgres)"
```

### Verificar Roles
```bash
kubectl get roles --all-namespaces | grep -E "(mealie|monitoring)"
kubectl get clusterroles | grep -E "(mealie|db-operator)"
```

### Verificar Network Policies
```bash
kubectl get networkpolicies --all-namespaces
```

### Verificar permisos de usuario
```bash
kubectl auth can-i --as=mealie-admin get pods --all-namespaces
kubectl auth can-i --as=mealie-viewer get pods --all-namespaces
```

## 🛡️ Buenas prácticas de seguridad

1. **Principio de menor privilegio**: Cada rol tiene solo los permisos necesarios
2. **Segregación de responsabilidades**: Diferentes roles para diferentes funciones
3. **Network Policies**: Control granular del tráfico de red
4. **Service Accounts**: Cuentas específicas para aplicaciones
5. **Auditoría**: Roles y permisos documentados y verificables

## 🔧 Configuración de usuarios

Para agregar nuevos usuarios, edita `rolebindings.yaml` y agrega:

```yaml
subjects:
- kind: User
  name: nuevo-usuario
  apiGroup: rbac.authorization.k8s.io
```

## 📊 Monitoreo de seguridad

- Revisar logs de auditoría: `kubectl get events --all-namespaces`
- Verificar network policies: `kubectl describe networkpolicy`
- Monitorear acceso: `kubectl auth can-i --list --as=usuario`

## 🚨 Incidentes de seguridad

En caso de incidentes:

1. Revisar logs de auditoría
2. Verificar network policies
3. Comprobar permisos de usuarios
4. Revisar Service Accounts
5. Documentar incidente y acciones tomadas 