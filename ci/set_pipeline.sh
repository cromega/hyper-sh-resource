#!/bin/bash -e

fly -t local set-pipeline -p hyper-sh-resource -c ci/pipeline.yml \
  -v "deploy-key=$(cat ../sublimia-platform/secrets/deploy_keys/hyper-sh-resource)" \
  -v "dockerhub-password=$(lpass show --password docker.com)"

