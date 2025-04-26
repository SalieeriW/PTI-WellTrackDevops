helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace -f values-ingress.yaml

kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx