FROM hashicorp/terraform:1.9.8

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
RUN curl -sL https://github.com/terraform-linters/tflint/releases/download/v0.53.0/tflint_linux_amd64.zip -o /tmp/tflint.zip \
    && unzip /tmp/tflint.zip -d /usr/local/bin \
    && rm /tmp/tflint.zip

# tfsec
RUN curl -sL https://github.com/aquasecurity/tfsec/releases/download/v1.28.11/tfsec-linux-amd64 -o /usr/local/bin/tfsec \
    && chmod +x /usr/local/bin/tfsec

# checkov
RUN pip3 install --break-system-packages checkov==3.2.231

# Infracost
RUN curl -sL https://github.com/infracost/infracost/releases/download/v0.10.39/infracost-linux-amd64.tar.gz | tar xz -C /tmp \
    && mv /tmp/infracost-linux-amd64 /usr/local/bin/infracost \
    && chmod +x /usr/local/bin/infracost

# Terragrunt
RUN curl -sL https://github.com/gruntwork-io/terragrunt/releases/download/v0.67.16/terragrunt_linux_amd64 -o /usr/local/bin/terragrunt \
    && chmod +x /usr/local/bin/terragrunt

# terraform-docs
RUN curl -sL https://github.com/terraform-docs/terraform-docs/releases/download/v0.18.0/terraform-docs-v0.18.0-linux-amd64.tar.gz | tar xz -C /usr/local/bin

# Azure CLI
RUN pip3 install --break-system-packages azure-cli==2.67.0

# AWS CLI
RUN pip3 install --break-system-packages awscli==1.36.40

# GCP CLI
RUN curl -sSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir=/opt \
    && ln -s /opt/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]
