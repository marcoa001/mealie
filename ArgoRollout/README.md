# 🚀 Argo Rollouts con Canary Releases para Mealie

Este directorio contiene la configuración completa para implementar **Canary releases** y **rollbacks automáticos** usando Argo Rollouts para la aplicación Mealie.

## 🎯 Características

- ✅ **Canary Releases**: Despliegue gradual del tráfico (10% → 50% → 100%)
- ✅ **Análisis Automático**: Métricas de éxito, latencia y tasa de errores
- ✅ **Rollbacks Automáticos**: Reversión automática si fallan las métricas
- ✅ **Monitoreo en Tiempo Real**: Integración con Prometheus
- ✅ **Gestión Fácil**: Scripts para gestionar releases y rollbacks

## 📁 Estructura de Archivos

```
ArgoRollout/
├── rollout.yaml              # Configuración principal del rollout Canary
├── service.yaml              # Servicios para stable y canary
├── ingress.yaml              # Ingress con Kong para routing
├── analysis-templates.yaml   # Templates para análisis automático
├── install.sh                # Script de instalación automática
├── manage-releases.sh        # Script para gestionar releases
└── README.md                 # Este archivo
```

## 🚀 Instalación

### 1. Instalación Automática (Recomendado)
```bash
cd ArgoRollout/
chmod +x install.sh
./install.sh
```

### 2. Instalación Manual
```bash
# Crear namespaces
kubectl create namespace argo-rollouts
kubectl create namespace mealie-app

# Instalar Argo Rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# Aplicar configuración
kubectl apply -f analysis-templates.yaml
kubectl apply -f service.yaml
kubectl apply -f rollout.yaml
kubectl apply -f ingress.yaml
```

## 🔧 Gestión de Releases

### Comandos Básicos
```bash
# Ver estado del rollout
./manage-releases.sh status

# Promover rollout manualmente
./manage-releases.sh promote

# Revertir rollout
./manage-releases.sh undo

# Ver logs
./manage-releases.sh logs

# Abrir dashboard
./manage-releases.sh dashboard
```

### Actualizar Imagen
```bash
# Actualizar a nueva versión
./manage-releases.sh update-image ghcr.io/mealie-recipes/mealie:v3.0.2

# Hacer rollback a revisión específica
./manage-releases.sh rollback 2
```

## 📊 Estrategia Canary

### Fases del Despliegue

1. **Fase 1 (10% tráfico)**: Despliegue inicial con 30s de pausa
2. **Análisis 1**: Verificación de métricas de éxito y latencia
3. **Fase 2 (50% tráfico)**: Escalado gradual con 1m de pausa
4. **Análisis 2**: Verificación final de métricas
5. **Fase 3 (100% tráfico)**: Despliegue completo

### Métricas de Análisis

- **Tasa de Éxito**: Debe ser ≥ 95% para continuar
- **Latencia**: Debe ser ≤ 0.5s para continuar
- **Tasa de Errores**: Debe ser ≤ 5% para continuar

## 🔍 Monitoreo

### Dashboard de Argo Rollouts
```bash
kubectl argo rollouts dashboard
```

### Métricas en Prometheus
- `http_requests_total`: Total de requests HTTP
- `http_request_duration_seconds`: Duración de requests
- `http_requests_total{status=~"5.."}`: Requests con error

## 🚨 Rollbacks Automáticos

Los rollbacks se activan automáticamente cuando:

- Las métricas fallan en cualquier fase del análisis
- La aplicación no responde correctamente
- Se exceden los umbrales de latencia o errores

## 🌐 Acceso a la Aplicación

- **URL Principal**: http://mealie.local
- **Puerto Canary**: 30925
- **Puerto Stable**: 30926

## 📋 Troubleshooting

### Problemas Comunes

1. **Rollout no avanza**: Verificar métricas de Prometheus
2. **Rollback automático**: Revisar logs y métricas
3. **Servicios no accesibles**: Verificar selectores de labels

### Comandos de Debug
```bash
# Ver eventos del rollout
kubectl describe rollout mealie-canary -n mealie-app

# Ver pods del rollout
kubectl get pods -n mealie-app -l app=mealie

# Ver logs de un pod específico
kubectl logs -n mealie-app <pod-name>
```

## 🔗 Enlaces Útiles

- [Documentación de Argo Rollouts](https://argoproj.github.io/argo-rollouts/)
- [Estrategias de Despliegue](https://argoproj.github.io/argo-rollouts/concepts/#deployment-strategies)
- [Análisis y Rollbacks](https://argoproj.github.io/argo-rollouts/concepts/#analysis)

## 📞 Soporte

Para problemas o preguntas:
1. Revisar logs del rollout
2. Verificar métricas de Prometheus
3. Consultar la documentación oficial
4. Revisar eventos del cluster
