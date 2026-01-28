# Frontend Docker images for Kubernetes

## Helm deployment: only change the image

You use **Helm** for the router and **only change the image**. To fix **login** and **static assets**:

1. **Use the combined image** (backend + our frontend), not the frontend-only image.
2. Build and push it, then set the Helm router image to that tag.

### Build and push combined image

From **repo root**:

```bash
make build-combined
make push-combined
```

This builds `deploy/build/Dockerfile.combined`: OpenObserve backend + our web app. The UI is built with **base /web/** (backend serves UI at `/web/`). API and UI are same origin → **login works**, assets load.

### Set Helm router image

Point the `o2-openobserve-router` image to the combined image, e.g.:

- `sagoresarker/sherlock-o2:v0.0.1`

(Use your `DOCKER_USER` / `IMAGE_COMBINED` / `TAG` from the Makefile.)

Then upgrade your Helm release so the router uses that image. No extra manifests, no Ingress changes.

---

## Base path (static assets)

- **Combined image:** Built with `VITE_BASE_PATH=/web/`. UI at `/web/`, assets at `/web/assets/...`. Handled by `Dockerfile.combined`.
- **Frontend-only image:** Built with `VITE_BASE_PATH=/` by default. Use when serving the app at **root** (e.g. standalone `serve`). Override with `--build-arg VITE_BASE_PATH=/subpath/` if served under a subpath.

---

## Frontend-only image (no backend)

The **frontend-only** image (`make build` / `make push`) is for running **only** the UI (e.g. separate Deployment, `serve`). It has **no** API → **login will not work** if you use it as the router image.

Use the **combined** image for the Helm router when you only change the image.

---

## Makefile targets

| Target | Description |
|--------|-------------|
| `make build` | Frontend-only image (web/Dockerfile). |
| `make build-combined` | **Backend + frontend** (use for Helm router). |
| `make push` | Push frontend-only image. |
| `make push-combined` | Push combined image. |
| `make deploy` | Replace router image with frontend-only (**removes API**, use only if API is elsewhere). |
| `make deploy-standalone` | Deploy frontend as separate Deployment; router stays as API. |

For **Helm, only change the image**: use `build-combined` + `push-combined`, then set the router image to the combined tag.
