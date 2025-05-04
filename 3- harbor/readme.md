helm repo add harbor https://helm.goharbor.io
helm repo update

helm install harbor harbor/harbor --namespace harbor --create-namespace -f values-harbor.yaml

kubectl get secret -n harbor harbor-core -o jsonpath="{.data.HARBOR_ADMIN_PASSWORD}" | base64 --decode

admin
Harbor12345

kubectl get pods -n harbor
kubectl get svc -n harbor