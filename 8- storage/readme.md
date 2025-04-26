helm repo add rook-release https://charts.rook.io/release
helm repo update

helm install rook-ceph rook-release/rook-ceph \
  --namespace rook-ceph --create-namespace \
  --version v1.12.8

kubectl apply -f ceph-cluster.yaml
kubectl apply -f ceph-storageclass.yaml
// esperar la inicializaciones de los pods
kubectl -n rook-ceph get pods 
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- ceph status