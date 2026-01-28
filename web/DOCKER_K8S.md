# Frontend Docker image for Kubernetes

Build context: **`./web`** (run from repo root).

## Makefile (build, push, deploy)

Use `Makefile.web` at repo root to build, push, and update **o2-openobserve-router** to use the frontend image:

```bash
# From repo root
make -f Makefile.web build          # Build image (linux/amd64)
make -f Makefile.web push           # Tag and push to Docker Hub
make -f Makefile.web deploy         # Set o2-openobserve-router image and rollout
make -f Makefile.web deploy-patch   # One-time: container port 8080, probes use /
```

Override image/tag/user:

```bash
make -f Makefile.web build IMAGE_NAME=openobserve-web DOCKER_USER=sagoresarker TAG=v0.0.2
make -f Makefile.web build VITE_OPENOBSERVE_ENDPOINT=https://api.o2.example.com  # API on different host
```

After changing the router to the frontend image, run **`deploy-patch`** once so the deployment uses port 8080 and probes `path: /` (the frontend has no `/healthz`).

---

## Build

```bash
# From repo root
docker build -f web/Dockerfile -t <your-registry>/openobserve-web:<tag> ./web
```

## API endpoint (VITE_OPENOBSERVE_ENDPOINT)

Vite bakes the API base URL at **build time**. Choose one:

### Same origin (recommended for K8s)

UI and API are served from the **same host** (e.g. Ingress routes `/` → frontend, `/api` → `o2-openobserve-router`). The app uses `window.location.origin` for the API.

```bash
docker build -f web/Dockerfile -t <image> ./web
```

Do **not** pass `VITE_OPENOBSERVE_ENDPOINT`.

### API on a different host

UI and API have different URLs (e.g. UI at `https://app.o2.example.com`, API at `https://api.o2.example.com`). The value must be **reachable from the user’s browser** (e.g. Ingress or LoadBalancer URL), not cluster-internal DNS.

```bash
docker build -f web/Dockerfile \
  --build-arg VITE_OPENOBSERVE_ENDPOINT=https://api.o2.example.com \
  -t <image> ./web
```

## Kubernetes example

- Backend: existing `o2-openobserve-router` (Helm), service `o2-openobserve-router`, port 5080.
- Frontend: separate Deployment using this image, port 8080.

**Same-origin setup:** Configure your Ingress so that:
- `https://o2.example.com/` → frontend Service (port 8080)
- `https://o2.example.com/api` → `o2-openobserve-router` (port 5080)

Then build the frontend image **without** `VITE_OPENOBSERVE_ENDPOINT`.

**Minimal Deployment + Service:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: openobserve-web
  namespace: openobserve
spec:
  replicas: 1
  selector:
    matchLabels:
      app: openobserve-web
  template:
    metadata:
      labels:
        app: openobserve-web
    spec:
      containers:
        - name: web
          image: <your-registry>/openobserve-web:<tag>
          ports:
            - containerPort: 8080
              name: http
          resources:
            {}
---
apiVersion: v1
kind: Service
metadata:
  name: openobserve-web
  namespace: openobserve
spec:
  selector:
    app: openobserve-web
  ports:
    - port: 80
      targetPort: 8080
      name: http
```

Point your Ingress (or router) at the `openobserve-web` Service for the UI path.
