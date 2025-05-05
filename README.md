# WellTrack DevOps Infraestructura

Este proyecto utiliza el patrón "App of Apps" de Argo CD para automatizar el despliegue y la gestión de la infraestructura necesaria para el entorno de desarrollo de WellTrack.

## Arquitectura del Proyecto

El proyecto se basa en Kubernetes y adopta la metodología GitOps. Argo CD se utiliza para implementar la Infraestructura como Código (IaC).

### Componentes Principales

-   **NGINX Ingress Controller**: Enrutamiento del tráfico entrante.
-   **Harbor**: Registro de imágenes de contenedor.
-   **PostgreSQL**: Base de datos relacional.
-   **Prometheus/Grafana**: Monitorización y visualización.
-   **Loki/Promtail**: Recolección y análisis de logs.
-   **Rook/Ceph**: Almacenamiento distribuido.
-   **HashiCorp Vault**: Gestión de secretos.

## Estructura del Proyecto

```
PTI-WellTrackDevops/
├── bootstrap/                # Chart Helm principal (App of Apps)
│   ├── Chart.yaml            # Metadatos del chart Helm
│   ├── values.yaml           # Configuración de las sub-aplicaciones (componentes)
│   ├── templates/            # Plantillas de Application Argo CD para cada componente
│   │   ├── ingress.yaml
│   │   ├── harbor.yaml
│   │   ├── database.yaml
│   │   ├── monitoring.yaml
│   │   ├── logging.yaml
│   │   ├── storage.yaml
│   │   └── vault.yaml
│   └── values/               # Archivos values.yaml específicos de cada componente
│       ├── ingress.yaml
│       ├── harbor.yaml
│       ├── database.yaml
│       ├── monitoring.yaml
│       ├── logging-loki.yaml
│       ├── logging-promtail.yaml
│       ├── storage.yaml
│       └── vault.yaml
├── bootstrap.yaml            # Aplicación Argo CD inicial (punto de entrada)
├── .gitignore                # Archivos y directorios ignorados por Git
└── README.md                 # Documentación principal (este archivo)
```

### Descripción de Directorios y Archivos Clave

-   **`bootstrap/`**: Contiene el chart Helm principal que implementa el patrón "App of Apps".
    -   **`Chart.yaml`**: Define los metadatos del chart `welltrack-bootstrap`.
    -   **`values.yaml`**: Define qué sub-aplicaciones (componentes de infraestructura) están habilitadas y especifica información básica como el chart Helm a usar, su repositorio, versión y `syncWave`.
    -   **`templates/`**: Contiene las plantillas Helm que generan los manifiestos de `Application` de Argo CD para cada componente. Cada archivo define una sub-aplicación.
    -   **`values/`**: Almacena los archivos `values.yaml` detallados para la configuración específica de cada componente (Ingress, Harbor, Loki, etc.). Estos archivos son referenciados e incluidos por las plantillas en `templates/`.
-   **`bootstrap.yaml`**: Es el manifiesto de la `Application` inicial de Argo CD. Define la aplicación "raíz" que Argo CD debe monitorizar. Esta aplicación apunta al directorio `bootstrap/` dentro de este repositorio Git.
-   **`.gitignore`**: Especifica qué archivos no deben ser rastreados por Git (ej. secretos).
-   **`README.md`**: Documentación general del proyecto.

## Proceso de Despliegue

### Prerrequisitos

-   Cluster Kubernetes instalado. **Si utilizas Kind para desarrollo local**, puedes crear un cluster compatible usando la configuración proporcionada:
    -   **Mueve `a-cluster-setup/kind-config.yaml` a la raíz del proyecto.**
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
    # Crear namespace para Argo CD
    kubectl create namespace argocd

    # Añadir repositorio Helm de Argo CD
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update

    # Desplegar Argo CD (puedes ajustar los valores según sea necesario)
    # Ejemplo básico:
    helm install argocd argo/argo-cd -n argocd --create-namespace
    # Si tienes un values.yaml específico para Argo CD:
    # helm install argocd argo/argo-cd -n argocd -f ruta/a/tu/argocd-values.yaml
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
    - Haz clic en "Sync". Argo CD procesará el chart Helm `bootstrap/` y creará las Applications para cada componente.

