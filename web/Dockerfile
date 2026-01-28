# syntax=docker/dockerfile:1
# Build context must be the web directory (e.g. docker-compose: context: ./web, dockerfile: Dockerfile).
# From repo root: docker build -f web/Dockerfile ./web
# For standalone frontend, pass the backend API URL so the app can reach /config:
#   docker build -f web/Dockerfile --build-arg VITE_OPENOBSERVE_ENDPOINT=http://your-api-host:5080 ./web
FROM public.ecr.aws/docker/library/node:24-trixie
WORKDIR /web
COPY . /web/

# Optional: set at build time when serving frontend separately from backend
ARG VITE_OPENOBSERVE_ENDPOINT
ENV VITE_OPENOBSERVE_ENDPOINT=http://103.174.50.21:5080

RUN npm install
RUN NODE_OPTIONS="--max-old-space-size=8192" npm run build

EXPOSE 8081
CMD ["npx", "serve", "-s", "dist", "-l", "8081"]
