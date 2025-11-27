FROM jenkins/jenkins:lts

USER root

# Install Docker CLI
RUN apt-get update && \
    apt-get install -y docker.io && \
    rm -rf /var/lib/apt/lists/*

# Ensure the 'docker' group has GID 111 (your host's GID)
# If group exists, change its GID; if not, create it.
RUN if getent group docker > /dev/null; then \
        groupmod -g 111 docker; \
    else \
        groupadd -g 111 docker; \
    fi && \
    usermod -aG docker jenkins

USER jenkins