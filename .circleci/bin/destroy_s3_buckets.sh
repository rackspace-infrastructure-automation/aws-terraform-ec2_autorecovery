#!/bin/sh

set -e

WORKING_DIR=$(pwd)
WORKSPACE_DIR="$WORKING_DIR/workspace"
S3_DIR="$WORKING_DIR/s3buckets"


BUCKETS=$(find "${S3_DIR}"/* -maxdepth 0 -type d -exec basename '{}' \; | sort -nr)


for BUCKET in ${BUCKETS}; do

  if [[ -d "${S3_DIR}/${BUCKET}/.terraform" ]]; then
      echo "terraform init $LAYER"
      (cd "${S3_DIR}/${BUCKET}" && terraform init -input=false -no-color)

      echo "terraform destroy $LAYER"
      (cd "${S3_DIR}/${BUCKET}" && terraform destroy -refresh=false -auto-approve)
  fi
done
