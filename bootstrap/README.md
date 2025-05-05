# Plantillas de Aplicación Argo CD (Sub-Aplicaciones)

Este directorio contiene las plantillas Helm que definen los recursos `Application` de Argo CD para cada componente de la infraestructura de WellTrack (Ingress, Harbor, Base de Datos, Monitorización, Logging, Almacenamiento, Vault).

## Funcionamiento

Cada archivo `.yaml` en este directorio es una plantilla Helm que genera un manifiesto `Application` de Argo CD.

-   **Control de Habilitación**: La generación de cada `Application` está condicionada por la variable `enable` correspondiente en el archivo `../values.yaml` (ej. `{{- if .Values.spec.ingress.enable }}`).
-   **Definición de la Fuente**: Cada plantilla utiliza valores de `../values.yaml` para especificar:
    -   El chart Helm real del componente (`.Values.spec.<componente>.chart`).
    -   El repositorio Helm donde se encuentra el chart (`.Values.spec.<componente>.repoURL`).
    -   La versión específica del chart a desplegar (`.Values.spec.<componente>.targetRevision`).
-   **Inyección de Configuración**: En lugar de usar `valueFiles` (que busca archivos en el repositorio del *chart* del componente), estas plantillas utilizan la sección `helm.values` junto con la función `.Files.Get` de Helm:
    ```yaml
    helm:
      values: |
    {{ .Files.Get "values/<componente>.yaml" | indent 8 }}
    ```
    Esto lee el contenido del archivo de configuración específico del componente desde el directorio `../values/` (dentro de *este* chart `bootstrap`) y lo inyecta directamente como un bloque de texto YAML en la definición de la `Application`. Argo CD usará este YAML como los valores para renderizar el chart Helm del componente.
-   **Destino y Sincronización**: También se definen el namespace de destino (`.Values.spec.<componente>.namespace`), el servidor de destino (`.Values.spec.destination.server`), la política de sincronización y la `syncWave` (`.Values.spec.<componente>.syncWave`).

En resumen, estos archivos actúan como "conectores" que definen cómo Argo CD debe desplegar cada componente, utilizando la configuración centralizada en `../values.yaml` y la configuración detallada en `../values/`. 