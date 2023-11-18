.DEFAULT_GOAL := help
SHELL := /bin/bash

APP = $(shell basename $(shell git remote get-url origin))
VERSION = $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
BUILD_DIR = out
REGISTRY = ghcr.io/andygol

ARGS1 := $(word 1,$(MAKECMDGOALS)) 
ARGS2 := $(word 2,$(MAKECMDGOALS))

TARGETOS ?= $(if $(filter apple,$(ARGS1)),darwin,$(if $(filter linux windows,$(ARGS1)),$(ARGS1),linux))
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
build: format get ## Default build for Linux amd64.
	@echo 'CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o ./${BUILD_DIR}/kubot${EXT} -ldflags "-X=github.com/Andygol/kubot/cmd.appVersion=${VERSION}"'

linux: build ## Build a Linux binary. [ linux [[arm|arm64] | [amd|amd64]] ] to build for thespecific ARCH 

apple: build ## Build a macOS binary

windows: EXT = .exe
windows: build ## Build a Windows binary

##@ Building
image: ## Build container image
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push: ## Push container image to the REGISTRY
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

##@ Clean
clean: ## Delete build dir
	rm -rf ./out

clean-image: ## Delete last created container image
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH} -f

clean-all: clean clean-image ## Clean all

##@ Help
.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m[ target ]\033[0m\n"} \
	/^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2 } \
	/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

%::
	@true