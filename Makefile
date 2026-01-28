# Frontend (sherlock-web) and combined (backend + frontend) image build, push, deploy.
# Run from repo root.
#
# Helm router, only change image: use build-combined + push-combined, set router image
# to $(DOCKER_USER)/$(IMAGE_COMBINED):$(TAG). API + our UI, same origin, login works.

IMAGE_NAME     := sherlock-web
IMAGE_COMBINED := sherlock-o2
DOCKER_USER    := sagoresarker
TAG            := v0.0.1
K8S_NS         := openobserve
K8S_DEPLOY     := o2-openobserve-router
K8S_CONTAINER  := openobserve-router

# Optional: API base URL when UI and API are on different hosts (frontend-only build).
VITE_OPENOBSERVE_ENDPOINT ?=

BUILD_ARGS := --platform linux/amd64 -t $(IMAGE_NAME):$(TAG) -f web/Dockerfile ./web
ifdef VITE_OPENOBSERVE_ENDPOINT
BUILD_ARGS += --build-arg VITE_OPENOBSERVE_ENDPOINT=$(VITE_OPENOBSERVE_ENDPOINT)
endif

.PHONY: build push run delete clean deploy deploy-patch deploy-standalone build-combined push-combined

build:
	@ docker build $(BUILD_ARGS)

# Backend + our frontend. Use this image for Helm router; only change the image.
build-combined:
	@ docker build --platform linux/amd64 -t $(IMAGE_COMBINED):$(TAG) -f deploy/build/Dockerfile.combined .

push:
	@ docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_USER)/$(IMAGE_NAME):$(TAG)
	@ docker push $(DOCKER_USER)/$(IMAGE_NAME):$(TAG)

push-combined:
	@ docker tag $(IMAGE_COMBINED):$(TAG) $(DOCKER_USER)/$(IMAGE_COMBINED):$(TAG)
	@ docker push $(DOCKER_USER)/$(IMAGE_COMBINED):$(TAG)

run:
	@ docker run -d --name $(IMAGE_NAME) -p 8080:8080 $(IMAGE_NAME):$(TAG)

delete:
	@ docker stop $(IMAGE_NAME) 2>/dev/null || true
	@ docker rm $(IMAGE_NAME) 2>/dev/null || true

clean:
	@ docker rmi $(IMAGE_NAME):$(TAG) 2>/dev/null || true

# Deploy frontend as a SEPARATE Deployment (recommended).
# Keeps o2-openobserve-router as the API. Use Ingress: / -> openobserve-web, /api|/config|/auth -> router.
# Run 'make push' first.
deploy-standalone:
	@ sed 's|IMAGE_PLACEHOLDER|$(DOCKER_USER)/$(IMAGE_NAME):$(TAG)|g' deploy/k8s/frontend.yaml | kubectl apply -f -
	@ kubectl rollout status deployment/openobserve-web -n $(K8S_NS)

# Replace o2-openobserve-router image with frontend (removes API -> login breaks). Prefer deploy-standalone.
deploy:
	@ docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_USER)/$(IMAGE_NAME):$(TAG)
	@ kubectl set image deployment/$(K8S_DEPLOY) $(K8S_CONTAINER)=$(DOCKER_USER)/$(IMAGE_NAME):$(TAG) -n $(K8S_NS)
	@ kubectl rollout status deployment/$(K8S_DEPLOY) -n $(K8S_NS)

# One-time patch when using 'deploy' (replace router): container port 8080, probes use /.
deploy-patch:
	@ kubectl patch deployment/$(K8S_DEPLOY) -n $(K8S_NS) --type=json \
	  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/ports/0/containerPort","value":8080}]'
	@ kubectl patch deployment/$(K8S_DEPLOY) -n $(K8S_NS) --type=json \
	  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/port","value":8080},{"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/"}]'
	@ kubectl patch deployment/$(K8S_DEPLOY) -n $(K8S_NS) --type=json \
	  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/port","value":8080},{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/"}]'
	@ kubectl patch deployment/$(K8S_DEPLOY) -n $(K8S_NS) --type=json \
	  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/startupProbe/httpGet/port","value":8080},{"op":"replace","path":"/spec/template/spec/containers/0/startupProbe/httpGet/path","value":"/"}]'
