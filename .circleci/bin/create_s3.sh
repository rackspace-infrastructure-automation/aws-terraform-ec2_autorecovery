#!/bin/sh

set -e

WORKING_DIR=$(pwd)
WORKSPACE_DIR="$WORKING_DIR/workspace"
LAYERS_DIR="$WORKING_DIR/layers"
S3_DIR="$WORKING_DIR/s3buckets"
S3_BUCKET_PREFIX="circleci-tf-backend"
MODULE_DIR="${WORKING_DIR}/module"

if [ -f "$WORKSPACE_DIR/changed_layers" ]; then
  LAYERS=$(cat "$WORKSPACE_DIR/changed_layers")
else
  LAYERS=$(find "$LAYERS_DIR"/* -maxdepth 0 -type d -exec basename '{}' \; | sort -n)
fi

for LAYER in ${LAYERS}; do
  if [[ ! -d "${LAYERS_DIR}/${LAYER}/.terraform" && ! -d "${S3_DIR}/${LAYER}" ]]; then

    echo "Executing s3 backend setup for layer ${LAYER}"
    # Create s3 bucket directory for layer
    mkdir -p ${S3_DIR}/${LAYER}

    # Copy s3 template as main.tf in bucket layer
    cp ${WORKING_DIR}/templates/s3_template.tf ${S3_DIR}/${LAYER}/main.tf

    # Generate bucket name
    S3_BUCKET_NAME="${S3_BUCKET_PREFIX}-${RANDOM}"
    echo "S3 Bucket name for layer ${LAYER} is ${S3_BUCKET_NAME}"

    # Record s3 bucket name to file
    echo "${S3_BUCKET_NAME}" > ${S3_DIR}/${LAYER}_bucket_name

    # Insert generated bucket name is s3 bucket main.tf file
    (sed -i -e "s/((GENERATED_BUCKET_NAME))/${S3_BUCKET_NAME}/g" ${S3_DIR}/${LAYER}/main.tf)

    # Insert generated bucket name is layer main.tf file
    (sed -i -e "s/((GENERATED_BUCKET_NAME))/${S3_BUCKET_NAME}/g" ${LAYERS_DIR}/${LAYER}/main.tf)

    # Initialize and apply
    (cd ${S3_DIR}/${LAYER} && terraform fmt && terraform init && terraform plan -out=s3.tfplan && terraform apply s3.tfplan)
  elif [[ -d "${LAYERS_DIR}/${LAYER}/.terraform" && -d "${S3_DIR}/${LAYER}" ]]; then
    EXISTING_BUCKET=$( cat ${S3_DIR}/${LAYER}_bucket_name )

    # Insert generated bucket name is layer main.tf file
    (sed -i -e "s/((GENERATED_BUCKET_NAME))/${EXISTING_BUCKET}/g" ${LAYERS_DIR}/${LAYER}/main.tf)
  else
    :
  fi
done