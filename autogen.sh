#!/bin/bash

set -e

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --clean)
            clean=yes
            ;;
        --no-lark)
            lark_no_install=yes
            ;;
        --rm-lark)
            lark_shovel=yes
            ;;
        *)
            help=yes
            ;;
    esac
    shift
done

if [[ $help ]]; then
    cat <<EOF
Usage:

  $ ./autogen.sh [OPTIONS]

Remove and rebuild Autotools files (./configure and friends). This script is
intended for developers; end users typically do not need it.

Options:

  --clean    remove only; do not rebuild
  --help     print this help and exit
  --no-lark  don't install bundled Lark (minimal support; see docs)
  --rm-lark  delete Lark (and then reinstall if not --clean or --no-lark)

EOF
    exit 0
fi

cat <<EOF
Removing and (maybe) rebuilding "configure" and friends.

NOTE 1: This script is intended for developers. End users typically do not
        need it.

NOTE 2: Incomprehensible error messages about undefined macros can appear
        below. This is usually caused by missing Autotools components.

See the install instructions for details on both.

EOF

cd "$(dirname "$0")"
set -x

# Remove existing Autotools stuff, if present. Coordinate with .gitignore.
# We don't run "make clean" because that runs configure again.
rm -rf Makefile \
       Makefile.in \
       ./*/Makefile \
       ./*/Makefile.in \
       aclocal.m4 \
       autom4te.cache \
       bin/.deps \
       bin/config.h \
       bin/config.h.in \
       bin/stamp-h1 \
       build-aux \
       config.log \
       config.status \
       configure

if [[ $lark_shovel ]]; then
    rm -Rfv lib/lark lib/lark-stubs lib/lark*.dist-info
fi

# Create configure and friends.
if [[ -z $clean ]]; then
    autoreconf --force --install -Wall -Werror
    if [[ ! -e lib/lark && ! $lark_no_install ]]; then
        # Install Lark only if its directory doesn't exist, to avoid excess
        # re-downloads.
        pip3 --isolated install \
             --target=lib --ignore-installed lark==0.11.3
        # Lark doesn't honor --no-compile, so remove the .pyc files manually.
        rm lib/lark/__pycache__/*.pyc
        rmdir lib/lark/__pycache__
        rm lib/lark/*/__pycache__/*.pyc
        rmdir lib/lark/*/__pycache__
        # Also remove Lark's installer stuff.
        rm lib/lark/__pyinstaller/*.py
        rmdir lib/lark/__pyinstaller
    fi
    set +x
    echo
    echo 'Done. Now you can "./configure".'
fi

