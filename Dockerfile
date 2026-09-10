FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install SSH and required packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# SSH setup
RUN mkdir -p /run/sshd

# CHANGE THIS PASSWORD
RUN echo "root:madhav69690" | chpasswd

# Enable root login and password authentication
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

EXPOSE 22

# Start SSH + Tailscale
CMD sh -c '\
echo "==================================" && \
echo "Starting SSH Server..." && \
/usr/sbin/sshd && \
echo "SSH SERVER STARTED" && \
echo "==================================" && \
echo "Starting Tailscale..." && \
tailscaled --tun=userspace-networking --state=/tmp/tailscale.state & \
sleep 3 && \
tailscale up \
  --authkey=${TAILSCALE_AUTHKEY} \
  --hostname=railway-box && \
echo "==================================" && \
echo "TAILSCALE CONNECTED!" && \
tailscale status && \
echo "==================================" && \
echo "Your Tailscale IP:" && \
tailscale ip -4 && \
echo "==================================" && \
echo "Forwarding SSH through Tailscale..." && \
tailscale serve --tcp=2222 tcp://localhost:22 && \
tail -f /dev/null'