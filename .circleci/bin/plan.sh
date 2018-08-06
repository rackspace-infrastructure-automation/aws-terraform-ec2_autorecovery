#!/bin/sh

set -e

WORKING_DIR=$(pwd)
WORKSPACE_DIR="$WORKING_DIR/workspace"
LAYERS_DIR="$WORKING_DIR/layers"

if [ -f "$WORKSPACE_DIR/changed_layers" ]; then
  LAYERS=$(cat "$WORKSPACE_DIR/changed_layers")
else
  LAYERS=$(find "$LAYERS_DIR"/* -type d -maxdepth 0 -exec basename '{}' \; | sort -n)
fi

for LAYER in $LAYERS; do
  echo "terraform init $LAYER"
  (cd "$LAYERS_DIR/$LAYER" && terraform init -input=false -no-color)

  # cache .terraform during the plan
  (cd "$LAYERS_DIR/$LAYER" && tar -czf "$WORKSPACE_DIR/.terraform.$LAYER.tar.gz" .terraform)

  echo "terraform plan $LAYER"
  (cd "$LAYERS_DIR/$LAYER" && terraform plan -no-color -input=false -out="$WORKSPACE_DIR/terraform.$LAYER.plan" | tee "$WORKSPACE_DIR/full_plan_output.log" | grep -v "Refreshing state" )

  # for debugging, show these files exist
  ls -la "$WORKSPACE_DIR/.terraform.$LAYER.tar.gz"
  ls -la "$WORKSPACE_DIR/terraform.$LAYER.plan"
done
