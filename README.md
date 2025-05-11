# WellTrack DevOps Infraestructura

Este proyecto utiliza el patrón "App of Apps" de Argo CD para automatizar el despliegue y la gestión de la infraestructura necesaria para el entorno de desarrollo de WellTrack.

## Arquitectura del Proyecto

El proyecto se basa en Kubernetes y adopta la metodología GitOps. Argo CD se utiliza para implementar la Infraestructura como Código (IaC).

### Componentes de Infraestructura Gestionados

-   **NGINX Ingress Controller**: Enrutamiento del tráfico entrante.
-   **Harbor**: Registro de imágenes de contenedor privado.
-   **PostgreSQL**: Base de datos relacional.
-   **Prometheus/Grafana**: Monitorización y visualización.
-   **Loki/Promtail**: Recolección y análisis de logs.
-   **Rook/Ceph**: Almacenamiento distribuido.
-   **HashiCorp Vault**: Gestión de secretos.
-   **Falco**: Seguridad en tiempo de ejecución y detección de anomalías.

### Aplicaciones WellTrack Gestionadas

-   **welltrack-frontend**: La interfaz de usuario de la aplicación. (Expuesto en `app.welltrack.local`)
-   **welltrack-backend**: La API y lógica de negocio del backend. (Expuesto en `api.welltrack.local`)
-   **welltrack-ml**: El servicio de Machine Learning. (Puede ser expuesto en `ml.welltrack.local`)

La *definición* del despliegue de estas aplicaciones (es decir, la creación de sus `Application` en Argo CD) se gestiona aquí, pero sus *charts Helm específicos* (incluyendo su configuración de Ingress y TLS) residen en el repositorio `PTI-WellTrackGitOps`.

## Estructura del Proyecto

```
PTI-WellTrackDevops/
├── bootstrap/                # Chart Helm principal (App of Apps)
│   ├── Chart.yaml            # Metadatos del chart Helm
│   ├── values.yaml           # Configuración de habilitación/deshabilitación y fuentes globales/spec
│   ├── README.md             # README específico del directorio bootstrap/templates
│   ├── templates/            # Plantillas de Application Argo CD para cada componente y aplicación
│   │   ├── ingress.yaml
│   │   ├── harbor.yaml
│   │   ├── database.yaml
│   │   ├── monitoring.yaml
│   │   ├── logging.yaml
│   │   ├── storage.yaml
│   │   ├── vault.yaml
│   │   ├── cert-manager.yaml
│   │   ├── falco.yaml
│   │   # Descomentar si external-secrets está habilitado en values.yaml
│   │   # ├── external-secrets-app.yaml
│   │   ├── welltrack-frontend-app.yaml # Plantilla para App Frontend
│   │   ├── welltrack-backend-app.yaml  # Plantilla para App Backend
│   │   └── welltrack-ml-app.yaml     # Plantilla para App ML
│   └── values/               # Archivos values.yaml específicos de cada componente de INFRAESTRUCTURA
│       ├── ingress.yaml
│       ├── harbor.yaml
│       ├── database.yaml
│       ├── monitoring.yaml
│       ├── logging.yaml
│       ├── storage.yaml
│       └── vault.yaml
│       └── falco.yaml
│       # ... (etc.)
├── bootstrap.yaml            # Aplicación Argo CD inicial (punto de entrada)
├── kind-config.yaml          # (Opcional) Configuración para crear un cluster Kind local
├── .gitignore                # Archivos y directorios ignorados por Git
└── README.md                 # Documentación principal (este archivo)
```

### Descripción de Directorios y Archivos Clave

-   **`bootstrap/`**: Contiene el chart Helm principal que implementa el patrón "App of Apps".
    -   **`Chart.yaml`**: Define los metadatos del chart `bootstrap`.
    -   **`values.yaml`**: Define qué componentes de infraestructura y aplicaciones están habilitados (`enabled: true/false` en el nivel superior). Especifica información clave como el namespace, chart/repositorio/path de origen y `syncWave` para cada componente dentro de la sección `spec:`. También puede contener configuraciones globales.
    -   **`templates/`**: Contiene las plantillas Helm que generan los manifiestos de `Application` de Argo CD para cada componente de infraestructura (Ingress, Vault, etc.) y para cada aplicación final (frontend, backend). Cada archivo `.yaml` aquí define una sub-aplicación gestionada por Argo CD. Consulta `bootstrap/README.md` para más detalles sobre cómo funcionan estas plantillas.
    -   **`values/`**: Almacena los archivos `values.yaml` detallados para la configuración específica de los charts Helm de los componentes de *infraestructura* (Ingress, Harbor, Loki, etc.). Estos archivos son referenciados e incluidos por las plantillas correspondientes en `templates/` mediante `helm.values` y `.Files.Get`. La configuración específica de las *aplicaciones* (frontend/backend) reside en sus respectivos `values.yaml` dentro del repositorio `PTI-WellTrackGitOps` y se referencia usando `helm.valueFiles`.
