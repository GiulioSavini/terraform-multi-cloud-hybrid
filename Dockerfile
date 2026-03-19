FROM hashicorp/terraform:1.9

RUN apk add --no-cache \
    bash \
    curl \
    git \
    jq \
    make \
    python3 \
    py3-pip \
    openssh-client \
    && rm -rf /var/cache/apk/*

# TFLint
RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# tfsec
RUN curl -sL https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64 -o /usr/local/bin/tfsec \
    && chmod +x /usr/local/bin/tfsec

# checkov
RUN pip3 install --break-system-packages checkov

# Infracost
RUN curl -sL https://github.com/infracost/infracost/releases/latest/download/infracost-linux-amd64.tar.gz | tar xz -C /usr/local/bin

# Terragrunt
RUN curl -sL https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64 -o /usr/local/bin/terragrunt \
    && chmod +x /usr/local/bin/terragrunt

# terraform-docs
RUN curl -sL https://github.com/terraform-docs/terraform-docs/releases/latest/download/terraform-docs-v0.18.0-linux-amd64.tar.gz | tar xz -C /usr/local/bin

# Azure CLI
RUN pip3 install --break-system-packages azure-cli

# AWS CLI
RUN pip3 install --break-system-packages awscli

# GCP CLI
RUN curl -sSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir=/opt \
    && ln -s /opt/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]
