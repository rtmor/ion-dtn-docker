# ION-DTN Docker Container
# Ryan T. Moran
# Development Makefile: This Makefile is provided to simplify regular Docker commands that a
# 						ION-DTN tester might likely encounter.
#
# import deploy config
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

.SILENT:

.PHONY: help build build-nc up-% down-% \
		publish-version-% publish tag tag-latest-% \
		tag-version-% repo-login

# HELP
help: ## For this help menu
	@gawk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z%-]+:.*?##/ \
		 { x=gensub(/^(up-|down-)(%)/, "\\1{environment}", "1", $$1); \
		   gsub("%", "{container:version}", x) ; \
		   printf "\033[36m%-30s\033[0m %s\n", x, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help
SHELL=/usr/bin/bash

# DOCKER TASKS

build-all:
	@-for i in $(COMPOSE_EXAMPLES); do \
		make build-$$i:latest; \
	done

# Build the container
# build-%: ## Build and tag ion container from `Dockerfile`; build-{image_name:version}
build: ## Build and tag ion container from `Dockerfile`; build-{image_name:version}
	@echo "[ion] Building container local/ion-dtn"
	docker build -t local/ion-dtn:latest -f build/Dockerfile .

# build-nc-%: ## Build and tag ion container from `Dockerfile` without caching; ex: build-nc-{image_name:version}
build-nc: ## Build and tag ion container from `Dockerfile` without caching; ex: build-nc-{image_name:version}
	@echo "[ion-container] Building container --no-cache $*"
	docker build --no-cache -t local/ion-dtn:latest -f build/Dockerfile .

_up-sample1: ## Start docker compose example2 environment (docker-compose)
	@echo "[ion-container] Starting docker-compose sample1 environment"
	docker-compose --file deploy/sample1/docker-compose.yaml up

_up-example1: ## Start docker compose example1 environment (docker-compose)
	@echo "[ion-container] Starting docker-compose example1 environment"
	docker-compose --file deploy/example1/docker-compose.yaml up

_up-example2: ## Start docker compose example2 environment (docker-compose)
	@echo "[ion-container] Starting docker-compose example2 environment"
	docker-compose --file deploy/example2/docker-compose.yaml up

up-%: ## Bring up docker compose environment `{example1, example2, ...}`; ex: up-example1
	$(eval context := $*)
	@if [ "$(context)" = "example1" ]; then make -s _up-example1; fi
	@if [ "$(context)" = "example2" ]; then make -s _up-example2; fi
	@if [ "$(context)" = "sample1" ]; then make -s _up-sample1; fi

_down-sample1: ## Bring down docker compose example2 environment (docker-compose)
	@echo "[ion-container] Bringing down docker-compose sample1"
	docker-compose --file deploy/sample1/docker-compose.yaml down

_down-example1: ## Bring down docker compose example1 environment (docker-compose)
	@echo "[ion-container] Bringing down docker-compose example1"
	docker-compose --file deploy/example1/docker-compose.yaml down

_down-example2: ## Bring down docker compose example2 environment (docker-compose)
	@echo "[ion-container] Bringing down docker-compose example2"
	docker-compose --file deploy/example1/docker-compose.yaml down

down-%: ## Bring down docker compose environment `{example1, example2, ...}`
	$(eval context := $*)
	@if [ "$(context)" = "example1" ]; then make -s _down-example1; fi
	@if [ "$(context)" = "example2" ]; then make -s _down-example2; fi

# publish-all: ## Publish all latest tagged containers to ECR
# 	@-for i in $(COMPOSE_EXAMPLES); do \
# 		make publish-$$i:latest; \
# 	done

# publish-%: ## Publish the `{container:version}` tagged container to ECR
publish: ## Publish the `{container:version}` tagged container to ECR
	@echo '[ion-container] Publishing ion-container to repositiory'
	@make -s repo-login tag
	docker push $(DOCKER_USER)/ion-dtn:latest

tag: ## Generate container `{container:version}` DockerHub/AWS-ECR tag
	@echo '[ion-container] Create DockerHub tag for container $*'
	docker tag local/ion-dtn:latest ${DOCKER_USER}/ion-dtn:latest

prune-network: ## Clean all docker network resources
	@echo '[ion-container] Removing all docker network resources...'
	docker system network prune

prune: ## Clean all docker resources - images, containers, volumes & networks
	@echo '[ion-container] Removing all docker resources...'
	docker system prune -a

# HELPERS
# script to login to dockerhub/aws/other repo
CMD_REPOLOGIN := "echo ${DOCKER_ACCESS_TOKEN} | \
				  docker login --username ${DOCKER_USER} --password-stdin"

VERSION := "git --no-pager log -1 --oneline --format=\"%Cblue%h %Cgreen%D\""

# login to DockerHub
repo-login: ## Auto login to DockerHub/AWS-ECR unsing aws-cli
	@eval $(CMD_REPOLOGIN)

version: ## Output the current git commit to be built
	@eval $(VERSION)

list-builds: ## Output a list of all available Dockerfile builds
	@-for i in $(COMPOSE_EXAMPLES); do \
		echo $$i; \
	done