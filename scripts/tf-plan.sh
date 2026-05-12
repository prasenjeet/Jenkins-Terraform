#!/usr/bin/env bash
# Generate a Terraform plan for the given environment.
# Saves the binary plan to tfplan.binary for use by tf-apply.sh.
set -euo pipefail

ENVIRONMENT="${1:?Usage: tf-plan.sh <environment> [apply|destroy]}"
ACTION="${2:-apply}"
TF_DIR="terraform/environments/${ENVIRONMENT}"

echo "==> Planning Terraform (action=${ACTION}) for environment: ${ENVIRONMENT}"

PLAN_ARGS=(-input=false -out=tfplan.binary -var-file=terraform.tfvars)

if [[ "${ACTION}" == "destroy" ]]; then
  PLAN_ARGS+=(-destroy)
fi

terraform -chdir="${TF_DIR}" plan "${PLAN_ARGS[@]}"

echo "==> Generating human-readable plan summary..."
terraform -chdir="${TF_DIR}" show -no-color tfplan.binary | tee "${TF_DIR}/tfplan.txt"

echo "==> Plan saved to ${TF_DIR}/tfplan.binary"
