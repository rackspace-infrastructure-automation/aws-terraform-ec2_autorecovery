#!/bin/sh

set -e

WORKING_DIR=$(pwd)
WORKSPACE_DIR="$WORKING_DIR/workspace"
LAYERS_DIR="$WORKING_DIR/layers"
ARTIFACT_DIR="${WORKSPACE_DIR}/artifacts"

if [ -f "$WORKSPACE_DIR/changed_layers" ]; then
  LAYERS=$(cat "$WORKSPACE_DIR/changed_layers")
else
  LAYERS=$(find "$LAYERS_DIR"/* -maxdepth 0 -type d -exec basename '{}' \; | sort -n)
fi

for LAYER in $LAYERS; do
  echo "terraform init $LAYER"
  (cd "$LAYERS_DIR/$LAYER" && terraform init -force-copy --input=false -no-color)

  # cache .terraform during the plan
  (cd "$LAYERS_DIR/$LAYER" && tar -czf "$WORKSPACE_DIR/.terraform.$LAYER.tar.gz" .terraform)

  echo "terraform plan $LAYER"
  (cd "$LAYERS_DIR/$LAYER" && cat /dev/null > "layerplan.log" && terraform plan -no-color -input=false -out="$WORKSPACE_DIR/terraform.$LAYER.plan" | tee "layerplan.log" | grep -v "Refreshing state" )
  (cd "$LAYERS_DIR/$LAYER" && cat "layerplan.log" >> "$WORKSPACE_DIR/full_plan_output.log")

  # for debugging, show these files exist
  ls -la "$WORKSPACE_DIR/.terraform.$LAYER.tar.gz"
  ls -la "$WORKSPACE_DIR/terraform.$LAYER.plan"

  # Copy plan stdout to artifact directory
  (cd "$LAYERS_DIR/$LAYER" && cp layerplan.log ${ARTIFACT_DIR}/terraform.${LAYER}.plan.log)
done
