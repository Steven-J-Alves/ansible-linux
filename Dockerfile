FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    ansible-core==2.21.4 \
    ansible-lint==26.9.0 \
    molecule==26.9.0 \
    "molecule-plugins[docker]==26.9.28"

COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy collection install -r /tmp/requirements.yml

WORKDIR /project
