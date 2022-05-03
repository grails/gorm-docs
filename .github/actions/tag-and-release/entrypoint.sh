#!/bin/bash
# $1 == GH_TOKEN
# $2 == GORM Version

gorm_version="$2"
echo -n "Updating GORM version to: $gorm_version"

if [ -z "$GIT_USER_EMAIL" ]; then
    GIT_USER_EMAIL="${GITHUB_ACTOR}@users.noreply.github.com"
fi

if [ -z "$GIT_USER_NAME" ]; then
   GIT_USER_NAME="${GITHUB_ACTOR}"
fi

echo "Configuring git"
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"
git config --global --add safe.directory /github/workspace

#echo -n "Determining target branch: "
#TARGET_BRANCH=`cat $GITHUB_EVENT_PATH | jq '.release.target_commitish' | sed -e 's/^"\(.*\)"$/\1/g'`
#echo $TARGET_BRANCH
git checkout $TARGET_BRANCH
git pull origin $TARGET_BRANCH

echo "Setting release version in gradle.properties"
sed -i "s/^gormVersion.*$/gormVersion\=${gorm_version}/" gradle.properties

cat gradle.properties

echo "Pushing release version and recreating v${gorm_version} tag"
git add gradle.properties
git commit -m "Release v${gorm_version}"
git push origin $TARGET_BRANCH
git push origin :refs/tags/v${gorm_version}
git tag -fa v${gorm_version} -m "Release v${gorm_version}"
git push origin $TARGET_BRANCH --tags
