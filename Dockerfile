FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TAILSCALE_AUTHKEY=tskey-auth-kJTyehsJS721CNTRL-esEAZYLDh5A4bUigPRvX5AocZEVKg1XM

# Install SSH, Tailscale, and required packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    openssh-client \
    curl \
    ca-certificates \
    gnupg \
    && curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null \
    && curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list \
    && apt-get update && apt-get install -y tailscale \
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

# Start SSH server + Tailscale (join your tailnet, then SSH over its private IP)
CMD service ssh start && \
    echo "========================================" && \
    echo "SSH SERVER STARTED" && \
    echo "Starting Tailscale..." && \
    echo "========================================" && \
    tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock & \
    sleep 2 && \
    tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=railway-box && \
    echo "========================================" && \
    echo "Tailscale connected. Find this box's IP with:" && \
    echo "  tailscale status   (run on your own machine)" && \
    echo "Then SSH with: ssh root@<tailscale-ip>" && \
    echo "========================================" && \
    tail -f /dev/null
