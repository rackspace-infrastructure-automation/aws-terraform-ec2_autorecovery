#!/bin/sh

set -e

# standard paths
WORKING_DIR=$(pwd)
WORKSPACE_DIR="$WORKING_DIR/workspace"
LAYERS_DIR="$WORKING_DIR/layers"
LAYERS=$(find "$LAYERS_DIR"/* -maxdepth 0 -type d -exec basename '{}' \; | sort -n)

# be sure we know about the latest remote refs
git fetch origin
MASTER_REF=$(git rev-parse remotes/origin/master)

# in the last hundred commits, is one of the parents in the current master?
git log --pretty=format:'%H' -n 100 | grep -q "$MASTER_REF"
UPTODATE=$?

if [ $UPTODATE -ne 0 ]
then
  echo "Your branch is not up to date. Exiting."
fi

if [ -f "$WORKSPACE_DIR/changed_layers" ]; then
  CHANGED_LAYERS=$(cat "$WORKSPACE_DIR/changed_layers")
else
  CHANGED_LAYERS=$(git diff --name-only "$MASTER_REF" -- "$LAYERS_DIR" | awk -F "/" '{print $2}' | sort -n | uniq)
  echo $CHANGED_LAYERS > "$WORKSPACE_DIR/changed_layers"
fi

echo "Changed layers: "
echo $CHANGED_LAYERS
