#!/usr/bin/env bash
# Apply the saved Terraform plan for the given environment.
set -euo pipefail

ENVIRONMENT="${1:?Usage: tf-apply.sh <environment>}"
TF_DIR="terraform/environments/${ENVIRONMENT}"
PLAN_FILE="${TF_DIR}/tfplan.binary"

if [[ ! -f "${PLAN_FILE}" ]]; then
  echo "ERROR: Plan file '${PLAN_FILE}' not found. Run tf-plan.sh first." >&2
  exit 1
fi

echo "==> Applying Terraform plan for environment: ${ENVIRONMENT}"
terraform -chdir="${TF_DIR}" apply -input=false -auto-approve tfplan.binary

echo "==> Terraform outputs:"
terraform -chdir="${TF_DIR}" output -json | tee "${TF_DIR}/outputs.json"

echo "==> Apply complete."
