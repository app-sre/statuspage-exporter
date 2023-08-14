SHELL				:= /bin/bash
NAME				:= statuspage-exporter
REPO				:= quay.io/app-sre/$(NAME)
TAG					:= $(shell git rev-parse --short HEAD)

CONTAINER_ENGINE    ?= $(shell which podman >/dev/null 2>&1 && echo podman || echo docker)
PKGS				:= $(shell go list ./... | grep -v -E '/vendor/|/test')

.PHONY: build
build:
	go build -o $(NAME) cmd/statuspage-exporter/main.go

.PHONY: image
image:
ifeq ($(CONTAINER_ENGINE), podman)
	@DOCKER_BUILDKIT=1 $(CONTAINER_ENGINE) build --no-cache -f ./Containerfile -t $(REPO):latest . --progress=plain
else
	@DOCKER_BUILDKIT=1 $(CONTAINER_ENGINE) --config=$(DOCKER_CONF) build --no-cache -f ./Containerfile -t $(REPO):latest . --progress=plain
endif
	@$(CONTAINER_ENGINE) tag $(REPO):latest $(REPO):$(TAG)

run:
	@source env.sh && go run cmd/statuspage-exporter/main.go -page-id $(PAGE_ID)


.PHONY: image-push
image-push:
	$(CONTAINER_ENGINE) --config=$(DOCKER_CONF) push $(REPO):$(TAG)
	$(CONTAINER_ENGINE) --config=$(DOCKER_CONF) push $(REPO):latest

.PHONY: kube
kube: build
	${CONTAINER_ENGINE} kube down exporter.yaml || true
	${CONTAINER_ENGINE} kube play exporter.yaml --build=true

.PHONY: clean
clean:
	rm -f ./statuspage-exporter

###########
# Testing #
###########

.PHONY: vet
vet:
	go vet ./...

.PHONY: test
test: vet test-unit

.PHONY: test-unit
test-unit:
	go test -race -short $(PKGS) -count=1
