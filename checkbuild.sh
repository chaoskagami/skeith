#!/bin/bash

set -e

FORCE=0

if [ ! -d "corbenik" ]; then
    git clone --recursive https://github.com/chaoskagami/corbenik corbenik
    FORCE=1
fi

cd corbenik

make clean

# ==============================================

git remote update
git fetch

LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base @ @{u})

if [ $LOCAL = $REMOTE ]; then
    echo "Up-to-date"
    if [ $FORCE = 0 ]; then
        exit 0
    fi
elif [ $LOCAL = $BASE ]; then
    echo "Need to pull"
    git pull
	git submodule update --init --recursive
else
    echo "Diverged"
    exit 1
fi

make fw_folder=skeith fw_name=Skeith release

rm -rf ../rel

mv rel ../rel

REV=$(git rev-parse HEAD)

cd ..

git add rel

git commit -m "Automated - build succeeded: $REV"

git push origin master

exit 0
