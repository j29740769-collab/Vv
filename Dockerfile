FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install SSH and required packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    openssh-client \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create SSH directory
RUN mkdir -p /var/run/sshd

# Set root password
RUN echo "root:Madhav69690" | chpasswd

# Enable root login and password authentication
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Railway uses this port internally
EXPOSE 22

# Start SSH server + Pinggy TCP tunnel
CMD service ssh start && \
    echo "========================================" && \
    echo "SSH SERVER STARTED" && \
    echo "Starting Pinggy TCP Tunnel..." && \
    echo "Check below for Host and Port" && \
    echo "========================================" && \
    ssh -o StrictHostKeyChecking=no \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -p 443 \
        -R0:localhost:22 \
        tcp@free.pinggy.io