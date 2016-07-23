#!/bin/bash

set -e

FORCE=0

if [ ! -d "corbenik" ]; then
    git clone --recursive https://github.com/chaoskagami/corbenik corbenik
    FORCE=1
fi

cd corbenik

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

unset CC
unset CXX
unset LD
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS
export PATH=$PATH:$DEVKITARM/bin

git clean -fxd
./autogen.sh
./configure --host=arm-none-eabi --prefix=/skeith
make

cd out

zip -r9 ../../rel/release.zip *
sha512sum ../../rel/release.zip | sed 's|../../rel/||g' > ../../rel/release.zip.sha512

cd ..

REV=$(git rev-parse HEAD)

cd ..

git add rel

git commit -m "Automated - build succeeded: $REV"

git push origin master

exit 0
