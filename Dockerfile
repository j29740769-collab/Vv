FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install SSH, cloudflared, and required packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    openssh-client \
    curl \
    ca-certificates \
    && curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb \
    && dpkg -i cloudflared.deb \
    && rm cloudflared.deb \
    && rm -rf /var/lib/apt/lists/*

# Create SSH directory
RUN mkdir -p /var/run/sshd

# Set root password (change this before deploying!)
RUN echo "root:Madhav69690" | chpasswd

# Enable root login and password authentication
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Railway uses this port internally
EXPOSE 22

# Start SSH server + Cloudflare quick tunnel
CMD service ssh start && \
    echo "========================================" && \
    echo "SSH SERVER STARTED" && \
    echo "Starting Cloudflare Tunnel..." && \
    echo "Check below for your ssh connect command" && \
    echo "========================================" && \
    cloudflared tunnel --url tcp://localhost:22