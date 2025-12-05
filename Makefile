# Makefile for home-server setup
help:
	@echo "Available commands:"
	@echo "  make setup             - Run initial setup script (tools & docker volumes)"
	@echo "  make proxy-up          - Start the go proxy server"
	@echo "  make proxy-down        - Stop the go proxy server"

setup:
	@echo "Running setup script..."
	@./scripts/setup.sh

proxy-up:
	@echo "Starting proxy server..."
	@docker compose build proxy && docker compose up -d proxy

proxy-down:
	@echo "Stopping proxy server..."
	@docker compose down proxy
