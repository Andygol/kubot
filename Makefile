.DEFAULT_GOAL := help
SHELL := /bin/bash

APP = $(shell basename $(shell git remote get-url origin) .git)

VERSION = $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
BUILD_DIR = out
REGISTRY = ghcr.io/andygol

ARGS1 := $(word 1,$(MAKECMDGOALS)) 
ARGS2 := $(word 2,$(MAKECMDGOALS))

TARGETOS ?= $(if $(filter apple,$(ARGS1)),darwin,$(if $(filter windows,$(ARGS1)),windows,linux))
TARGETARCH ?= $(if $(filter arm arm64,$(ARGS2)),arm64,$(if $(filter amd amd64,$(ARGS2)),amd64,amd64))

##@ Helpers
format: ## Code formatting
	gofmt -s -w ./

lint: ## Run linter
	golint

test: ## Run test
	go test -v

get: ## Get dependencies
	go get

##@ Build
build: format get ## Default build for Linux amd64
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o ./${BUILD_DIR}/kubot${EXT} -ldflags "-X=github.com/Andygol/kubot/cmd.appVersion=${VERSION}"

linux: build ## Build a Linux binary. [ linux [[arm|arm64] | [amd|amd64]] ] to build for the specific ARCH 

apple: build ## Build a macOS binary

windows: EXT = .exe
windows: build ## Build a Windows binary

##@ Building and Push
image: ## Build container image for defaul OS/Arch [linux/amd64]
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} --build-arg TARGETOS=${TARGETOS} --build-arg TARGETARCH=${TARGETARCH}

image-linux: image ## image-linux [ARCH] is an alias to linux [ARCH] image

image-apple: TARGETOS = darwin
image-apple: image ## image-apple [ARCH] is an alias to apple [ARCH] image

image-windows: TARGETOS = windows
image-windows: image ## image-windows [ARCH] is an alias to windows [ARCH] image

push: ## Push default container image to the REGISTRY
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

##@ Clean
clean: ## Delete build dir
	rm -rf ./out

clean-image: ## Delete last created container image
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} -f

clean-all: clean clean-image ## Clean all

##@ Help
.PHONY: help

help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m[ target ]\033[0m\n"} \
	/^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2 } \
	/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo -e "\nYou can combine certain targets together. So, in order to push a specific image to a registry, do the following:\n\n    \033[36mmake aplle arm image push\033[0m \n\nThis will build macOS binary for arm64 architecture, make image with specifc name and push it to the registry."

.PHONY: -n
-n: ## Running make -n [target] will display the planned actions without actually executing them
%::
	@true
