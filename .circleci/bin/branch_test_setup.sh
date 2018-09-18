#!/bin/sh

set -e

WORKING_DIR=$(pwd)
WORKSPACE_DIR="$WORKING_DIR/workspace"
LAYERS_DIR="$WORKING_DIR/layers"
TESTS_DIR="${WORKING_DIR}/module/tests"

if [ -f "$WORKSPACE_DIR/changed_layers" ]; then
  LAYERS=$(cat "$WORKSPACE_DIR/changed_layers")
else
  LAYERS=$(find "$LAYERS_DIR"/* -maxdepth 0 -type d -exec basename '{}' \; | sort -n)
fi

cp -r ${LAYERS_DIR} ${WORKING_DIR}/layers.backup2

for LAYER in $LAYERS; do

  echo $LAYER
  # if test layer exist in newly checked out branch, clear existing
  # layer (minus state file) and copy files from test

  if [ -d "${TESTS_DIR}/${LAYER}" ]; then
    find "$LAYERS_DIR/$LAYER" \( -name '*.tf' -o -name '*.tfvars' \) ! -name '*.tfstate' ! -name 's3_backend.tf' -maxdepth 1 -type f -exec rm -f {} +
    cp ${TESTS_DIR}/${LAYER}/*.tf ${LAYERS_DIR}/${LAYER}/
  fi

done

TESTS=$(find ${TESTS_DIR}/* -type d -maxdepth 0 -exec basename '{}' \; | sort -n)

for TEST in ${TESTS}; do

  # if test layer exist in newly checked out branch, clear existing
  # layer (minus state file) and copy files from test

  if [ ! -d "${LAYERS_DIR}/${TEST}" ]; then
    cp -r ${TESTS_DIR}/${TEST} ${LAYERS_DIR}/
  fi

  # for debugging, show these files exist
  ls -la "${LAYERS_DIR}/${TEST}" | grep .tf
done