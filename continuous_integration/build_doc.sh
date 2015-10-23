#!/bin/bash
# This script is meant to be called in the "test" step defined in 
# circle.yml. See https://circleci.com/docs/ for more details.
# The behavior of the script is controlled by environment variable defined
# in the circle.yml in the top level folder of the project.


BUILD_DOC_PATTERN="[build-doc]"
BUILD_DOC_NOPLOT_PATTERN="[build-doc-noplot]"

if [ -z $CIRCLE_PROJECT_USERNAME ]
then USR_NAME="sklearn-ci"
else USR_NAME=$CIRCLE_PROJECT_USERNAME
fi

if [ -z $CIRCLE_PROJECT_REPONAME ]
then SRC_REPO="scikit-learn"
else SRC_REPO=$CIRCLE_PROJECT_REPONAME
fi

# extracting the PR title
if [ -z $CI_PULL_REQUEST]
then PR_MSG=""
else 
  ORIG_REPO=$(echo $CI_PULL_REQUEST |  cut -d'/' -f4-5)
  PR_NUM=$(echo $CI_PULL_REQUEST |  cut -d'/' -f7)
  PR_MSG=$(curl "https://api.github.com/repos/$ORIG_REPO/pulls/$PR_NUM" | grep '\"title\"' | head -1 | cut -d':' -f2-) 
fi

# Logging the build version :
echo "$USR_NAME on $SRC_REPO started build for$PR_MSG" | tee ~/log.txt

# if we are on branch master, we want to build the documentation
test "$CIRCLE_BRANCH" == "master" && PR_MSG=$PR_MSG" [build-doc]"


# we check what kind of build we want
case $PR_MSG in 
*"$BUILD_DOC_PATTERN"*) 
  set -o pipefail && cd doc && make html  2>&1 | tee -a ~/log.txt
  if grep -q "Traceback (most recent call last):" ~/log.txt; then exit 1; else exit 0; fi 
  ;;
*"$BUILD_DOC_NOPLOT_PATTERN"*)
  set -o pipefail && cd doc && make html-noplot  2>&1 | tee -a ~/log.txt
  if grep -q "Traceback (most recent call last):" ~/log.txt; then exit 1; else exit 0; fi
  ;;
*)
  exit 0
  ;;
esac
