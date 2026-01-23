.PHONY: help init fmt validate lint test clean install-tools

help: ## Display this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install-tools: ## Install required tools (terraform, tflint, pre-commit)
	@echo "Installing required tools..."
	@command -v terraform >/dev/null 2>&1 || (echo "Please install Terraform: https://developer.hashicorp.com/terraform/install" && exit 1)
	@command -v tflint >/dev/null 2>&1 || (echo "Installing tflint..." && brew install tflint)
	@command -v pre-commit >/dev/null 2>&1 || (echo "Installing pre-commit..." && brew install pre-commit)
	@echo "Installing pre-commit hooks..."
	@pre-commit install
	@echo "Initializing tflint plugins..."
	@tflint --init
	@echo "All tools installed successfully!"

init: ## Initialize Terraform
	@echo "Initializing Terraform..."
	@terraform init

fmt: ## Format Terraform files
	@echo "Formatting Terraform files..."
	@terraform fmt -recursive

validate: init ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	@terraform validate

lint: ## Run tflint on all Terraform files
	@echo "Running tflint..."
	@tflint --recursive --minimum-failure-severity=warning

test: fmt validate lint ## Run all tests (fmt, validate, lint)
	@echo "✓ All tests passed!"

check-security: ## Run security checks (placeholder for future tfsec integration)
	@echo "Security checks..."
	@command -v tfsec >/dev/null 2>&1 && tfsec . || echo "tfsec not installed. Install with: brew install tfsec"

pre-commit: ## Run pre-commit hooks on all files
	@echo "Running pre-commit hooks..."
	@pre-commit run --all-files

clean: ## Clean Terraform files
	@echo "Cleaning Terraform files..."
	@rm -rf .terraform
	@rm -rf .terraform.lock.hcl
	@find . -type d -name ".terraform" -exec rm -rf {} +
	@echo "Clean complete!"

plan: validate ## Run terraform plan (requires terraform.tfvars)
	@echo "Running terraform plan..."
	@terraform plan

docs: ## Generate module documentation
	@echo "Generating documentation..."
	@command -v terraform-docs >/dev/null 2>&1 && terraform-docs markdown table --output-file README.md . || echo "terraform-docs not installed. Install with: brew install terraform-docs"

all: install-tools test ## Install tools and run all tests
	@echo "✓ Setup and testing complete!"
