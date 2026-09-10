# -------------------------------
# Ubuntu + SSH + Bore TCP Tunnel
# -------------------------------

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install SSH and required tools
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create SSH directory
RUN mkdir -p /var/run/sshd

# ===============================
# SET YOUR SSH PASSWORD HERE
# ===============================
RUN echo "root:madhav69690" | chpasswd

# Enable root login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Enable password authentication
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Explicit SSH settings
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# -------------------------------
# Install Bore
# -------------------------------

RUN curl -L \
    https://github.com/ekzhang/bore/releases/download/v0.5.2/bore-v0.5.2-x86_64-unknown-linux-musl.tar.gz \
    -o /tmp/bore.tar.gz && \
    tar -xzf /tmp/bore.tar.gz -C /tmp && \
    mv /tmp/bore /usr/local/bin/bore && \
    chmod +x /usr/local/bin/bore && \
    rm -rf /tmp/bore*

# SSH Port
EXPOSE 22

# -------------------------------
# Start everything
# -------------------------------

CMD /usr/sbin/sshd && \
    echo "======================================" && \
    echo "SSH SERVER STARTED" && \
    echo "Starting Bore TCP Tunnel..." && \
    echo "Wait for the SSH address below" && \
    echo "======================================" && \
    bore local 22 --to bore.pub