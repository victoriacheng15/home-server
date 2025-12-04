# Home Server

A personal home lab environment for experimenting with containerization, infrastructure as code, and service integration using open-source tooling on Ubuntu Server (minimal install).

## Overview

This project serves as a practical sandbox for learning and iterating on core infrastructure concepts, including:

- **Container orchestration** with Docker Compose
- **Infrastructure as Code (IaC)** using Terraform
- **Secure remote access** via Tailscale for private networking and service exposure
- **Self-hosted development services** (CI/CD, Git, automation, databases)
- **Geospatial data handling** via PostGIS
- **Lightweight observability** through a custom Go proxy

The setup is designed for local use and reflects an evolving exploration of tools—services may be added, removed, or replaced over time based on learning goals or practical needs.

## Services (Tentative)

The following services represent initial candidates for deployment. Not all may remain in the final configuration:

| Service | Port | Purpose |
|---------|------|---------|
| **Jenkins** | 8080 | CI/CD pipeline automation and build management |
| **Gitea** | 3000, 222 | Self-hosted Git server for version control |
| **PostgreSQL** | 5432 | Relational database |
| **PostGIS** | 5433 | PostgreSQL with geospatial extensions |
| **n8n** | 5678 | Workflow automation and integration platform |
| **Jupyter** | 8888 | Interactive notebooks for data analysis and exploration |
| **Health Proxy** | 8085 | Custom Go-based health check proxy |

## Project Structure

```plaintext
home-server/
├── docker/                # Custom Dockerfiles
│   ├── jenkins/
│   ├── n8n/
│   └── proxy/             # Go health proxy
├── proxy/                 # Go source code (main.go, go.mod)
├── scripts/               # Setup and data management utilities
│   ├── setup.sh
│   ├── create_volume.sh
│   ├── backup_volume.sh
│   └── restore_volume.sh
├── terraform/             # Sandbox for practicing and understanding Infrastructure as Code (IaC)
│   ├── main.tf
│   └── modules/
│       └── postgres-local/
├── config/                # Configuration files
├── data/                  # Persistent data
└── docker-compose.yml     # Service definitions
```
