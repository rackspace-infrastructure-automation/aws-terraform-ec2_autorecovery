#!/bin/sh

WORKING_DIR=$(pwd)
WORKSPACE_DIR="$WORKING_DIR/workspace"
MODULE_DIR="${WORKING_DIR}/module"
TESTS_DIR="${MODULE_DIR}/tests"

LAYERS=$(find "${TESTS_DIR}"/* -maxdepth 0 -type d -exec basename '{}' \; | sort -n)

for LAYER in ${LAYERS}; do
  backend_count=$( grep -E '^\s*bucket\s*\=\s*\"\(\(GENERATED_BUCKET_NAME\)\)\"' ${TESTS_DIR}/${LAYER}/*.tf | wc -l )
  if [[ ${backend_count} == "0" ]]; then
    echo "S3 backend configuration is missing for test ${LAYER}"
    exit 1
  else
    echo "S3 backend configuration found in test ${LAYER}"
  fi
done