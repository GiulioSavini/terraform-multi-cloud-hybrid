# Deployment targets. ENV selects the deployment directory.
ENV ?= dev
DEPLOY := deployments/$(ENV)
POLICY := compliance/policies

.PHONY: help init plan apply destroy fmt validate lint policy security check

help:
	@echo "make init|plan|apply|destroy ENV=dev|stg|prd"
	@echo "make check    -- everything CI runs, locally"

init:
	cd $(DEPLOY) && terraform init -upgrade

plan:
	cd $(DEPLOY) && terraform plan -var-file=terraform.tfvars -out=tfplan

apply:
	cd $(DEPLOY) && terraform apply tfplan

destroy:
	cd $(DEPLOY) && terraform destroy -var-file=terraform.tfvars

fmt:
	terraform fmt -recursive

# Every root that must stand on its own: the shared kernel, each bounded
# context, the control catalog, the application and each deployment.
ROOTS := platform/naming platform/tagging compliance/controls \
         domains/networking domains/access-control domains/workload-hosting \
         domains/service-discovery domains/observability \
         applications/landing-zone \
         deployments/dev deployments/stg deployments/prd

validate:
	@set -e; for d in $(ROOTS); do \
		echo "==> $$d"; \
		( cd $$d && terraform init -backend=false -input=false >/dev/null && terraform validate ); \
	done

lint:
	tflint --recursive --minimum-failure-severity=warning

# Unit tests for the compliance policies themselves.
policy:
	conftest verify --policy $(POLICY)

# Evaluate a real plan against policy. Requires `make plan` first.
policy-plan:
	cd $(DEPLOY) && terraform show -json tfplan > tfplan.json
	conftest test --policy $(POLICY) $(DEPLOY)/tfplan.json

security:
	trivy config --exit-code 1 --severity CRITICAL,HIGH --ignorefile .trivyignore .

check: fmt validate policy
	terraform fmt -check -recursive
	./scripts/check-boundaries.sh
