# Makefile for home-server setup
# Services
# JENKINS_IMAGE = jenkins/jenkins:lts
# JENKINS_CONTAINER = jenkins_server
# JENKINS_PORT = 8080


# GITEA_IMAGE = gitea/gitea:1.25
# GITEA_CONTAINER = gitea_server
# GITEA_PORT = 3000

# POSTGRES_IMAGE = postgres:18.0-alpine
# POSTGRES_CONTAINER = postgres_db
# POSTGRES_PORT = 5432

help:
	@echo "Available commands:"
	@echo "  make setup             - Run initial setup script (tools & docker volumes)"

setup:
	@echo "Running setup script..."
	@./scripts/setup.sh

up:
ifdef SERVICE
	@echo "Starting $(SERVICE) service..."
	@docker compose up -d $(SERVICE)
else
	@echo "Starting all services..."
	@docker compose up -d
endif

down:
ifdef SERVICE
	@echo "Stopping $(SERVICE) service..."
	@docker compose down $(SERVICE)
else
	@echo "Stopping all services..."
	@docker compose down
endif

logs:
	@echo "Tailing logs for $(SERVICE) service..."
	docker logs -f $($(shell echo $(SERVICE) | tr a-z A-Z)_SERVER)

exec:
	@echo "Accessing shell for $(SERVICE) service..."
	docker exec -it $($(shell echo $(SERVICE) | tr a-z A-Z)_SERVER) /bin/bash