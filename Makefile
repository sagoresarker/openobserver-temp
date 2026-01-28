# Frontend (openobserve-web) image build, push, and K8s deploy.
# Run from repo root. Build context: ./web.
#
# Deploy: updates o2-openobserve-router image to use this frontend.
# If the router deployment uses port 5080 for probes, you may need to patch
# the container port to 8080 (frontend listens on 8080). See deploy-patch.

IMAGE_NAME   := sherlock-web
DOCKER_USER  := sagoresarker
TAG          := v0.0.1
K8S_NS       := openobserve
K8S_DEPLOY   := o2-openobserve-router
K8S_CONTAINER:= openobserve-router

# Optional: API base URL when UI and API are on different hosts.
# make build VITE_OPENOBSERVE_ENDPOINT=https://api.o2.example.com
VITE_OPENOBSERVE_ENDPOINT ?=

BUILD_ARGS := --platform linux/amd64 -t $(IMAGE_NAME):$(TAG) -f web/Dockerfile ./web
ifdef VITE_OPENOBSERVE_ENDPOINT
BUILD_ARGS += --build-arg VITE_OPENOBSERVE_ENDPOINT=$(VITE_OPENOBSERVE_ENDPOINT)
endif

.PHONY: build push run delete clean deploy deploy-patch

build:
	@ docker build $(BUILD_ARGS)

push:
	@ docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_USER)/$(IMAGE_NAME):$(TAG)
	@ docker push $(DOCKER_USER)/$(IMAGE_NAME):$(TAG)

run:
	@ docker run -d --name $(IMAGE_NAME) -p 8080:8080 $(IMAGE_NAME):$(TAG)

delete:
	@ docker stop $(IMAGE_NAME) 2>/dev/null || true
	@ docker rm $(IMAGE_NAME) 2>/dev/null || true

clean:
	@ docker rmi $(IMAGE_NAME):$(TAG) 2>/dev/null || true

# Update o2-openobserve-router to use the frontend image.
# Run 'make push' first so the cluster can pull the image.
deploy:
	@ docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_USER)/$(IMAGE_NAME):$(TAG)
	@ kubectl set image deployment/$(K8S_DEPLOY) $(K8S_CONTAINER)=$(DOCKER_USER)/$(IMAGE_NAME):$(TAG) -n $(K8S_NS)
	@ kubectl rollout status deployment/$(K8S_DEPLOY) -n $(K8S_NS)

# One-time patch: container port 8080, probes use / (frontend has no /healthz).
# Run after changing the router image to the frontend.
deploy-patch:
	@ kubectl patch deployment/$(K8S_DEPLOY) -n $(K8S_NS) --type=json \
	  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/ports/0/containerPort","value":8080}]'
	@ kubectl patch deployment/$(K8S_DEPLOY) -n $(K8S_NS) --type=json \
	  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/port","value":8080},{"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/"}]'
	@ kubectl patch deployment/$(K8S_DEPLOY) -n $(K8S_NS) --type=json \
	  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/port","value":8080},{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/"}]'
	@ kubectl patch deployment/$(K8S_DEPLOY) -n $(K8S_NS) --type=json \
	  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/startupProbe/httpGet/port","value":8080},{"op":"replace","path":"/spec/template/spec/containers/0/startupProbe/httpGet/path","value":"/"}]'
