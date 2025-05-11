# Plantillas de Aplicación Argo CD (Sub-Aplicaciones)

Este directorio contiene las plantillas Helm que definen los recursos `Application` de Argo CD para cada **componente de infraestructura** (Ingress, Harbor, Base de Datos, etc.) y para las **aplicaciones principales** de WellTrack (Frontend, Backend, y ML).

## Funcionamiento

Cada archivo `.yaml` en este directorio es una plantilla Helm que genera un manifiesto `Application` de Argo CD.

-   **Control de Habilitación**: La generación de cada `Application` está condicionada por la variable `enabled` correspondiente en el archivo `../values.yaml` (ej. `{{- if .Values.ingress.enabled }}`, `{{- if .Values.spec.falco.enable }}` o `{{- if .Values.welltrackFrontend.enabled }}`).
-   **Definición de la Fuente**: Cada plantilla utiliza valores de `../values.yaml` para especificar la fuente de los manifiestos o chart del componente/aplicación:
    -   Para **componentes de infraestructura**: Normalmente se especifica `chart`, `repoURL` y `targetRevision` para un chart Helm externo (ej. `cert-manager`, `ingress-nginx`).
    -   Para **aplicaciones principales** (frontend, backend, ml): Normalmente se especifica `repoURL` (apuntando a `PTI-WellTrackGitOps`), `path` (al chart Helm específico de la aplicación dentro de `PTI-WellTrackGitOps`) y `targetRevision`.
-   **Inyección de Configuración (Infraestructura)**: Para los componentes de infraestructura, estas plantillas utilizan la sección `helm.values` junto con la función `.Files.Get` de Helm para inyectar la configuración desde el directorio `../values/` (dentro de *este* chart `bootstrap`):
    ```yaml
    helm:
      values: |
    {{ .Files.Get "values/<componente>.yaml" | indent 8 }}
    ```
    Esto permite configurar detalladamente cada componente de infraestructura (ej. Ingress Controller, Vault, cert-manager).
-   **Inyección de Configuración (Aplicaciones Principales - Frontend, Backend, ML)**: Para las aplicaciones `welltrack-frontend`, `welltrack-backend`, y `welltrack-ml`, la plantilla de `Application` (ej. `welltrack-frontend-app.yaml`) especifica `helm.valueFiles: ["values.yaml"]`. Esto le indica a Argo CD que utilice el archivo `values.yaml` que se encuentra *junto al chart Helm de la aplicación respectiva* dentro del repositorio `PTI-WellTrackGitOps`. Es en estos archivos `values.yaml` del GitOps donde se define la configuración específica de cada aplicación, incluyendo detalles del `Deployment` (imagen, réplicas), `Service`, y crucialmente, la configuración del `Ingress` (host, paths, anotaciones como `cert-manager.io/cluster-issuer`, y la sección `tls` con `secretName` para HTTPS).
-   **Destino y Sincronización**: También se definen el namespace de destino (ej. `.Values.welltrackFrontend.namespace`), el servidor de destino (`.Values.spec.destination.server` o similar), la política de sincronización y, opcionalmente, la `syncWave` para gestionar el orden de despliegue.

En resumen, estos archivos actúan como "conectores" que definen cómo Argo CD debe desplegar cada componente de infraestructura y cada aplicación principal. La configuración de alto nivel (habilitación, origen) se encuentra en `../values.yaml` (el `values.yaml` raíz de `bootstrap`), la configuración detallada de *infraestructura* está en `../values/`, y la configuración detallada de las *aplicaciones* (incluyendo sus Ingress y TLS) reside en los `values.yaml` de sus charts específicos dentro del repositorio `PTI-WellTrackGitOps`. 