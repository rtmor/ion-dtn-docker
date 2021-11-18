# import deploy config
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

.SILENT:

.PHONY: help build-% build-nc-% up-% down-% \
		publish-version-% publish-% tag-latest-% \
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
build-%: ## Build and tag ion container from `Dockerfile`; build-{image_name:version}
	$(eval image := $(firstword $(subst :, ,$*)))
	$(eval version := $(lastword $(subst :, ,$*)))
	@if [ "$(image)" = "$(version)" ]; then \
		echo -e "Error: version not provided.\\n"; \
		make -s help; exit 1; \
	fi
	@echo "[ion] Building container $*"
	docker build -t ${image}:${version} -f build/Dockerfile .

build-nc-%: ## Build and tag ion container from `Dockerfile` without caching; ex: build-nc-{image_name:version}
	$(eval image := $(firstword $(subst :, ,$*)))
	$(eval version := $(lastword $(subst :, ,$*)))
	@echo "[ion] Building container --no-cache $*"
	docker build --no-cache -t ${image}:${version} -f build/Dockerfile .

_up-example1: ## Start docker compose example1 environment (docker-compose)
	@echo "[ion] Starting docker-compose example1 environment"
	docker-compose --file deploy/example1/docker-compose.yaml up

_up-example2: ## Start docker compose example2 environment (docker-compose)
	@echo "[ion] Starting docker-compose example2 environment"
	docker-compose --file deploy/example2/docker-compose.yaml up

up-%: ## Bring up docker compose environment `{example1, example2, ...}`; ex: up-example1
	$(eval context := $*)
	@if [ "$(context)" = "example1" ]; then make -s _up-example1; fi
	@if [ "$(context)" = "example2" ]; then make -s _up-example2; fi

_down-example1: ## Bring down docker compose example1 environment (docker-compose)
	@echo "[ion] Bringing down docker-compose example1"
	docker-compose --file deploy/example1/docker-compose.yaml down

_down-example2: ## Bring down docker compose example2 environment (docker-compose)
	@echo "[ion] Bringing down docker-compose example2"
	docker-compose --file deploy/example1/docker-compose.yaml down

down-%: ## Bring down docker compose environment `{example1, example2, ...}`
	$(eval context := $*)
	@if [ "$(context)" = "example1" ]; then make -s _down-example1; fi
	@if [ "$(context)" = "example2" ]; then make -s _down-example2; fi

# publish-all: ## Publish all latest tagged containers to ECR
# 	@-for i in $(COMPOSE_EXAMPLES); do \
# 		make publish-$$i:latest; \
# 	done

publish-%: ## Publish the `{container:version}` tagged container to ECR
	$(eval image := $(firstword $(subst :, ,$*)))
	$(eval version := $(lastword $(subst :, ,$*)))
	@echo '[ion] Publish $* to $(DOCKER_REPO)'
	@make -s repo-login tag-$*
	docker push $(DOCKER_REPO)/${image}:${version}

tag-%: ## Generate container `{container:version}` ECR tag
	$(eval image := $(firstword $(subst :, ,$*)))
	$(eval version := $(lastword $(subst :, ,$*)))
	@echo '[ion] Create AWS ECR tag for container $*'
	docker tag ${image}:${version} $(DOCKER_REPO)/${image}:${version}

prune-network: ## Clean all docker network resources
	@echo '[ion] Removing all docker network resources...'
	docker system network prune

prune: ## Clean all docker resources - images, containers, volumes & networks
	@echo '[ion] Removing all docker resources...'
	docker system prune -a

# HELPERS
# generate script to login to aws docker repo
CMD_REPOLOGIN := "aws ecr get-login-password --region ${AWS_CLI_REGION} | \
				  docker login --username AWS --password-stdin $(DOCKER_REPO)"

VERSION := "git --no-pager log -1 --oneline --format=\"%Cblue%h %Cgreen%D\""

# login to AWS-ECR
repo-login: ## Auto login to AWS-ECR unsing aws-cli
	@eval $(CMD_REPOLOGIN)

version: ## Output the current git commit to be built
	@eval $(VERSION)

list-builds: ## Output a list of all available Dockerfile builds
	@-for i in $(COMPOSE_EXAMPLES); do \
		echo $$i; \
	done