-   **`bootstrap.yaml`**: Es el manifiesto de la `Application` inicial de Argo CD. Define la aplicación "raíz" (`welltrack-bootstrap`) que Argo CD debe monitorizar. Esta aplicación apunta al directorio `bootstrap/` dentro de este repositorio Git.
-   **`kind-config.yaml`**: Configuración opcional para crear un cluster local con Kind para desarrollo.
-   **`.gitignore`**: Especifica qué archivos no deben ser rastreados por Git.
-   **`README.md`**: Documentación general del proyecto.

## Proceso de Despliegue

### Prerrequisitos

-   Cluster Kubernetes instalado. **Si utilizas Kind para desarrollo local**, puedes crear un cluster compatible usando la configuración proporcionada:
    -   **(Opcional) Asegúrate de tener `kind-config.yaml` en la raíz del proyecto.**
    -   Ejecuta el siguiente comando:
        ```bash
        kind create cluster --config kind-config.yaml --name welltrack-local
        ```
    -   Verifica la conexión:
        ```bash
        kubectl cluster-info --context kind-welltrack-local
        kubectl get nodes
        ```
-   Helm 3 instalado.
-   `kubectl` configurado y conectado al cluster.

### Pasos de Despliegue

1.  **Desplegar Argo CD** (si aún no está desplegado)
    ```bash
    kubectl create namespace argocd
    # Recomendado usar Helm para instalar Argo CD
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update
    # Reemplaza <version> con la versión deseada del chart de Argo CD
    helm install argocd argo/argo-cd -n argocd --create-namespace -f bootstrap/values/argocd.yaml --version <version> 
    # Alternativamente, si no usas Helm o quieres una instalación rápida (menos configurable):
    # kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml 
    ```

2.  **Aplicar la Aplicación Bootstrap**
    Una vez que Argo CD esté funcionando, aplica la aplicación raíz:
    ```bash
    kubectl apply -f bootstrap.yaml
    ```
    Esto le indicará a Argo CD que monitorice el directorio `bootstrap/` en tu repositorio Git.

3.  **Sincronizar en Argo CD UI**
    - Accede a la UI de Argo CD (ver sección "Acceso a los Servicios Desplegados").
    - Busca la aplicación `welltrack-bootstrap`.
    - Haz clic en "Sync". Argo CD procesará el chart Helm `bootstrap/` y creará las `Application` para cada componente de infraestructura y aplicación habilitado.
    - Las `Application` de los componentes de infraestructura apuntarán a sus respectivos charts Helm (definidos en `bootstrap/values.yaml` bajo `spec:`).
    - Las `Application` para `welltrack-frontend`, `welltrack-backend`, y `welltrack-ml` apuntarán a sus charts Helm dentro del repositorio `PTI-WellTrackGitOps`, usando los `values.yaml` de ese repositorio.

## Orden de Sincronización (Sync Waves)

Los componentes se despliegan en oleadas (`syncWave`) para gestionar dependencias, según lo definido en `bootstrap/values.yaml` bajo la sección `spec:`. El orden típico configurado es:

1.  **Ola 1**: `ingress` (namespace: `ingress-nginx`), `storage` (namespace: `rook-ceph`)
2.  **Ola 2**: `database` (namespace: `database`), `harbor` (namespace: `harbor`)
3.  **Ola 3**: `monitoring` (namespace: `monitoring`), `logging` (namespace: `logging`)
4.  **Ola 4**: `vault` (namespace: `vault`), `falco` (namespace: `falco`)
5.  **Aplicaciones**: `welltrack-backend`, `welltrack-frontend`, y `welltrack-ml` (en namespace `welltrack`) - Se despliegan después de las olas de infraestructura. Pueden tener `syncWave` asignada en `bootstrap/values.yaml` si es necesario gestionar dependencias más específicas con componentes de infraestructura.

*Nota: Revisa los valores `syncWave` en `bootstrap/values.yaml` para el orden exacto.*

## Configuración de Componentes

La configuración detallada de cada componente de *infraestructura* se gestiona a través de los archivos `values.yaml` ubicados en el directorio `bootstrap/values/`. La configuración de las *aplicaciones* (frontend/backend) se gestiona en sus respectivos `values.yaml` dentro del repositorio `PTI-WellTrackGitOps`.

## Acceso a los Servicios Desplegados

Para acceder a los servicios expuestos a través de Ingress, necesitas asegurarte de que los nombres de dominio `.welltrack.local` resuelvan a la dirección IP de tu Ingress Controller.

### Prerrequisito: Configurar Resolución DNS (Archivo Hosts)

1.  **Obtén la IP Externa del Ingress Controller:**
    El método exacto depende de cómo se expone tu servicio Ingress (LoadBalancer, NodePort). Un comando común si usas Nginx Ingress con un Service de tipo LoadBalancer es:
    ```bash
    kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    # Si la IP no aparece inmediatamente, espera unos momentos.
    # Si usas Kind y `extraPortMappings`, la IP será localhost (127.0.0.1).
    # Si usas NodePort, necesitas la IP de uno de los nodos y el NodePort:
    # NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}') # O usa la IP externa si aplica
    # NODE_PORT=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}') # Para HTTP
    # echo "Accede via http://$NODE_IP:$NODE_PORT"
    ```
    Reemplaza la IP obtenida (`INGRESS_IP`, que podría ser `127.0.0.1` si usas Kind) en el paso siguiente.

