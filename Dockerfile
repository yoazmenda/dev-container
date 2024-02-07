# Use the official Ubuntu base image
FROM ubuntu:latest

# Avoid prompts during package installation
ARG DEBIAN_FRONTEND=noninteractive

# Update packages and install necessary software
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y openssh-server git python3 openjdk-11-jdk curl mc vim ncdu sudo && \
    rm -rf /var/lib/apt/lists/*

# Set up SSH server
RUN mkdir /var/run/sshd
RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
RUN echo 'ChallengeResponseAuthentication no' >> /etc/ssh/sshd_config

# Create a non-root user with sudo access
RUN useradd -m -s /bin/bash -G sudo user && \
    echo 'user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Setup directory for keys
RUN mkdir -p /home/user/.ssh && \
    chown user:user /home/user/.ssh && \
    chmod 700 /home/user/.ssh

# Expose the SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
