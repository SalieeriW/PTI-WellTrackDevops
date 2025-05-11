# Archivos de Configuración (Values) de Componentes de Infraestructura

Este directorio contiene los archivos `values.yaml` específicos para la configuración detallada de cada componente de la **infraestructura base** gestionado por el chart Helm `bootstrap` (como el Ingress Controller, cert-manager, Vault, Harbor, base de datos, etc.).

## Propósito

Cada archivo en este directorio corresponde a un componente de infraestructura específico (ej. `ingress.yaml` para la configuración del *controlador* Nginx Ingress, `cert-manager.yaml` para el gestor de certificados, `harbor.yaml` para Harbor, etc.) y contiene las opciones de configuración que se pasarán al chart Helm de dicho componente.

Estos archivos son referenciados e incluidos por las plantillas de `Application` ubicadas en el directorio `../templates/` mediante la función `.Files.Get` de Helm. Por ejemplo, en `../templates/ingress.yaml` (que define la `Application` para el Ingress Controller) se utiliza:

```yaml
helm:
  values: |
{{ .Files.Get "values/ingress.yaml" | indent 8 }}
```

Esto permite mantener la configuración específica de cada componente de infraestructura separada y organizada, mientras que el chart `bootstrap` principal orquesta su despliegue.

**Importante**: La configuración de las *aplicaciones finales* (como `welltrack-frontend`, `welltrack-backend`, `welltrack-ml`), incluyendo sus propias reglas de `Ingress` (ej. para `app.welltrack.local`), sus certificados TLS, y otros detalles específicos de la aplicación, **NO** se gestiona aquí. Esa configuración reside en los archivos `values.yaml` de sus respectivos charts Helm dentro del repositorio `PTI-WellTrackGitOps`.

## Archivos Presentes (Ejemplos)

-   `argocd.yaml`: Configuración para el propio Argo CD (si se gestiona su despliegue mediante este patrón, aunque a menudo se instala por separado primero).
-   `cert-manager.yaml`: Configuración para el chart de `cert-manager`.
-   `database.yaml`: Configuración para PostgreSQL (u otra base de datos).
-   `harbor.yaml`: Configuración para Harbor.
-   `ingress.yaml`: Configuración para el Nginx Ingress **Controller**.
-   `logging-loki.yaml`: Configuración para Loki.
-   `logging-promtail.yaml`: Configuración para Promtail.
-   `monitoring.yaml`: Configuración para Kube Prometheus Stack.
-   `storage.yaml`: Configuración para Rook-Ceph (u otro proveedor de almacenamiento).
-   `vault.yaml`: Configuración para HashiCorp Vault.
-   `falco.yaml`: Configuración para Falco.

Modifica el archivo correspondiente en este directorio para ajustar la configuración del componente de **infraestructura** deseado. Para la configuración de las aplicaciones, dirígete al repositorio `PTI-WellTrackGitOps`. 