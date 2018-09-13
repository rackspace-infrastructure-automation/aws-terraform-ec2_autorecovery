#!/bin/sh

set -e

WORKING_DIR=$(pwd)
WORKSPACE_DIR="$WORKING_DIR/workspace"
LAYERS_DIR="$WORKING_DIR/layers"
PLAN_RESULTS="${WORKSPACE_DIR}/plan_results"

if [ -f "$WORKSPACE_DIR/changed_layers" ]; then
  LAYERS=$(cat "$WORKSPACE_DIR/changed_layers")
else
  LAYERS=$(find "$LAYERS_DIR"/* -maxdepth 0 -type d -exec basename '{}' \; | sort -n)
fi

for LAYER in $LAYERS; do
  echo "Writing resource destroy count to file for layer ${LAYER}"
  (cd "$LAYERS_DIR/$LAYER" && grep Plan "layerplan.log" | cut -d ' ' -f 8 > ${PLAN_RESULTS}/${LAYER})
done
