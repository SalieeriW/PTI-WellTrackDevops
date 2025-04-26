kind create cluster --config kind-config.yaml --name welltrack-local
kubectl cluster-info --context kind-welltrack-local
kubectl get nodes