2.  **Modifica tu Archivo Hosts Local:**
    Añade las siguientes líneas a tu archivo hosts. Necesitarás permisos de administrador.
    *   **Linux/macOS:** `sudo nano /etc/hosts`
    *   **Windows:** Abrir Notepad como Administrador y editar `C:\Windows\System32\drivers\etc\hosts`

    ```
    # Reemplaza INGRESS_IP con la IP real (p.ej., 127.0.0.1 para Kind con port-mapping)
    INGRESS_IP grafana.welltrack.local harbor.welltrack.local vault.welltrack.local argocd.welltrack.local prometheus.welltrack.local alertmanager.welltrack.local app.welltrack.local api.welltrack.local ml.welltrack.local
    ```
    *(Asegúrate de incluir `app.welltrack.local` para el frontend, `api.welltrack.local` para el backend, `ml.welltrack.local` para el servicio de ML, y cualquier otro dominio que uses si los expones vía Ingress).*

### Acceso a Servicios Específicos

Una vez configurada la resolución DNS:

1.  **Argo CD:**
    *   **URL:** `https://argocd.welltrack.local` (Según `bootstrap/values/argocd.yaml`. HTTPS gestionado por cert-manager).
    *   **Usuario:** `admin`
    *   **Contraseña:** Obtener la contraseña inicial:
        ```bash
        kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
        ```

2.  **Aplicación Frontend WellTrack:**
    *   **URL:** `https://app.welltrack.local`
    *   **Nota:** Utiliza HTTPS. Dado que el certificado es autofirmado (gestionado por `cert-manager` con `selfsigned-cluster-issuer`), tu navegador mostrará una advertencia de seguridad que deberás aceptar.

3.  **API Backend WellTrack:**
    *   **URL Base:** `https://api.welltrack.local`
    *   **Ejemplo Endpoint de Salud:** `https://api.welltrack.local/health` (o la ruta que hayas configurado)
    *   **Nota:** Utiliza HTTPS con certificado autofirmado. Tu navegador o cliente API mostrará una advertencia de seguridad. Para `curl`, usa la opción `-k` o `--insecure`.
    *   La API puede requerir autenticación adicional (ej. API Key) según su implementación.

4.  **Servicio ML WellTrack:**
    *   **URL Base:** `https://ml.welltrack.local`
    *   **Ejemplo Endpoint:** `https://ml.welltrack.local/` (o la ruta principal de tu servicio ML)
    *   **Nota:** Utiliza HTTPS con certificado autofirmado. Aplican las mismas consideraciones de advertencia de seguridad que para el frontend y backend.
    *   Puede requerir autenticación específica si está implementada en el servicio ML.

5.  **Grafana:**
    *   **URL:** `https://grafana.welltrack.local` (Asumiendo que el Ingress está configurado en `bootstrap/values/monitoring.yaml` y actualizado para HTTPS).
    *   **Usuario:** `admin`
    *   **Contraseña:** Depende de la configuración del chart `kube-prometheus-stack`. A menudo se guarda en un secret:
        ```bash
        # El nombre del secret puede variar ligeramente según la versión del chart
        kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
        ```

6.  **Prometheus:**
    *   **URL:** `https://prometheus.welltrack.local` (Asumiendo Ingress configurado y actualizado para HTTPS).
    *   Accede a esta URL en tu navegador para ver la interfaz de usuario de Prometheus.

7.  **Harbor:**
    *   **URL:** `https://harbor.welltrack.local` (Asumiendo Ingress configurado en `bootstrap/values/harbor.yaml` y actualizado para HTTPS).
    *   **Usuario:** `admin`
    *   **Contraseña:** La definida en `bootstrap/values/harbor.yaml` (ej. `Harbor12345`). **¡IMPORTANTE!** Cambia la contraseña por defecto en entornos reales.

8.  **Vault:**
    *   **URL:** `https://vault.welltrack.local` (Según `bootstrap/values/vault.yaml` y actualizado para HTTPS).
    *   **Acceso (Modo Dev):** Si Vault está en modo dev (`server.dev.enabled: true` en `bootstrap/values/vault.yaml`), se auto-desella y tiene un token raíz predefinido. Para obtenerlo:
        *   Revisa los logs del pod `vault-0` poco después de su inicio:
            ```bash
            kubectl logs -n vault vault-0
            ```
            Busca una línea que contenga `Root Token: <tu-token-raiz>`.
        *   Utiliza este token para iniciar sesión en la UI o CLI.
    *   **Nota:** El modo dev **NO** es para producción. La configuración de almacenamiento (`storage.type: file`) tampoco es adecuada para producción. Revisa `bootstrap/values/vault.yaml` para la configuración exacta.

## Contribuciones

Las contribuciones son bienvenidas. Por favor, sigue las prácticas estándar de Git (fork, branch, pull request).

---
Copyright @Hongda Zhu