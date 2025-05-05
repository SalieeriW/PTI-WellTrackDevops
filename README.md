# WellTrack DevOps 基础设施

本项目使用ArgoCD的App of Apps模式实现对WellTrack开发环境所需的基础设施的自动化部署与管理。

## 项目架构

项目基于Kubernetes构建，采用GitOps方法论，通过ArgoCD实现基础设施即代码(IaC)。

### 主要组件

- **NGINX Ingress Controller** - 入站流量路由
- **Harbor** - 容器镜像仓库
- **PostgreSQL** - 关系型数据库
- **Prometheus/Grafana** - 监控与可视化
- **Loki/Promtail** - 日志收集与分析
- **Rook/Ceph** - 分布式存储
- **HashiCorp Vault** - 密钥管理

## 项目结构

```
PTI-WellTrackDevops/
├── apps/                     # App of Apps主目录
│   ├── templates/            # ArgoCD应用模板
│   │   ├── ingress.yaml      # Ingress Controller应用定义
│   │   ├── harbor.yaml       # Harbor应用定义
│   │   ├── database.yaml     # PostgreSQL应用定义
│   │   ├── monitoring.yaml   # Prometheus/Grafana应用定义
│   │   ├── logging.yaml      # Loki/Promtail应用定义
│   │   ├── storage.yaml      # Rook/Ceph应用定义
│   │   └── vault.yaml        # Vault应用定义
│   ├── Chart.yaml            # Helm Chart定义
│   └── values.yaml           # App of Apps配置值
├── values/                   # 各组件Helm值文件
│   ├── ingress.yaml          # Ingress Controller配置
│   ├── harbor.yaml           # Harbor配置
│   ├── argocd.yaml           # ArgoCD配置
│   ├── database.yaml         # PostgreSQL配置
│   ├── monitoring.yaml       # Prometheus/Grafana配置
│   ├── logging-loki.yaml     # Loki配置
│   ├── logging-promtail.yaml # Promtail配置
│   └── vault.yaml            # Vault配置
├── bootstrap.yaml            # ArgoCD引导应用
└── README.md                 # 项目文档
```

### 目录说明

- **apps/** - 包含ArgoCD App of Apps模式的核心定义
  - **templates/** - 各组件的ArgoCD Application资源定义
  - **Chart.yaml** - 定义Helm Chart元数据
  - **values.yaml** - 包含所有子应用的配置信息

- **values/** - 存储各组件的Helm值文件，从原始目录结构中移植过来
  
- **bootstrap.yaml** - ArgoCD引导应用，是整个部署的入口点

## 部署流程

### 前提条件

- 已安装Kubernetes集群
- 已安装Helm 3
- 已配置kubectl并可连接到集群

### 部署步骤

1. **部署ArgoCD**

```bash
# 创建ArgoCD命名空间
kubectl create namespace argocd

# 添加ArgoCD Helm仓库
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# 部署ArgoCD
helm install argocd argo/argo-cd -n argocd -f values/argocd.yaml
```

2. **应用引导应用**

```bash
# 应用bootstrap.yaml
kubectl apply -f bootstrap.yaml
```

3. **访问ArgoCD UI**

```bash
# 获取初始管理员密码
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 设置端口转发(或通过配置的Ingress访问)
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

然后访问 https://localhost:8080 或 http://argocd.welltrack.local (如果配置了Ingress)

## 同步顺序

组件按照以下顺序部署(通过syncWave控制):

1. **基础层(syncWave: 1)**: 
   - Ingress Controller - 网络入口
   - Storage - 分布式存储

2. **数据层(syncWave: 2)**:
   - PostgreSQL - 数据库
   - Harbor - 容器仓库

3. **可观测性层(syncWave: 3)**:
   - Prometheus/Grafana - 监控
   - Loki/Promtail - 日志

4. **安全层(syncWave: 4)**:
   - Vault - 密钥管理

## 配置说明

所有组件的配置都存储在`values/`目录中，这些是从原始项目结构中的单独目录移植过来的Helm值文件。修改这些文件可以定制各组件的行为。

### 主要配置文件

- **values/ingress.yaml** - NGINX Ingress Controller配置
- **values/harbor.yaml** - Harbor容器仓库配置
- **values/database.yaml** - PostgreSQL数据库配置
- **values/monitoring.yaml** - Prometheus和Grafana监控系统配置
- **values/logging-loki.yaml** - Loki日志聚合系统配置
- **values/logging-promtail.yaml** - Promtail日志收集代理配置
- **values/vault.yaml** - HashiCorp Vault机密管理工具配置

## 添加新组件

要添加新组件，需要:

1. 在`apps/values.yaml`中添加组件配置
2. 在`apps/templates/`创建对应的Application模板
3. 在`values/`目录中添加组件的Helm值文件

## 故障排除

- **应用同步失败**: 检查ArgoCD UI中的同步状态和错误信息
- **组件部署失败**: 检查对应命名空间中的Pod状态和日志 