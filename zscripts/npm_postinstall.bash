#!/bin/bash

set -e

HERE=$(pwd)
WITHOUT_NODE_MODULES=(${HERE//node_modules/})

if [[ "$HERE" != "$WITHOUT_NODE_MODULES" ]]; then
    # inside node_modules => stop
    exit 0
fi

if [[ -z $CODEBUILD_START_TIME ]]; then
    echo ">>> copy git pre-commit hook <<<"
    cp ./zscripts/git-pre-commit.sh ./.git/hooks/pre-commit
    chmod +x ./.git/hooks/pre-commit
fi
