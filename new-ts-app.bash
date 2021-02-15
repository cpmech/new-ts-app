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
APPSRC="$TEMPLATE/src"

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
pkg_create() {
    if [ "$USE_NPM" = "true" ]; then
        npx create-react-app $PROJ --template typescript
    else
        yarn create react-app $PROJ --template typescript
    fi
}
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
message "🚀 create react app"
pkg_create
cd $PROJ
echo ".eslintcache" >> .gitignore
echo "src/rcomps" >> .gitignore
echo "cdk.out" >> .gitignore

# copy configuration files
message "📜 copy configuration files"
cp -av $TEMPLATE/.eslintignore .
cp -av $TEMPLATE/.prettierrc .
cp -av $TEMPLATE/jest.config.js .
cp -av $TEMPLATE/setupTests.ts .
cp -rvf $TEMPLATE/.vscode .
cp -rvf $TEMPLATE/zscripts .

# fix package.json
message "📝 fix package.json and tsconfig.json"
sad -i '/"test":/d' package.json
sad -i '/"eject":/i\    "test": "jest --verbose",' package.json
sad -i '/"eject":/i\    "tw": "jest --watch --verbose",' package.json
sad -i '/"eject":/i\    "tsc": "tsc",' package.json
sad -i '/"eject":/i\    "eslint": "eslint",' package.json
sad -i '/"eject":/i\    "lint": "eslint --ignore-path .eslintignore . --ext ts --ext tsx --quiet --fix",' package.json
sad -i '/"eject":/i\    "postinstall": "bash ./zscripts/npm_postinstall.bash",' package.json
sad -i '/"eject":/i\    "cdk": "bash ./zscripts/cdk.bash"' package.json
sad -i '/"eject":/d' package.json
sed -i 's/"target": "es5"/"target": "es2018"/' tsconfig.json

# copy src files
message "copy src files"
rm ./src/App.css
cp -avf $TEMPLATE/src/App.test.tsx ./src/
cp -avf $TEMPLATE/src/App.tsx ./src/
cp -avf $TEMPLATE/src/index.css ./src/
cp -avf $TEMPLATE/src/index.tsx ./src/
cp -rvf $TEMPLATE/src/components ./src/
cp -rvf $TEMPLATE/src/data ./src/
cp -rvf $TEMPLATE/src/layout ./src/
cp -rvf $TEMPLATE/src/pages ./src/
cp -rvf $TEMPLATE/src/service ./src/
cp -rvf $TEMPLATE/src/styles ./src/
cp -rvf $TEMPLATE/src/util ./src/
cp -rvf $TEMPLATE/az-cdk .

# update dependencies
message "🆕 update dependencies"
npm-check-updates -u
pkg_i

# add dependencies
message "✨ add dependencies"
DEPS="@cpmech/basic @cpmech/js2ts @cpmech/rcomps @cpmech/react-icons @cpmech/simple-state \
    @cpmech/util @emotion/react async-mutex react-responsive"
pkg_add $DEPS

# add dev dependencies
message "✨ add dev dependencies"
DEVDEPS="@types/react-responsive eslint-config-prettier eslint-plugin-prettier \
    prettier ts-jest ts-node typescript \
    @cpmech/az-cdk @cpmech/envars aws-cdk"
pkg_add_dev $DEVDEPS

# run npm install again, because it doesn't trigger the postinstall hook automatically
if [ "$USE_NPM" = "true" ]; then
    pkg_i
fi

# run tests
message "🔥 run tests"
CI=true pkg_test

# git commit changes
message "👍 git commit changes"
git add .gitignore .eslintignore jest.config.js .prettierrc \
    package.json setupTests.ts tsconfig.json .vscode az-cdk src zscripts
if [ "$USE_NPM" = "true" ]; then
    git add package-lock.json
else
    git add yarn.lock 
fi
git commit -m "Re-Init"

# print success
message "🎉 success!"
