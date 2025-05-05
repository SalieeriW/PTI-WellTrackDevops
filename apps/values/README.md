# WellTrack 配置值文件

## 概述

本目录包含WellTrack DevOps基础设施各组件的Helm值文件，这些文件定义了各组件的具体配置。这些值文件从原始目录结构中的各个模块移动到此统一目录，以配合ArgoCD的App of Apps模式使用。

## 文件说明

### ingress.yaml

NGINX Ingress Controller的配置值，主要包括:
- 控制器服务类型(NodePort)
- 部署模式(DaemonSet)
- 资源请求与限制
- 主机端口配置

### harbor.yaml

Harbor容器镜像仓库的配置值，主要包括:
- 暴露方式(Ingress)
- 外部URL
- 持久化设置
- 各组件资源配置

### argocd.yaml

ArgoCD的配置值，主要包括:
- 全局域名设置
- Ingress配置
- 资源请求与限制
- App of Apps的组件配置

### database.yaml

PostgreSQL数据库的配置值，主要包括:
- 认证信息(用户名/密码)
- 持久化设置
- 资源请求与限制

### monitoring.yaml

Prometheus和Grafana监控系统的配置值，主要包括:
- Grafana的Ingress设置
- 持久化配置
- 资源请求与限制
- 组件启用/禁用设置

### logging-loki.yaml

Loki日志聚合系统的配置值，主要包括:
- 部署模式(SingleBinary)
- 持久化设置
- 认证配置
- 资源请求与限制

### logging-promtail.yaml

Promtail日志收集代理的配置值，主要包括:
- Loki服务器连接设置
- 资源请求与限制

### storage.yaml

Rook/Ceph分布式存储系统的配置值，主要包括:
- 操作员配置
- 集群设置
- 存储路径
- 资源请求与限制

### vault.yaml

HashiCorp Vault密钥管理工具的配置值，主要包括:
- 开发模式设置
- Ingress配置
- UI启用设置
- 存储后端配置

## 使用说明

这些值文件被App of Apps模式中的各个子应用引用，路径格式为:

```yaml
helm:
  valueFiles:
    - ../../values/文件名.yaml
```

修改这些文件可以定制相应组件的行为，修改后通过ArgoCD进行同步，即可应用更改。 