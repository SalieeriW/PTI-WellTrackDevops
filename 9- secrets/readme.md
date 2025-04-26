helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm install vault hashicorp/vault \
  --namespace vault --create-namespace \
  -f values-vault.yaml

# 初始化Vault（生产模式需要）
kubectl exec -n vault vault-0 -- vault operator init \
  -key-shares=1 -key-threshold=1 \
  -format=json > vault-keys.json

# 解封Vault（生产模式需要）
UNSEAL_KEY=$(jq -r ".unseal_keys_b64" vault-keys.json)
kubectl exec -n vault vault-0 -- vault operator unseal $UNSEAL_KEY