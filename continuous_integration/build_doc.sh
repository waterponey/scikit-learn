#!/bin/bash
# This script is meant to be called in the "test" step defined in 
# circle.yml. See https://circleci.com/docs/ for more details.
# The behavior of the script is controlled by environment variable defined
# in the circle.yml in the top level folder of the project.


BUILD_DOC_PATTERN="[build-doc]"
BUILD_DOC_NOPLOT_PATTERN="[build-doc-noplot]"

if [ -z $CIRCLE_PROJECT_USERNAME ]
then USR_NAME="waterponey"
else USR_NAME=$CIRCLE_PROJECT_USERNAME
fi

if [ -z $CIRCLE_PROJECT_REPONAME ]
then SRC_REPO="scikit-learn"
else SRC_REPO=$CIRCLE_PROJECT_REPONAME
fi

if [ -z $CIRCLE_PR_NUMBER ]
then PR_MSG="MEGA NICE PR lolilol kitty [build-doc-noplot]"
else PR_MSG=$(curl "https://api.github.com/repos/$USR_NAME/$SRC_REPO/pulls/$CIRCLE_PR_NUMBER" | grep '\"title\"' | head -1) 
fi

echo "$USR_NAME on $SRC_REPO started build for $PR_MSG" | tee ~/log.txt

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
