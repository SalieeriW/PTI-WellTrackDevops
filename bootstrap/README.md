# Plantillas de Aplicación Argo CD (Sub-Aplicaciones)

Este directorio contiene las plantillas Helm que definen los recursos `Application` de Argo CD para cada **componente de infraestructura** (Ingress, Harbor, Base de Datos, etc.) y para las **aplicaciones principales** de WellTrack (Frontend, Backend, ML, etc.).

## Funcionamiento

Cada archivo `.yaml` en este directorio es una plantilla Helm que genera un manifiesto `Application` de Argo CD.

-   **Control de Habilitación**: La generación de cada `Application` está condicionada por la variable `enabled` correspondiente en el archivo `../values.yaml` (ej. `{{- if .Values.ingress.enabled }}` o `{{- if .Values.welltrackFrontend.enabled }}`).
-   **Definición de la Fuente**: Cada plantilla utiliza valores de `../values.yaml` para especificar la fuente de los manifiestos o chart del componente/aplicación:
    -   Para **componentes de infraestructura**: Normalmente se especifica `chart`, `repoURL` y `targetRevision` para un chart Helm externo.
    -   Para **aplicaciones principales** (frontend, backend): Normalmente se especifica `repoURL` (apuntando a `PTI-WellTrackGitOps`), `path` (al chart dentro de GitOps) y `targetRevision`.
-   **Inyección de Configuración (Infraestructura)**: Para los componentes de infraestructura, en lugar de usar `valueFiles`, estas plantillas pueden utilizar la sección `helm.values` junto con la función `.Files.Get` de Helm:
    ```yaml
    helm:
      values: |
    {{ .Files.Get "values/<componente>.yaml" | indent 8 }}
    ```
    Esto lee el contenido del archivo de configuración específico del componente desde el directorio `../values/` (dentro de *este* chart `bootstrap`) y lo inyecta directamente como los valores para renderizar el chart Helm del componente de infraestructura.
-   **Inyección de Configuración (Aplicaciones)**: Para las aplicaciones principales (frontend, backend), la plantilla normalmente especifica `helm.valueFiles: ["values.yaml"]`. Esto le indica a Argo CD que utilice el archivo `values.yaml` que se encuentra *junto al chart* dentro del repositorio `PTI-WellTrackGitOps`. Este es el archivo que actualizan los pipelines de CI/CD.
-   **Destino y Sincronización**: También se definen el namespace de destino (ej. `.Values.welltrackFrontend.namespace`), el servidor de destino (`.Values.spec.destination.server` o similar), la política de sincronización y, opcionalmente, la `syncWave`.

En resumen, estos archivos actúan como "conectores" que definen cómo Argo CD debe desplegar cada componente de infraestructura y cada aplicación principal, utilizando la configuración de alto nivel en `../values.yaml`, la configuración detallada de infraestructura en `../values/`, y dejando que Argo CD lea la configuración detallada de las aplicaciones desde el repositorio `PTI-WellTrackGitOps`. 