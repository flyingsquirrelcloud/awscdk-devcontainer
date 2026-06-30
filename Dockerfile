FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_MAJOR=22

# Install system deps + Node.js (via NodeSource) + AWS CLI in one layer
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        bash ca-certificates curl sudo unzip nano procps git \
        python3 python3-venv python3-pip && \
    # Node.js via NodeSource (no nvm needed in containers)
    curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install --global aws-cdk@latest && \
    # AWS CLI v2
    arch=$(dpkg --print-architecture) && \
    if [ "$arch" = "amd64" ]; then \
        curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip; \
    else \
        curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o awscliv2.zip; \
    fi && \
    unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip ./aws && \
    # Cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create non-root user with sudo access
RUN groupadd -r appuser && useradd -r -g appuser -m appuser && \
    echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV PIPENV_VERBOSITY=-1

WORKDIR /app
RUN chown -R appuser:appuser /app

USER appuser

CMD ["bash"]
