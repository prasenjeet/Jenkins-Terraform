#!/usr/bin/env bash
# Destroy infrastructure for the given environment using a pre-generated destroy plan.
set -euo pipefail

ENVIRONMENT="${1:?Usage: tf-destroy.sh <environment>}"
TF_DIR="terraform/environments/${ENVIRONMENT}"
PLAN_FILE="${TF_DIR}/tfplan.binary"

if [[ ! -f "${PLAN_FILE}" ]]; then
  echo "ERROR: Destroy plan '${PLAN_FILE}' not found. Run tf-plan.sh with action=destroy first." >&2
  exit 1
fi

echo "==> Destroying Terraform-managed infrastructure for environment: ${ENVIRONMENT}"
terraform -chdir="${TF_DIR}" apply -input=false -auto-approve tfplan.binary

echo "==> Destroy complete."
