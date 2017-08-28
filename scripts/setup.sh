#!/bin/bash

cd ${OKTA_HOME}/${REPO}

setup_service grunt
setup_service bundler

echo "prefix=/home/vagrant/.npm-global
progress=false
cafile=/home/vagrant/Okta-Root-CA.pem
strict-ssl=true
@okta:registry=https://artifacts.aue1d.saasure.com/artifactory/api/npm/npm-okta
registry=https://artifacts.aue1d.saasure.com/artifactory/api/npm/npm-okta-master
phantomjs_cdnurl=https://artifacts.aue1d.saasure.com/artifactory/thirdparty/ariya/phantomjs" >> /root/.yarnrc

# Use newer, faster yarn
wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo
yes | yum -y install yarn

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
