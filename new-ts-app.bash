#!/bin/bash

set -e

# options
USE_NPM=${2:-"true"}

# check required tools
if [ "$USE_NPM" = "true" ]; then
    echo "npm --version"
    npm --version
else
    echo "yarn --version"
    yarn --version
fi
echo "npm-check-updates --version"
npm-check-updates --version

# constants
TEMPLATE="`dirname \"$0\"`"

# fix 'sad' command in macOS
sad() { 
  sed "$@"
}
unamestr=`uname`
if [[ "$unamestr" == 'Darwin' ]]; then
    sad() { 
        gsed "$@"
    }
    echo "Remember to:"
    echo "brew install gnu-sed"
fi

# pkg commands
pkg_i() {
    if [ "$USE_NPM" = "true" ]; then
        npm install
    else
        yarn
    fi
}
pkg_add() {
    if [ "$USE_NPM" = "true" ]; then
        npm install $@
    else
        yarn add $@
    fi
}
pkg_add_dev() {
    if [ "$USE_NPM" = "true" ]; then
        npm install -D $@
    else
        yarn add -D $@
    fi
}
pkg_test() {
    if [ "$USE_NPM" = "true" ]; then
        npm run test
    else
        yarn test
    fi
}

# define message function
message(){
    echo
    echo ">>> $1 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    echo
}

# check input
if [[ $# == 0 ]]; then
    echo
    echo "usage:"
    echo "       ./`basename $0` myapp"
    echo
    exit 1
fi
PROJ=$1

# create project
message "🚀 create project"
mkdir $PROJ
cd $PROJ
git init

# copy files
message "📜 copy files"
cp -av $TEMPLATE/.eslintignore .
cp -av $TEMPLATE/.eslintrc.js .
cp -av $TEMPLATE/.gitignore .
cp -av $TEMPLATE/.prettierrc .
cp -av $TEMPLATE/jest.config.js .
cp -av $TEMPLATE/package.json .
cp -av $TEMPLATE/rollup.config.js .
cp -av $TEMPLATE/tsconfig.json .
cp -rvf $TEMPLATE/.vscode .
cp -rvf $TEMPLATE/src .
cp -rvf $TEMPLATE/zscripts .

# update dependencies
message "🆕 update dependencies"
npm-check-updates -u
pkg_i

# run tests
message "🔥 run tests"
CI=true pkg_test

# git commit changes
message "👍 git commit changes"
git add .eslintignore \
    .eslintrc.js \
    .gitignore \
    .prettierrc \
    jest.config.js \
    package.json \
    rollup.config.js \
    tsconfig.json \
    .vscode \
    src \
    zscripts
if [ "$USE_NPM" = "true" ]; then
    git add package-lock.json
else
    git add yarn.lock 
fi
git commit -m "Init"

# print success
message "🎉 success!"
