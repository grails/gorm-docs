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


fi

exit $EXIT_STATUS