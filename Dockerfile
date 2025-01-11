# Use Ubuntu latest
FROM ubuntu:latest

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Update, install minimal dependencies, Python 3.12 venv, AWS CLI v2, NVM, and clean up in a single RUN command
RUN apt-get update -y && \
    apt-get install -y curl sudo bash ca-certificates gnupg unzip nano procps git software-properties-common python3-venv && \
    arch=$(dpkg --print-architecture) && \
    if [ "$arch" = "amd64" ]; then curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip; else curl https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o awscliv2.zip; fi && \
    unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip ./aws && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
    nvm install 22 && \
    nvm use 22 && \
    npm install --global aws-cdk@latest && \
    apt-get purge -y --auto-remove curl gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add PIPENV_VERBOSITY setting to .bashrc
RUN echo "export PIPENV_VERBOSITY=-1" >> /root/.bashrc && \
    echo "export NVM_DIR=\"$HOME/.nvm\"" >> /root/.bashrc && \
    echo "[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"" >> /root/.bashrc && \
    echo "Added PIPENV_VERBOSITY=-1 and NVM environment setup to /root/.bashrc"

# Add NVM directory to the PATH environment variable
ENV PATH="/root/.nvm/versions/node/v22.12.0/bin:$PATH"

# Create a non-root user and group
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install sudo and add permissions for appuser
RUN apt-get update && apt-get install -y sudo && \
    echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory and adjust permissions
WORKDIR /app
RUN chown -R appuser:appuser /app

# Switch to the non-root user
USER appuser

# Specify default command
CMD ["bash"]
