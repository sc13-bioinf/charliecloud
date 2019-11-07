#!/bin/bash

set -ex

if [[ $1 = --help ]]; then
    cat <<EOF
Usage:

  $ ./autogen.sh [--clean]

Remove and rebuild Autotools files (./configure and friends).

  --clean  remove only; do not rebuild

EOF
    exit 0
fi

# Remove existing Autotools stuff, if present. Coordinate with .gitignore.
# We don't run "make clean" because that runs configure again.
rm -rf Makefile \
       Makefile.in \
       aclocal.m4 \
       autom4te.cache \
       bin/.deps \
       bin/Makefile \
       bin/Makefile.in \
       bin/config.h \
       bin/config.h.in \
       bin/stamp-h1 \
       build-aux \
       config.log \
       config.status \
       configure

# Create configure and friends.
if [[ $1 != --clean ]]; then
    aclocal
    autoheader
    autoreconf --install -Wall -Werror
fi

# Done.
set +x
echo
echo 'Done. Next you should probably "./configure && make clean".'
