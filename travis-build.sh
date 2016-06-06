#!/bin/bash
set -e

./gradlew asciidoctor --no-daemon
./gradlew --stop
./gradlew groovydoc --no-daemon
./gradlew --stop
./gradlew docs --no-daemon
./gradlew assemble --no-daemon

EXIT_STATUS=0
echo "Publishing archives for branch $TRAVIS_BRANCH"
if [[ -n $TRAVIS_TAG ]] || [[ $TRAVIS_BRANCH == 'master' && $TRAVIS_PULL_REQUEST == 'false' ]]; then

    echo "Publishing Documentation"
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global credential.helper "store --file=~/.git-credentials"
    echo "https://$GH_TOKEN:@github.com" > ~/.git-credentials

    git clone https://${GH_TOKEN}@github.com/grails/grails-data-mapping.git -b gh-pages gh-pages --single-branch > /dev/null
    cd gh-pages

    
    if [[ -n $TRAVIS_TAG ]]; then
        version="$TRAVIS_TAG"
        version=${version:1}

        # mkdir -p latest
        # cp -r ../build/docs/. ./latest/
        # git add latest/*

        majorVersion=${version:0:4}
        majorVersion="${majorVersion}x"

        mkdir -p "$version"
        cp -r ../build/docs/. "./$version/"
        git add "$version/*"

        mkdir -p "$majorVersion"
        cp -r ../build/docs/. "./$majorVersion/"
        git add "$majorVersion/*"        

    else 
        If this is the master branch then update the snapshot
        mkdir -p snapshot
        cp -r ../build/docs/. ./snapshot/

        git add snapshot/*    
    fi


    git commit -a -m "Updating docs for Travis build: https://travis-ci.org/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID"
    git push origin HEAD
    cd ..
    rm -rf gh-pages

fi

exit $EXIT_STATUS