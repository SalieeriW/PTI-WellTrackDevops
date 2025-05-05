# Archivos de Configuración (Values) de Componentes

Este directorio contiene los archivos `values.yaml` específicos para la configuración detallada de cada componente de la infraestructura gestionado por el chart Helm `bootstrap`.

## Propósito

Cada archivo en este directorio corresponde a un componente específico (ej. `ingress.yaml` para Nginx Ingress, `harbor.yaml` para Harbor, etc.) y contiene las opciones de configuración que se pasarán al chart Helm de dicho componente.

Estos archivos son referenciados e incluidos por las plantillas de `Application` ubicadas en el directorio `../templates/` mediante la función `.Files.Get` de Helm. Por ejemplo, en `../templates/ingress.yaml` se utiliza:

```yaml
helm:
  values: |
{{ .Files.Get "values/ingress.yaml" | indent 8 }}
```

Esto permite mantener la configuración específica de cada componente separada y organizada, mientras que el chart `bootstrap` principal orquesta su despliegue.

## Archivos Presentes

-   `argocd.yaml`: (Nota: Este archivo parece ser de una configuración anterior o para desplegar ArgoCD mismo, revisar si es necesario aquí).
-   `database.yaml`: Configuración para PostgreSQL.
-   `harbor.yaml`: Configuración para Harbor.
-   `ingress.yaml`: Configuración para Nginx Ingress Controller.
-   `logging-loki.yaml`: Configuración para Loki.
-   `logging-promtail.yaml`: Configuración para Promtail.
-   `monitoring.yaml`: Configuración para Kube Prometheus Stack (Prometheus, Grafana, Alertmanager).
-   `storage.yaml`: Configuración para Rook-Ceph.
-   `vault.yaml`: Configuración para HashiCorp Vault.

Modifica el archivo correspondiente para ajustar la configuración del componente deseado. 