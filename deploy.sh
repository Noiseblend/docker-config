#!/bin/bash

if [[ "$TRAVIS_BRANCH" = "master" || "$TRAVIS_BRANCH" = "main" ]]; then
    curl --basic --user alin:$DEPLOY_PASSWORD --get --data-urlencode "update=$UPDATE_COMMAND" --data-urlencode "restart=$RESTART" --data-urlencode "async=$ASYNC" https://deploy.darkwoods.win/$STACK
fi
