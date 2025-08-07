helm install fluentd fluent/fluentd -f values.yaml
kubectl get pods -l app.kubernetes.io/name=fluentd