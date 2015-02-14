#!/bin/sh

npm run compile
git add lib
git ci -m 'compile new version'
npm version patch
# remove tag again since bower will set it.
v=`grep version package.json | awk -F '\"' '{print $4}'`
git tag -d "v${v}"
bower version patch
git push origin
git push origin --tags
npm publish
