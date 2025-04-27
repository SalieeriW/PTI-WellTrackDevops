# WellTrack Local Infrastructure Setup

This repository contains the configuration files for setting up a local development environment for WellTrack using Kind (Kubernetes in Docker) and various Helm charts.

## Project Structure

The main components are organized into the following directories:

```
welltrack-local-infra/
├── 1- cluster-setup/         # Kind cluster configuration
│   └── kind-config.yaml
├── 2- ingress/               # Nginx Ingress Controller setup
│   └── values-ingress.yaml
├── 3- harbor/                # Harbor container registry setup (values placeholder)
│   └── values-harbor.yaml
├── 4- argocd/                # Argo CD GitOps controller setup
│   └── values-argocd.yaml
├── 5- database/              # PostgreSQL database setup
│   └── values-postgres.yaml
├── 6- monitoring/            # Prometheus & Grafana monitoring stack setup
│   └── values-prometheus.yaml
├── 7- logging/               # Loki & Promtail logging stack setup
│   ├── values-loki.yaml
│   └── values-promtail.yaml
├── 8- storage/               # Rook Ceph distributed storage setup
│   ├── ceph-cluster.yaml
│   └── ceph-storageclass.yaml
├── 9- secrets/               # HashiCorp Vault secrets management setup
│   └── values-vault.yaml
└── readme.md                 # This documentation file
```

## Local Host Configuration

For accessing services exposed via Ingress (like Harbor, Argo CD, Grafana, Vault) using their hostnames, you need to add the following entry to your local machine's hosts file (e.g., `/etc/hosts` on Linux/macOS or `C:\Windows\System32\drivers\etc\hosts` on Windows):

```bash
# Example entry for /etc/hosts
127.0.0.1       localhost harbor.welltrack.local argocd.welltrack.local grafana.welltrack.local vault.welltrack.local
```

## Setup Instructions

Please refer to the `readme.md` file within each numbered directory (e.g., `1- cluster-setup/readme.md`, `2- ingress/readme.md`, etc.) for specific setup commands and instructions for each component. Follow the directories in numerical order.