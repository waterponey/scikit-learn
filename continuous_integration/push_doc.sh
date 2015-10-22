#!/bin/bash
# This script is meant to be called in the "deploy" step defined in 
# circle.yml. See https://circleci.com/docs/ for more details.
# The behavior of the script is controlled by environment variable defined
# in the circle.yml in the top level folder of the project.


if [ -z $CIRCLE_PROJECT_USERNAME ];
then USR_NAME="waterponey";
else USR_NAME=$CIRCLE_PROJECT_USERNAME;
fi

if [ -z $CIRCLE_PROJECT_REPONAME ];
then SRC_REPO="scikit-learn";
else SRC_REPO=$CIRCLE_PROJECT_REPONAME;
fi

DOC_REPO="scikit-learn.github.io"

echo "git@github.com:"$USR_NAME"/"$DOC_REPO".git"

MSG="Pushing the docs for revision for branch:  $CIRCLE_BRANCH, commit $CIRCLE_SHA1"

cd $HOME
if [ ! -d $DOC_REPO ];
then git clone "git@github.com:"$USR_NAME"/"$DOC_REPO".git";
fi
cd $DOC_REPO
git checkout master
git reset --hard origin/master
git rm -rf dev/ && rm -rf dev/
cp -R $HOME/scikit-learn/doc/_build/html/stable dev
git config user.email "email@domainname.ext"
git config user.name $USR_NAME
git add -f dev/
git commit -m "$MSG" dev
git push

echo $MSG 
