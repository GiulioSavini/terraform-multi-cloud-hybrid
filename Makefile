.PHONY: help init plan apply destroy fmt validate lint security docs clean

ENV ?= dev
AWS_REGION ?= eu-west-1
AZURE_LOCATION ?= westeurope
GCP_REGION ?= europe-west1

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform for the specified environment (ENV=dev|stg|prd)
	cd environments/$(ENV) && terraform init -upgrade

plan: ## Run Terraform plan (ENV=dev|stg|prd)
	cd environments/$(ENV) && terraform plan -var-file=terraform.tfvars -out=tfplan

apply: ## Apply Terraform changes (ENV=dev|stg|prd)
	cd environments/$(ENV) && terraform apply tfplan

destroy: ## Destroy infrastructure (ENV=dev|stg|prd)
	cd environments/$(ENV) && terraform destroy -var-file=terraform.tfvars -auto-approve

fmt: ## Format all Terraform files
	terraform fmt -recursive .

validate: ## Validate Terraform configuration
	cd environments/$(ENV) && terraform validate

lint: ## Run TFLint
	tflint --recursive --config .tflint.hcl

security: ## Run security scans (tfsec + checkov)
	tfsec . --soft-fail
	checkov -d . --quiet

cost: ## Estimate costs with Infracost
	infracost breakdown --path environments/$(ENV)

docs: ## Generate module documentation
	terraform-docs markdown table --output-file README.md --output-mode inject modules/

clean: ## Clean Terraform cache
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.tfplan" -delete 2>/dev/null || true
	find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true

docker-shell: ## Launch Dockerized workspace
	docker build -t tf-hybrid-workspace .
	docker run -it --rm \
		-v $(PWD):/workspace \
		-v ~/.aws:/root/.aws:ro \
		-v ~/.azure:/root/.azure:ro \
		-v ~/.config/gcloud:/root/.config/gcloud:ro \
		tf-hybrid-workspace

pre-commit: ## Run pre-commit hooks
	pre-commit run --all-files
