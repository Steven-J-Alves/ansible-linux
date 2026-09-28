FROM ghcr.io/ansible/community-ansible-dev-tools:latest

USER root
RUN dnf install -y docker-cli --setopt=install_weak_deps=False && dnf clean all
RUN pip install --no-cache-dir "molecule-plugins[docker]==26.9.28"

COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy collection install --no-cache -r /tmp/requirements.yml

WORKDIR /project
