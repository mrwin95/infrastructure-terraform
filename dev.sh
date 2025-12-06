#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-apply}"
ENV="${2:-dev}"
MODULE="${3:-all}"
CLUSTER="dev"
TFVARS="envs/${ENV}.tfvars"
BACKEND_FILE="backend-config/${ENV}.hcl"
# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${GREEN}=== Terraform Runner ===${NC}"
echo -e "${YELLOW}Action:      ${ACTION}${NC}"
echo -e "${YELLOW}Environment: ${ENV}${NC}"
echo -e "${YELLOW}TFVars file: ${TFVARS}${NC}"
echo

# Validate tfvars
if [[ ! -f "${TFVARS}" ]]; then
  echo -e "${RED}ERROR: tfvars file not found: ${TFVARS}${NC}"
  exit 1
fi

# Validate backend config exists
if [[ ! -f "${BACKEND_FILE}" ]]; then
  echo -e "${RED}ERROR: backend-config file not found: ${BACKEND_FILE}${NC}"
  exit 1
fi

echo -e "${YELLOW}Running Terraform Init...${NC}"
terraform init -input=false -backend-config="${BACKEND_FILE}"

#ensure correct workspace

if ! terraform workspace list | grep -q " ${ENV}"; then
    echo - e "${YELLOW}Creating workspace: ${ENV}${NC}"
    terraform workspace new "${ENV}" || true
fi

echo -e "${YELLOW}Selecting workspace: ${ENV}${NC}"
terraform workspace select "${ENV}"

TARGET_OPTION=""
if [[ "${MODULE}" != "all" ]]; then
    TARGET_OPTION="-target=module.${MODULE}"
    echo -e "${YELLOW}Targeting module: ${MODULE}${NC}"
fi

if [[ "${ACTION}" == "destroy" ]]; then
  echo -e "${RED}WARNING: You are about to destroy resources in '${ENV}'${NC}"
  read -p "Type 'yes' to confirm: " CONFIRM

  if [[ "${CONFIRM}" != "yes" ]]; then
    echo -e "${RED}Destroy aborted.${NC}"
    exit 1
  fi

  echo -e "${YELLOW}Running Terraform Destroy...${NC}"
  terraform destroy -var-file="${TFVARS}" ${TARGET_OPTION}

  echo -e "${GREEN}Destroy completed.${NC}"
  exit 0
fi

echo -e "${YELLOW}Running Terraform Plan...${NC}"
PLAN_FILE="tfplan-${ENV}.bin"
terraform plan -var-file="${TFVARS}" ${TARGET_OPTION} -out="${PLAN_FILE}"

echo
read -p "Apply the plan? (y/n): " CONFIRM

if [[ "${CONFIRM}" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Applying Terraform Plan...${NC}"
    terraform apply "${PLAN_FILE}"
    echo -e "${GREEN}Terraform Apply completed successfully.${NC}"
else
    echo -e "${RED}Terraform Apply aborted by user.${NC}"
fi
echo -e "${GREEN}Done.${NC}"