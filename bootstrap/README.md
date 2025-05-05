# Chart Helm Bootstrap (App of Apps)

Este directorio contiene el chart Helm principal (`welltrack-bootstrap`) que implementa el patrón "App of Apps" para gestionar toda la infraestructura de WellTrack.

## Contenido

-   **`Chart.yaml`**: Define los metadatos de este chart Helm (nombre, versión, descripción).
-   **`values.yaml`**: Archivo principal de configuración. Aquí se define:
    -   Configuraciones globales (destino, repositorio fuente, política de sincronización).
    -   Qué componentes (sub-aplicaciones) están habilitados (`enable: true/false`).
    -   Información básica de cada componente para localizar su chart Helm (nombre del chart, repositorio, versión) y su `syncWave`.
-   **`templates/`**: Contiene las plantillas Helm que generan los manifiestos de `Application` de Argo CD para cada uno de los componentes de infraestructura (Ingress, Harbor, Base de Datos, etc.).
-   **`values/`**: Contiene los archivos `values.yaml` específicos y detallados para la configuración de cada componente individual. Estos archivos son incluidos ("inlineados") por las plantillas correspondientes en el directorio `templates/`.

## Funcionamiento

La aplicación Argo CD definida en `../../bootstrap.yaml` apunta a este directorio. Cuando Argo CD sincroniza `welltrack-bootstrap`, procesa este chart Helm:

1.  Lee `bootstrap/values.yaml` para saber qué componentes desplegar.
2.  Para cada componente habilitado, utiliza la plantilla correspondiente en `bootstrap/templates/` para generar un manifiesto de `Application` Argo CD.
3.  Estas plantillas de `Application` referencian el chart Helm real del componente (ej. el chart oficial de Harbor) y utilizan la función `.Files.Get` de Helm para inyectar la configuración específica desde el archivo correspondiente en `bootstrap/values/`.
4.  Argo CD crea entonces estas `Application` secundarias, las cuales a su vez despliegan y gestionan los componentes reales en el cluster Kubernetes. 