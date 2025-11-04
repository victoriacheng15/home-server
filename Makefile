# Makefile for home-server setup
# Services
JENKINS_IMAGE = jenkins/jenkins:lts
JENKINS_CONTAINER = jenkins_server
JENKINS_PORT = 8080


GITEA_IMAGE = gitea/gitea:1.25
GITEA_CONTAINER = gitea_server
GITEA_PORT = 3000

POSTGRES_IMAGE = postgres:18.0-alpine
POSTGRES_CONTAINER = postgres_db
POSTGRES_PORT = 5432

help:
	@echo "Available commands:"
	@echo "  make setup             - Run initial setup script (tools & docker volumes)"

setup:
	@echo "Running setup script for home-server..."
	@./scripts/setup.sh