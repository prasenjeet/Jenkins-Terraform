#!/usr/bin/env bash
# Initialize Terraform for the given environment.
set -euo pipefail

ENVIRONMENT="${1:?Usage: tf-init.sh <environment>}"
TF_DIR="terraform/environments/${ENVIRONMENT}"

if [[ ! -d "${TF_DIR}" ]]; then
  echo "ERROR: Environment directory '${TF_DIR}' not found." >&2
  exit 1
fi

echo "==> Initializing Terraform for environment: ${ENVIRONMENT}"
terraform -chdir="${TF_DIR}" init \
  -input=false \
  -reconfigure

echo "==> Init complete."
