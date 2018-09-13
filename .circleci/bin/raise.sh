#!/bin/sh

set -e

WORKING_DIR=$(pwd)
WORKSPACE_DIR="$WORKING_DIR/workspace"
PLAN_RESULTS="${WORKSPACE_DIR}/plan_results"

LAYERS=$(find "${PLAN_RESULTS}" -maxdepth 1 -type f -exec basename '{}' \; | sort -n)

exit_code="0"
for LAYER in ${LAYERS}; do
    num_destroys=$( cat ${PLAN_RESULTS}/${LAYER} )
    if [[ "$num_destroys" != "0" && "$num_destroys" != "" ]]; then
       echo "Resource Destruction Detected for layer ${LAYER}"
       echo "Number of resources to be destroyed or replaced for layer ${LAYER}: ${num_destroys}"
       exit_code="1"
    else
       echo "No resource destruction detected in layer ${LAYER}"
    fi
done

exit ${exit_code}