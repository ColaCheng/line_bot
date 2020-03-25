.PHONY: all init new select_workspace plan validate apply deploy destroy help
SHELL := /bin/bash
BUILDV := $(shell /bin/date "+%s")
KEEPCOUNT := 100

all: help

init: ## Initialize Terraform to work locally, downloads plugins to .terraform
	terraform init

new: ## Initialize Terraform workspace
	test -f '.env' && \
	terraform workspace new $$(cat .env)

select_workspace: ## Run the Terraform workspace select step
	test -f '.env' && \
	terraform workspace select $$(cat .env)

plan: select_workspace ## Run the Terraform plan step
	terraform plan \
	-var-file=./environments/$$(cat .env).tfvars

validate: select_workspace ## Run the Terraform validate step
	terraform validate $(TERRAFORM_DEPLOY_OPTS) \
	-var-file=./environments/$$(cat .env).tfvars

apply: select_workspace ## Run the Terraform apply step
	terraform apply $(TERRAFORM_DEPLOY_OPTS) \
	-var-file=./environments/$$(cat .env).tfvars

deploy: select_workspace ## Only deploy new autoscaling group if needed
	terraform apply $(TERRAFORM_DEPLOY_OPTS) -target=module.asg-deployment \
	-var-file=./environments/$$(cat .env).tfvars

destroy: select_workspace ## You probably don't know what you're doing
	read -p "type 'yes' to destroy $$(cat .env): " answer && \
	[ "$$answer" == "yes" ] && \
	terraform destroy \
	-var-file=./environments/$$(cat .env).tfvars

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
