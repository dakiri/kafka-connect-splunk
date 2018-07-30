cnf ?= config.env
include $(cnf)

help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

build:          ## Build the container
	docker build -t $(DOCKER_REPO)/$(APP_NAME) .

build-nc:       ## Build the container without caching
	docker build --no-cache -t $(DOCKER_REPO)/$(APP_NAME) .

run up:         ## Run container 
	docker-compose up

daemon:         ## Run container in daemon mode
	docker-compose up -d

restart:	## Restart the daemon
	docker-compose down
	docker-compose up

stop:           ## Stop container
	docker-compose down

shell bash:     ## Launch shell in container
	echo "Lauching shell for $(CONTAINER_NAME)"
	docker exec -it $(CONTAINER_NAME) bash
