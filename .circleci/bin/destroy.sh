#!/bin/sh

set -e

WORKING_DIR=$(pwd)
WORKSPACE_DIR="$WORKING_DIR/workspace"
LAYERS_DIR="$WORKING_DIR/layers"

if [ -f "$WORKSPACE_DIR/changed_layers" ]; then
  LAYERS=$(cat "$WORKSPACE_DIR/changed_layers" | sort -nr)
else
  LAYERS=$(find "$LAYERS_DIR"/* -maxdepth 0 -type d -exec basename '{}' \; | sort -nr)
fi

for LAYER in $LAYERS; do

  # uncache .terraform for the destroy
  (cd "$LAYERS_DIR/$LAYER" && tar xzf "$WORKSPACE_DIR/.terraform.$LAYER.tar.gz" || echo "Did not find a cached .terraform directory")

  if [[ -d "${LAYERS_DIR}/${LAYER}/.terraform" ]]; then
      echo "terraform init $LAYER"
      (cd "$LAYERS_DIR/$LAYER" && terraform init -force-copy -input=false -no-color)

      echo "terraform destroy $LAYER"
      (cd "$LAYERS_DIR/$LAYER" && terraform destroy -refresh=false -auto-approve)
  fi
done
