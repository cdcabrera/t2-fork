#!/usr/bin/env bash
#
#
# Build
#
build()
{
  local SRC=$1
  local DIR=$2
  mkdir -p $DIR
  printf "${YELLOW}Building ...${NOCOLOR}"
  cp -R  $SRC $DIR
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
  build $SRC_DIR $BUILD_DIR
}
