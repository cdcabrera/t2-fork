#!/bin/bash
#
#
# Clone, build for local development
#
gitRebase()
{
    local GITREMOTE=$1
    local GITBRANCH=$2
    local GITSOURCEBRANCH=$3

    printf "${YELLOW}Attempting to rebase branch \"${GITBRANCH}\" ...${NOCOLOR}"

    if [ ! -z "$(git branch -a | grep $GITBRANCH)" ]; then
      git checkout ${GITBRANCH}
      git rebase ${GITSOURCEBRANCH}
      git push -f ${GITREMOTE} ${GITBRANCH} --quiet
      printf "${GREEN}SUCCESS${NOCOLOR}\n"
    else
      printf "${YELLOW}SKIPPING${NOCOLOR}\n"
    fi
}
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

  # filter
  #if [ "${AUTO_REBASE}" != "true" ] || [ "${TRAVIS_PULL_REQUEST}" != "false" ] || [[ $REPO != *"$TRAVIS_REPO_SLUG"* ]]; then
  if [ -z "${AUTO_REBASE}" ] || [ "${TRAVIS_PULL_REQUEST}" != "false" ] || [[ $REPO != *"$TRAVIS_REPO_SLUG"* ]]; then
    echo -e "${YELLOW}Exiting early, rebase conditions not met.${NOCOLOR}"
    exit 0;
  fi

  # filter process for specific branch and CI stage
  if [[ "${TRAVIS_BRANCH}" = "${BRANCH}" ]] && [[ $TRAVIS_BUILD_STAGE_NAME == *"Rebase"* ]]; then
    set +x
    openssl aes-256-cbc \
            -K `env | grep 'encrypted_2.*_key' | cut -f2 -d '='` \
            -iv `env | grep 'encrypted_2.*_iv' | cut -f2 -d '='` \
            -in .travis/release_key.enc -out .travis/release_key -d
    set -x

    chmod 600 .travis/release_key
    eval `ssh-agent -s`
    ssh-add .travis/release_key

    echo -e "${YELLOW}Attempting rebase...${NOCOLOR}\n"

    git config --global user.name ${USER}
    git config --global user.email ${EMAIL}
    git remote add ssh-origin ${REPO}
    git checkout ${BRANCH}
    #git fetch ssh-origin ${BRANCH}
    #git reset --hard ssh-origin/${BRANCH}

    for RB_BRANCH in ${AUTO_REBASE//,/ }
    do
       gitRebase $REPO $RB_BRANCH $BRANCH
    done

    #gitRebase $REPO "stage" $BRANCH
    #gitRebase $REPO "qa" $BRANCH
    #gitRebase $REPO "ci" $BRANCH

    echo -e "${GREEN}Rebase completed.${NOCOLOR}"
    exit 0;
  fi

  # fallback messaging
  echo -e "${YELLOW}Exiting, nothing to rebase${NOCOLOR}"
  exit 0;
}

}