## Orden de Sincronización (Sync Waves)

Los componentes se despliegan en oleadas (`syncWave`) para gestionar dependencias:

1.  **Ola 1**: `ingress`, `storage`
2.  **Ola 2**: `database`, `harbor`
3.  **Ola 3**: `monitoring`, `logging` (loki, promtail)
4.  **Ola 4**: `vault`

## Configuración de Componentes

La configuración detallada de cada componente se gestiona a través de los archivos `values.yaml` ubicados en el directorio `bootstrap/values/`. Modifica estos archivos para personalizar el comportamiento de cada servicio.

## Acceso a los Servicios Desplegados

Para acceder a los servicios expuestos a través de Ingress, necesitas asegurarte de que los nombres de dominio `.welltrack.local` resuelvan a la dirección IP de tu Ingress Controller.

### Prerrequisito: Configurar Resolución DNS (Archivo Hosts)

1.  **Obtén la IP Externa del Ingress Controller:**
    El método exacto depende de cómo se expone tu servicio Ingress (LoadBalancer, NodePort). Un comando común si usas Nginx Ingress con un Service de tipo LoadBalancer es:
    ```bash
    kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    # O si es NodePort y accedes a través de un nodo específico:
    # NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}') # O usa la IP externa si aplica
    # echo $NODE_IP
    ```
    Reemplaza la IP obtenida (`INGRESS_IP`) en el paso siguiente.

2.  **Modifica tu Archivo Hosts Local:**
    Añade las siguientes líneas a tu archivo hosts. Necesitarás permisos de administrador.
    *   **Linux/macOS:** `/etc/hosts`
    *   **Windows:** `C:\Windows\System32\drivers\etc\hosts`

    ```
    INGRESS_IP grafana.welltrack.local harbor.welltrack.local vault.welltrack.local argocd.welltrack.local prometheus.welltrack.local
    ```
    (Asegúrate de reemplazar `INGRESS_IP` con la IP real obtenida en el paso 1).

### Acceso a Servicios Específicos

Una vez configurada la resolución DNS:

1.  **Argo CD:**
    *   **URL:** `http://argocd.welltrack.local` (o `https://` si has configurado TLS)
    *   **Usuario:** `admin`
    *   **Contraseña:** Obtener la contraseña inicial:
        ```bash
        kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
        ```

2.  **Grafana:**
    *   **URL:** `http://grafana.welltrack.local`
    *   **Usuario:** `admin`
    *   **Contraseña:** Obtener la contraseña inicial:
        ```bash
        kubectl get secret --namespace monitoring prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
        ```

3.  **Prometheus:**
    *   **URL:** `http://prometheus.welltrack.local`
    *   Accede a esta URL en tu navegador para ver la interfaz de usuario de Prometheus.

4.  **Harbor:**
    *   **URL:** `http://harbor.welltrack.local`
    *   **Usuario:** `admin`
    *   **Contraseña:** `Harbor12345` (Según `bootstrap/values/harbor.yaml`. **¡IMPORTANTE!** Esta es una contraseña insegura por defecto, ¡cámbiala en un entorno real!).

5.  **Vault:**
    *   **URL:** `http://vault.welltrack.local`
    *   **Acceso:** Vault en modo dev (`dev.enabled: true` en `bootstrap/values/vault.yaml`) se auto-desella y tiene un token raíz predefinido. Para obtenerlo:
        *   Revisa los logs del pod `vault-0` poco después de su inicio:
            ```bash
            kubectl logs -n vault vault-0
            ```
            Busca una línea que contenga `Root Token: <tu-token-raiz>`.
        *   Utiliza este token para iniciar sesión en la UI o CLI.
    *   **Nota:** El modo dev **NO** es para producción. La configuración de almacenamiento (`file`) tampoco es adecuada para producción.


Copyright @Hongda Zhu