# WellTrack Apps - ArgoCD App of Apps

## 概述

本目录包含WellTrack DevOps基础设施的ArgoCD App of Apps模式定义。此模式使用单个父应用(bootstrap应用)管理多个子应用，实现基础设施的统一部署和管理。

## 目录结构

```
apps/
├── templates/            # ArgoCD应用模板
│   ├── ingress.yaml      # Ingress Controller应用定义
│   ├── harbor.yaml       # Harbor应用定义
│   ├── database.yaml     # PostgreSQL应用定义
│   ├── monitoring.yaml   # Prometheus/Grafana应用定义
│   ├── logging.yaml      # Loki/Promtail应用定义
│   ├── storage.yaml      # Rook/Ceph应用定义
│   └── vault.yaml        # Vault应用定义
├── Chart.yaml            # Helm Chart定义
├── values.yaml           # App of Apps配置值
└── README.md             # 本文档
```

## 文件说明

### Chart.yaml

定义Helm Chart的元数据信息，包括名称、版本和描述。

### values.yaml

包含所有子应用的配置信息，包括:

- 源代码仓库URL和版本
- 各组件的命名空间
- Helm值文件路径
- 同步波(syncWave)设置
- 目标服务器

### templates/

包含各子应用的ArgoCD Application资源定义模板，这些模板通过values.yaml中的配置生成最终的Application资源。

## 同步顺序

应用同步顺序由syncWave控制:

1. syncWave: 1 - 基础组件(Ingress, Storage)
2. syncWave: 2 - 数据组件(Database, Harbor)
3. syncWave: 3 - 可观测性组件(Monitoring, Logging)
4. syncWave: 4 - 安全组件(Vault)

## 模板示例

每个模板都遵循类似的结构:

```yaml
{{- if .Values.spec.组件名.enable }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: 应用名
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "{{ .Values.spec.组件名.syncWave }}"
spec:
  project: {{ .Values.spec.project }}
  source:
    chart: {{ .Values.spec.组件名.chart }}
    repoURL: {{ .Values.spec.组件名.repoURL }}
    targetRevision: {{ .Values.spec.组件名.targetRevision }}
    helm:
      valueFiles:
        - {{ .Values.spec.组件名.values }}
  destination:
    server: {{ .Values.spec.destination.server }}
    namespace: {{ .Values.spec.组件名.namespace }}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
{{- end }}
```

## 添加新组件

要添加新组件，需要:

1. 在`values.yaml`中添加组件配置
2. 在`templates/`创建对应的Application模板文件
3. 确保values目录中存在对应的Helm值文件 