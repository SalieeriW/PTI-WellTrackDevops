**A continuación se indican los pasos para añadir Loki como fuente de datos (data source) en Grafana:**

1.  **Inicia sesión en Grafana:** Abre tu interfaz de usuario de Grafana e inicia sesión.
2.  **Navega a Fuentes de Datos (Data Sources):** Normalmente, encontrarás el icono del engranaje (Configuración) en la barra de menú lateral izquierda.
    * Haz clic en "Data Sources".
3.  **Añade una nueva fuente de datos:** Haz clic en el botón "Add data source".
4.  **Busca y selecciona "Loki"** en la lista.
5.  **Configura la fuente de datos Loki:**
    * **Nombre (Name):** Dale un nombre descriptivo a esta fuente de datos, por ejemplo, `Loki`, `Logs del Cluster` o `Servicio de Logs`.
    * **URL (¡Lo más importante!):** Esta es la clave para conectar Grafana y Loki. Según la información de salida durante la instalación de Loki, si Grafana se está ejecutando **en el mismo clúster de Kubernetes**, deberías usar la dirección del Service de Kubernetes para el Loki Gateway:
        ```
        http://loki-gateway.logging.svc.cluster.local
        ```
        * **Nota:** `loki-gateway` es el nombre del servicio, `logging` es el namespace (espacio de nombres), y `svc.cluster.local` es el sufijo de dominio interno estándar del clúster de Kubernetes. Asegúrate de que esta dirección sea accesible para tu Pod de Grafana.
        * Si tu Grafana está desplegado fuera del clúster, necesitarás exponer el servicio Loki Gateway mediante un Ingress, LoadBalancer o Port-forwarding, y usar la dirección externa accesible correspondiente.
    * **Autenticación (Authentication):** Si tu Loki Gateway tiene configurada autenticación (por ejemplo, Basic Auth), necesitarás configurar las credenciales correspondientes aquí. La instalación por defecto normalmente no requiere autenticación interna.
    * **Otras configuraciones:** Puedes ajustar otras configuraciones según sea necesario, pero la URL es lo fundamental.
6.  **Guardar y Probar (Save & test):** Haz clic en el botón "Save & test" en la parte inferior de la página.
    * Grafana intentará conectarse a la URL de Loki que has proporcionado. Si la conexión es exitosa, mostrará un mensaje de éxito en verde. Si falla, comprueba si la URL es correcta, si las políticas de red (Network Policies) permiten al Pod de Grafana acceder al Service de Loki Gateway, y si los Pods de Loki están funcionando correctamente.
7.  **Empezar a consultar:** Una vez añadida la fuente de datos con éxito, podrás seleccionarla en la vista "Explore" de Grafana y usar el lenguaje de consulta LogQL para buscar y analizar los logs enviados a Loki por Promtail.

---