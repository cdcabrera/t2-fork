#!/bin/bash
#
#
# main()
#
{
  set -e
  set -x

  GREEN="\e[32m"
  YELLOW="\e[33m"
  NOCOLOR="\e[39m"
  #DIFF_CHECK=$(git diff | grep '^+' | grep -v '+++' | wc -l)

  # filter out pull requests
  if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
    echo -e "${YELLOW}Exiting early, pull request${NOCOLOR}"
    exit 0;
  fi

  # filter out forked repositories
  if [[ $REPO != *"$TRAVIS_REPO_SLUG"* ]]; then
    echo -e "${YELLOW}Exiting early, not master repository${NOCOLOR}"
    exit 0;
  fi

  # if auto deploy active filter out timestamp only updates
  #if [ "${AUTO_DEPLOY}" = "true" ] && [[ "${DIFF_CHECK}" = "0" ]]; then
  #  echo -e "${YELLOW}$(git diff --compact-summary){$NOCOLOR}"
  #  echo -e "${YELLOW}Exiting early, no significant changes${NOCOLOR}"
  #  exit 0;
  #fi

  # filter out deployment tokens when active
  if [ "${AUTO_DEPLOY}" != "true" ] && [[ ! "$TRAVIS_COMMIT_MESSAGE" =~ "[RELEASE]" ]]; then
    echo -e "${YELLOW}Exiting early, not a release${NOCOLOR}"
    exit 0;
  fi

  # filter process for specific branch and CI stage
  #if [[ "${TRAVIS_BRANCH}" = "${BRANCH}" ]] && [[ $TRAVIS_BUILD_STAGE_NAME == *"Build"* ]]; then
  if [[ "${TRAVIS_BRANCH}" = "${BRANCH}" ]]; then
    set +x
    openssl aes-256-cbc \
            -K `env | grep 'encrypted_2.*_key' | cut -f2 -d '='` \
            -iv `env | grep 'encrypted_2.*_iv' | cut -f2 -d '='` \
            -in .travis/release_key.enc -out .travis/release_key -d
    set -x

    chmod 600 .travis/release_key
    eval `ssh-agent -s`
    ssh-add .travis/release_key

    echo -e "${YELLOW}PUSHING release...${NOCOLOR}"

    git config --global user.name ${USER}
    git config --global user.email ${EMAIL}
    git remote add ssh-origin ${REPO}
    git checkout ${BRANCH}

    git fetch --tags
    yarn release:increment --dry-run

    #git push --follow-tags ssh-origin ${BRANCH}

    echo -e "${GREEN}COMPLETED release${NOCOLOR}"

    exit 0;
  fi

  # fallback messaging
  echo -e "${YELLOW}Exiting, not ${BRANCH} branch or build stage${NOCOLOR}"
  exit 0;
}
