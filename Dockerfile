FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    openssh-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd

# Set your password here
RUN echo "root:madhav69" | chpasswd

# Enable root login and password authentication
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22

CMD service ssh start && \
    echo "=================================" && \
    echo "SSH SERVER STARTED" && \
    echo "Starting Serveo SSH Tunnel..." && \
    echo "=================================" && \
    ssh -o StrictHostKeyChecking=no \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -N \
        -R KrishnaChauhan:22:localhost:22 \
        serveo.net