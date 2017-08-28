#!/bin/bash

cd ${OKTA_HOME}/${REPO}

setup_service grunt
setup_service bundler

export ARTIFACT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
export BACON_ARTIFACT_PATH=$(basename ${ARTIFACT_DIR})

pushd ${OKTA_HOME}/${REPO}/${BACON_ARTIFACT_PATH} > /dev/null

# Use newer, faster yarn
npm install --g yarn@0.27.5

# Install required dependencies
yarn global add @okta/ci-update-package
yarn global add @okta/ci-pkginfo

if ! bundle install; then
  echo "bundle install failed! Exiting..."
  exit ${FAILED_SETUP}
fi

if ! yarn install --ignore-optional --verbose; then
  echo "yarn install failed! Exiting..."
  exit ${FAILED_SETUP}
fi

if ! yarn run build:release; then
  echo "yarn build release failed! Exiting..."
  exit ${FAILED_SETUP}
fi

popd > /dev/null

export REGISTRY="${REGISTRY:-'https://artifacts.aue1d.saasure.com/artifactory/api/npm/npm-okta'}"
