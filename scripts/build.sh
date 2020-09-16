#!/usr/bin/env bash
#
#
# Build
#
build()
{
  local SRC=$1
  local DIR=$2
  local LOCAL_BRANCH=$3
  local LOCAL_STAGE=$4
  mkdir -p $DIR
  printf "${YELLOW}Building ... branch=${LOCAL_BRANCH}, stage=${LOCAL_STAGE} ${NOCOLOR}"
  cp $SRC/* $DIR 2>/dev/null
  printf "${GREEN}SUCCESS${NOCOLOR}\n"
}
#
#
# Git commit hash and package.json version
#
version()
{
  local DIR=$1

  UI_VERSION="$(node -p 'require(`./package.json`).version').$(git rev-parse --short HEAD)"
  printf "Version ${YELLOW}UI_VERSION=$UI_VERSION${NOCOLOR} ...${NOCOLOR}"
  mkdir -p $DIR
  echo UI_VERSION="$UI_VERSION" >> $DIR/version.txt
  printf "${GREEN}SUCCESS${NOCOLOR}\n"
}
#
#
# Clean directories
#
clean()
{
  local DIR=$1

  echo "Cleaning build directories, files..."
  rm -rf -- $DIR
}
#
#
# main()
#
{
  BLUE="\e[34m"
  RED="\e[31m"
  GREEN="\e[32m"
  YELLOW="\e[33m"
  NOCOLOR="\e[39m"

  SRC_DIR=./src
  BUILD_DIR=./build

  clean $BUILD_DIR
  version $BUILD_DIR
  build $SRC_DIR $BUILD_DIR "${BRANCH:-local}" "${BUILD_STAGE:-Local Deploy}"
}
