#!/bin/bash

# Script para gestionar releases y rollbacks de Argo Rollouts
NAMESPACE="mealie-app"
ROLLOUT_NAME="mealie-canary"

case "$1" in
    "status")
        echo "📊 Estado del rollout:"
        kubectl argo rollouts get rollout $ROLLOUT_NAME -n $NAMESPACE
        ;;
    "promote")
        echo "🚀 Promoviendo rollout..."
        kubectl argo rollouts promote $ROLLOUT_NAME -n $NAMESPACE
        ;;
    "undo")
        echo "⏪ Revertiendo rollout..."
        kubectl argo rollouts undo $ROLLOUT_NAME -n $NAMESPACE
        ;;
    "restart")
        echo "🔄 Reiniciando rollout..."
        kubectl argo rollouts restart $ROLLOUT_NAME -n $NAMESPACE
        ;;
    "logs")
        echo "📝 Mostrando logs del rollout..."
        kubectl argo rollouts logs -f $ROLLOUT_NAME -n $NAMESPACE
        ;;
    "dashboard")
        echo "🌐 Abriendo dashboard de Argo Rollouts..."
        kubectl argo rollouts dashboard
        ;;
    "update-image")
        if [ -z "$2" ]; then
            echo "❌ Error: Debes especificar la nueva imagen"
            echo "Uso: $0 update-image <nueva-imagen>"
            exit 1
        fi
        echo "🔄 Actualizando imagen a: $2"
        kubectl argo rollouts set image $ROLLOUT_NAME -n $NAMESPACE mealie=$2
        ;;
    "rollback")
        if [ -z "$2" ]; then
            echo "❌ Error: Debes especificar la revisión"
            echo "Uso: $0 rollback <revision-number>"
            exit 1
        fi
        echo "⏪ Haciendo rollback a la revisión: $2"
        kubectl argo rollouts undo $ROLLOUT_NAME -n $NAMESPACE --to-revision=$2
        ;;
    *)
        echo "🔧 Script de gestión de Argo Rollouts"
        echo ""
        echo "Uso: $0 <comando> [opciones]"
        echo ""
        echo "Comandos disponibles:"
        echo "  status                    - Mostrar estado del rollout"
        echo "  promote                   - Promover el rollout"
        echo "  undo                      - Revertir el rollout"
        echo "  restart                   - Reiniciar el rollout"
        echo "  logs                      - Mostrar logs del rollout"
        echo "  dashboard                 - Abrir dashboard de Argo Rollouts"
        echo "  update-image <imagen>     - Actualizar imagen del rollout"
        echo "  rollback <revision>       - Hacer rollback a una revisión específica"
        echo ""
        echo "Ejemplos:"
        echo "  $0 status"
        echo "  $0 update-image ghcr.io/mealie-recipes/mealie:v3.0.2"
        echo "  $0 rollback 2"
        ;;
esac
