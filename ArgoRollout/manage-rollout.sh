#!/bin/bash

# Script para gestionar Argo Rollouts
NAMESPACE=${1:-mealie-app}
ROLLOUT_NAME=${2:-mealie}

case "$3" in
  "promote")
    echo "Promoviendo rollout $ROLLOUT_NAME..."
    kubectl argo rollouts promote $ROLLOUT_NAME -n $NAMESPACE
    ;;
  "abort")
    echo "Abortando rollout $ROLLOUT_NAME..."
    kubectl argo rollouts abort $ROLLOUT_NAME -n $NAMESPACE
    ;;
  "retry")
    echo "Reintentando rollout $ROLLOUT_NAME..."
    kubectl argo rollouts retry $ROLLOUT_NAME -n $NAMESPACE
    ;;
  "rollback")
    echo "Haciendo rollback del rollout $ROLLOUT_NAME..."
    kubectl argo rollouts rollback $ROLLOUT_NAME -n $NAMESPACE
    ;;
  "status")
    echo "Estado del rollout $ROLLOUT_NAME:"
    kubectl argo rollouts get $ROLLOUT_NAME -n $NAMESPACE
    ;;
  "list")
    echo "Listando rollouts en namespace $NAMESPACE:"
    kubectl argo rollouts list -n $NAMESPACE
    ;;
  *)
    echo "Uso: $0 <namespace> <rollout-name> <comando>"
    echo "Comandos disponibles:"
    echo "  promote   - Promover al siguiente paso"
    echo "  abort     - Abortar el rollout"
    echo "  retry     - Reintentar el rollout"
    echo "  rollback  - Hacer rollback"
    echo "  status    - Mostrar estado"
    echo "  list      - Listar rollouts"
    echo ""
    echo "Ejemplos:"
    echo "  $0 mealie-app mealie promote"
    echo "  $0 mealie-app mealie status"
    exit 1
    ;;
esac
