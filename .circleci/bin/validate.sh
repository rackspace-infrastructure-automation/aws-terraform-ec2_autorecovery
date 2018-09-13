#!/bin/sh

set -e

WORKING_DIR=$(pwd)
WORKSPACE_DIR="$WORKING_DIR/workspace"
LAYERS_DIR="$WORKING_DIR/layers"
LAYERS=$(find "$LAYERS_DIR"/* -maxdepth 0 -type d -exec basename '{}' \; | sort -n)

OVERALL_RETURN=0
for LAYER in $LAYERS; do
  echo "terraform validate $LAYER"

  VALIDATE_OUTPUT=$(cd "$LAYERS_DIR/$LAYER" && terraform validate -input=false -check-variables=false -no-color .)
  VALIDATE_RETURN=$?

  if [ $VALIDATE_RETURN -ne 0 ]
  then
    echo "Validate failed in $LAYER, please run terraform validate"
    echo $VALIDATE_OUTPUT
    OVERALL_RETURN=1
  fi
done

if [ $OVERALL_RETURN -ne 0 ]
then
  exit $OVERALL_RETURN
fi
