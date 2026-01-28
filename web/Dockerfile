# syntax=docker/dockerfile:1
# Frontend-only image for Kubernetes (or any container runtime).
# Build context must be the web directory.
#
# Build (from repo root):
#   docker build -f web/Dockerfile -t <your-registry>/openobserve-web:<tag> ./web
#
# Kubernetes – API same origin (Ingress serves UI + API on same host):
#   No build-arg. App uses window.location.origin for API.
#   docker build -f web/Dockerfile -t <image> ./web
#
# Kubernetes – API different host (e.g. API at https://o2-api.example.com):
#   Pass API base URL at build time (must be reachable from the user's browser):
#   docker build -f web/Dockerfile \
#     --build-arg VITE_OPENOBSERVE_ENDPOINT=https://o2-api.example.com \
#     -t <image> ./web
#
# ------------------------------------------------------------------------------

FROM public.ecr.aws/docker/library/node:24-alpine AS builder
WORKDIR /web

# Install deps (including devDependencies for build).
# Use npm install so build works when package-lock.json is out of sync with package.json.
# For reproducible builds, run "npm install" in web/ locally and commit package-lock.json, then switch to "npm ci".
COPY package.json package-lock.json* ./
RUN npm install

# App source
COPY . .

# Base path for assets (use "/" when served at root; fixes static assets not loading).
ARG VITE_BASE_PATH=/
ENV VITE_BASE_PATH=${VITE_BASE_PATH}

# API base URL: set at build time for K8s when UI and API are on different hosts.
# Omit for same-origin setup (Ingress serves both on same host).
ARG VITE_OPENOBSERVE_ENDPOINT
ENV VITE_OPENOBSERVE_ENDPOINT=${VITE_OPENOBSERVE_ENDPOINT}

RUN NODE_OPTIONS="--max-old-space-size=8192" npm run build

# ------------------------------------------------------------------------------
# Serve static assets
# ------------------------------------------------------------------------------
FROM public.ecr.aws/docker/library/node:24-alpine AS serve
WORKDIR /app

RUN npm install -g serve

COPY --from=builder /web/dist ./dist

EXPOSE 8080

# SPA: fallback to index.html for client-side routing
CMD ["serve", "-s", "dist", "-l", "8080"]
