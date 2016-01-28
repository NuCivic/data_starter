#!/usr/bin/env bash

set -e

# This allows us to use !(dkan) to move all the files into a subfolder without recursion.
shopt -s extglob dotglob

show_help () {
  cat << EOF
=== DATA STARTER INIT SCRIPT. v0.1 ===

This script will setup ahoy for data-starter.

Using ahoy:
-----------
  After you run this script and install ahoy (if you haven't yet), use the 'ahoy' command for additional steps like the following:

  Setup client site:
      ahoy data client-setup

Questions? Bugs?
----------------

  Internal teams should create a pluto ticket. Others should create a ticket on github.
EOF
}

DIRECTORY="data-starter"

if [ -d "../$DIRECTORY" ]; then
  SKIP_INIT=true
fi

if [[ $EUID -eq 0 ]] || [ -z $USER ]; then
  IS_ROOT=true
  this_user="root"
  AUTO_SUDO=""
else
  this_user=$USER
  AUTO_SUDO="sudo"
fi
echo "User is $this_user"


get_platform() {
  PLATFORM="$(uname -s)"
}

error() {
  echo ""
  echo "[Error] $1"
  echo ""
  show_help
  exit 1
}

alert() {
  echo ""
  echo "$1"
  echo ""
}

# -------- MAIN -----------

# -- BEGIN SETUP FOLDERS --
if [ ! "$SKIP_INIT" ]; then

  mkdir $DIRECTORY 2> /dev/null && echo "Created ./$DIRECTORY folder.." || ( echo "./$DIRECTORY folder already exists.. exiting."; ls -la; exit 1)

  mv !($DIRECTORY) $DIRECTORY && echo "Moved all files into ./$DIRECTORY.." || ( echo "Error moving files into ./$DIRECTORY.. exiting."; exit 1)

  if [ -f $DIRECTORY/.ahoy/starter.ahoy.yml ]; then
    ln -s $DIRECTORY/.ahoy/starter.ahoy.yml .ahoy.yml && echo "Symlinked an initial ahoy file at ./.ahoy.yml based on ./$DIRECTORY/.ahoy/starter.ahoy.yml."
  else
    echo "$DIRECTORY/.ahoy/starter.ahoy.yml doesn't exist. Make sure you use a $DIRECTORY branch with the latest ahoy files."
  fi

else
  alert "Skipping folder initialization and assuming it was already run..."
fi

# -- END SETUP FOLDERS --

shopt -u dotglob

