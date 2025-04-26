helm repo add harbor https://helm.goharbor.io
helm repo update

helm install harbor harbor/harbor --namespace harbor --create-namespace -f values-harbor.yaml

kubectl get pods -n harbor
kubectl get svc -n harbor