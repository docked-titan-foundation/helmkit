# Makefile
REGISTRY      := ghcr.io/docked-titan-foundation
IMAGE_NAME    := helmkit
VERSION       := $(shell cat CHANGELOG.md | grep "## \[" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
IMAGE_REF     := $(REGISTRY)/$(IMAGE_NAME):$(VERSION)
LATEST_REF    := $(REGISTRY)/$(IMAGE_NAME):latest

.PHONY: all build test precommit clean verify scan helm help

all: precommit

build: ## Build the Docker image locally
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--tag $(IMAGE_REF) \
		--tag $(REGISTRY)/$(IMAGE_NAME):latest \
		--build-arg BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ") \
		--build-arg VCS_REF=$(shell git rev-parse --short HEAD) \
		--build-arg APP_VERSION=$(VERSION) \
		--load \
		.

test: ## Run integration tests against the image
	docker run --rm \
		--user 1000:1000 \
		--read-only \
		--tmpfs /tmp:size=100m \
		-v $(PWD)/tests:/tests:ro \
		$(IMAGE_REF) \
		bash /tests/integration/test-helmkit.sh

precommit: ## Run pre-commit hooks
	pre-commit run --all-files

clean: ## Remove local build artifacts
	docker rmi $(IMAGE_REF) $(LATEST_REF) || true

verify: ## Verify cosign signature on the image
	cosign verify $(IMAGE_REF)
	cosign verify $(LATEST_REF)

scan: ## Run Trivy security scan
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION not found. Run 'make build' first or check CHANGELOG.md."; \
		exit 1; \
	fi
	docker build -t helmkit-test .
	trivy image --severity CRITICAL,HIGH --exit-code 1 helmkit-test

helm: ## Run helm inside the container
	docker run --rm $(IMAGE_REF) helm version

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'