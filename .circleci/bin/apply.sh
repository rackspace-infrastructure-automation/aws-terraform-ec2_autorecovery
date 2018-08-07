#!/bin/sh

set -e

WORKING_DIR=$(pwd)
WORKSPACE_DIR="$WORKING_DIR/workspace"
LAYERS_DIR="$WORKING_DIR/layers"

if [ -f "$WORKSPACE_DIR/changed_layers" ]; then
  LAYERS=$(cat "$WORKSPACE_DIR/changed_layers" | sort -n)
else
  LAYERS=$(find "$LAYERS_DIR"/* -type d -maxdepth 0 -exec basename '{}' \; | sort -n)
fi

for LAYER in $LAYERS; do
  # for debugging, show that these files exist
  ls -la "$WORKSPACE_DIR/.terraform.$LAYER.tar.gz"
  ls -la "$WORKSPACE_DIR/terraform.$LAYER.plan"

  # uncache .terraform for the apply
  (cd "$LAYERS_DIR/$LAYER" && tar xzf "$WORKSPACE_DIR/.terraform.$LAYER.tar.gz")

  echo "terraform apply $LAYER"
  (cd "$LAYERS_DIR/$LAYER" && terraform apply -input=false -no-color "$WORKSPACE_DIR/terraform.$LAYER.plan")
done
