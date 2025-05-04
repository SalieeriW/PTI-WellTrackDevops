helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argocd argo/argo-cd --namespace argocd --create-namespace -f values-argocd.yaml

(en los casos que hay que hacer update)
helm upgrade argocd argo/argo-cd --namespace argocd -f values-argocd.yaml

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

p4fBHxBwFSR1D7Av

y acceder al https://argocd.welltrack.local