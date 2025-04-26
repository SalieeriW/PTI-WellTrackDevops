welltrack-local-infra/
├── cluster-setup/
│   └── kind-config.yaml         # Kind集群配置
├── ingress/
│   └── values-ingress.yaml      # Nginx Ingress的自定义值
├── harbor/
│   └── values-harbor.yaml       # Harbor的自定义值
├── argocd/
│   └── values-argocd.yaml       # Argo CD的自定义值
├── database/
│   └── values-postgres.yaml     # PostgreSQL的自定义值
├── monitoring/
│   └── values-prometheus.yaml   # Prometheus Stack的自定义值
├── logging/
│   ├── values-loki.yaml         # Loki的自定义值
│   └── values-promtail.yaml     # Promtail的自定义值
├── storage/
│   └── ceph-cluster.yaml        # Ceph集群配置
│   └── ceph-storageclass.yaml   # Ceph StorageClass配置
├── secrets/
│   └── values-vault.yaml        # Vault的自定义值
└── README.md                    # 文档说明

# nano /etc/hosts
127.0.0.1       localhost harbor.welltrack.local argocd.welltrack.local grafana.welltrack.local vault.welltrack.local