# Use the official Ubuntu base image
FROM ubuntu:latest

# Use ARG for variable that won't be needed after build
ARG DEBIAN_FRONTEND=noninteractive

# Update packages and install necessary software in one RUN to reduce layers
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y openssh-server git python3 openjdk-11-jdk curl mc vim ncdu sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /var/run/sshd

# Configure SSH server
RUN echo 'PermitRootLogin no\nPasswordAuthentication no\nChallengeResponseAuthentication no' > /etc/ssh/sshd_config

# Create a non-root user with sudo access
RUN useradd -m -s /bin/bash -G sudo user && \
    echo 'user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Setup directory for keys
RUN mkdir -p /home/user/.ssh && \
    chown user:user /home/user/.ssh && \
    chmod 700 /home/user/.ssh

# Expose the SSH port (will be overridden by runtime port mapping)
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
