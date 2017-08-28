#!/bin/bash

cd ${OKTA_HOME}/${REPO}

setup_service grunt
setup_service bundler

# Use newer, faster yarn
curl -o- -L https://yarnpkg.com/install.sh | bash
export PATH="$PATH:`yarn global bin`"

# Install required dependencies
yarn global add @okta/ci-update-package
yarn global add @okta/ci-pkginfo

if ! bundle install; then
  echo "bundle install failed! Exiting..."
  exit ${FAILED_SETUP}
fi

if ! gnome-terminal -e yarn install --ignore-optional --verbose; then
  echo "yarn install failed! Exiting..."
  exit ${FAILED_SETUP}
fi

if ! yarn run build:release; then
  echo "yarn build release failed! Exiting..."
  exit ${FAILED_SETUP}
fi
