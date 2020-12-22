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

echo -n "Determining target branch: "
target_branch=`cat $GITHUB_EVENT_PATH | jq '.release.target_commitish' | sed -e 's/^"\(.*\)"$/\1/g'`
echo $target_branch
git checkout $target_branch
git pull origin $target_branch

echo "Setting release version in gradle.properties"
if [ -z "$BETA" ] || [ "$BETA" = "false" ]; then
  sed -i "s/^gormVersion.*$/gormVersion\=${gorm_version}.RELEASE/" gradle.properties
else
  sed -i "s/^gormVersion.*$/gormVersion\=${gorm_version}/" gradle.properties
fi
cat gradle.properties

echo "Pushing release version and recreating v${gorm_version} tag"
git add gradle.properties
git commit -m "Release v${gorm_version}"
git push origin $target_branch
git push origin :refs/tags/v${gorm_version}
git tag -fa v${gorm_version} -m "Release v${gorm_version}"
git push origin $target_branch --tags
