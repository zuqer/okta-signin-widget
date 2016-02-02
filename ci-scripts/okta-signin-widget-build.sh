#!/bin/bash
set +x
set -e

TASK=$1
THRUSH_VERSION=$2
THRUSH_BRANCH=$3


usage(){
  OUTPUTCODE=$1
  echo """
USAGE:
    ./okta-signin-widget-build.sh {TASK}

    Example:
    ./okta-signin-widget-build.sh build

TASKS:
    usage             Prints this guide.
    build             Builds the widget.
                      Depends on: clean setversions
    deploy            Publishes widget to NPM after successful build
                      Requires valid Artifactory credentials.
"""
  [ -z $OUTPUTCODE ] && OUTPUTCODE=0
  exit $OUTPUTCODE
}

configure(){

  BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
  WORKSPACE=$BASEDIR/../../..
  ARTIFACTORY_BASE_URL=${ARTIFACTORY_BASE_URL:-"https://artifacts.aue1d.saasure.com/artifactory"}
  ARTIFACTID="okta.swa.safari"
  GROUPID="com/okta/clients"
  THRUSH_GROUPID="com/okta/thrush"
  TMP_THRUSH_FILE=${WORKSPACE}/thrush-latest-build.zip
  THRUSH_CI_DIR=${WORKSPACE}/thrush-ci
  ARTIFACTORY_REPO="topic"

  if [ -z ${CERTDIR} ]; then
    CERTDIR=/ebs/jenkins/certs
  fi

  if [ -z ${THRUSH_VERSION} ]; then
    THRUSH_VERSION=$(curl -X GET "${ARTIFACTORY_BASE_URL}/api/search/latestVersion?g=${THRUSH_GROUPID}&a=shared&repos=release")
  fi

  if [ ! -z ${THRUSH_VERSION} ]; then
    if [ -z ${THRUSH_BRANCH} ]; then
      echo -e "\nERROR: Parameter 'THRUSH_BRANCH' is empty and is required when 'THRUSH_VERSION' is set!\n"
      usage 1
    fi
  fi

  # Marks the artifact as a Dev build based on Thrush branch and Plugins branch values.
  DEVBUILD="-Dev"
  MAIN_BRANCHPATTERN="(^master$|^release$|^preview$|^hotfix$)"
  if echo ${THRUSH_BRANCH} | grep -Eq $MAIN_BRANCHPATTERN; then
    if echo ${BRANCH} | grep -Eq $MAIN_BRANCHPATTERN; then
      DEVBUILD=""
    fi
  fi
}

build(){
  pushd $WORKSPACE/plugins > /dev/null
  ${ANT} -Dcert.dir=${CERTDIR} -DserverProtocol=http -DserverPort=1802 -Dtomcat.maxmem=768m -Djunit.maxmem=2048m -DrootDomainAdmin=okta1-admin.com -DrootDomainUser=okta1.com -Djunit.permgen=768m -Dtomcat.permgen=512m -Dplugin.version.thrush=${THRUSH_VERSION} -Dartifactory.base.thrush.url=${ARTIFACTORY_BASE_URL}/okta-all/${THRUSH_GROUPID} clean.safari build.safari -DisCI=true
  popd > /dev/null
}

deploy(){
  RELEASE_VERSION=$(grep -i 'RELEASE_VERSION' ${WORKSPACE}/plugins/target/version.properties | cut -f2 -d'=')

  curl -u ${ARTIFACTORY_USER}:${ARTIFACTORY_PASS} --upload-file ${WORKSPACE}/plugins/target/dist/${ARTIFACTID}-${RELEASE_VERSION}.pom ${ARTIFACTORY_BASE_URL}/${ARTIFACTORY_REPO}/${GROUPID}/${ARTIFACTID}/${RELEASE_VERSION}/${ARTIFACTID}-${RELEASE_VERSION}${DEVBUILD}.pom -m 30 --connect-timeout 30 -f
  curl -u ${ARTIFACTORY_USER}:${ARTIFACTORY_PASS} --upload-file ${WORKSPACE}/plugins/target/dist/${ARTIFACTID}-${RELEASE_VERSION}.safariextz ${ARTIFACTORY_BASE_URL}/${ARTIFACTORY_REPO}/${GROUPID}/${ARTIFACTID}/${RELEASE_VERSION}/${ARTIFACTID}-${RELEASE_VERSION}${DEVBUILD}.safariextz -m 30 --connect-timeout 30 -f
}

if [ -z $TASK ]; then
  usage
fi

if [ "$TASK" == "build" ]; then
  configure
  build
elif [ "$TASK" == "deploy" ]; then
  configure
  build
  deploy
else
  usage
fi
