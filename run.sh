#!/bin/sh
# Copyright (C) 2016 Wesley Tanaka <http://wtanaka.com/>
PROJECT=role-tester-ansible
BRANCH=master
PWD="`pwd`"
ROLENAME="${PWD##*/}"

download()
{
  wget -O - "$@" || curl -L "$@" ||
  python3 -c "import sys; from urllib.request import urlopen as u
sys.stdout.buffer.write(u('""$@""').read())"
}

while getopts b:hr: opt; do
  case "$opt" in
    b)
      BRANCH="$OPTARG"
      ;;
    r)
      ROLENAME="$OPTARG"
      ;;
    h)
      echo "Usage: $0 [-b BRANCH] [-r ROLENAME] [-h]"
      exit
      ;;
  esac
done

URL=https://github.com/wtanaka/"$PROJECT"/archive/"$BRANCH".tar.gz

download "$URL" | tar xvfz -

env ROLE_UNDER_TEST="$ROLENAME" make -C "$PROJECT"-"$BRANCH"
