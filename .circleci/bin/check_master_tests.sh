#!/bin/sh

WORKING_DIR=$(pwd)
MASTER_DIR="${WORKING_DIR}/branches/master"
MASTER_TESTS="${MASTER_DIR/tests}"
MODULE_DIR="${WORKING_DIR}/module"

if [[ -d ${MASTER_TESTS} ]]; then
    main_count=$( find ${MASTER_TESTS} -name "main.tf" -type f | wc -l )
    if [[ ${main_count} != 0 ]]; then
        echo "tests found, switching active branch to master"
        rm -f ${MODULE_DIR}
        ln -s ${MASTER_DIR} ${MODULE_DIR}
        exit 0
    else
        echo "tests directory found but no main.tf files found"
        exit 0
    fi
else
    echo "No tests directory found"
fi
