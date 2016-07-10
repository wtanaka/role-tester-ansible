#!/bin/sh
# Copyright (C) 2016 Wesley Tanaka <http://wtanaka.com/>
#
# This bootstrap script downloads the Ansible Role Tester into your
# role directory and executes it.
#
# Usage (in the root directory of your ansible role, the one that
# contains meta/ and tasks/)
#
# wget -O- bit.ly/ansibletest | sh
#
# To pin to a specific commit of role-tester-ansible
#
# wget -O- bit.ly/ansibletest | env BRANCH=fullshahashgoeshere sh
download()
{
  wget -O - "$@" || curl -L "$@" ||
  python3 -c "import sys; from urllib.request import urlopen as u
sys.stdout.buffer.write(u('""$@""').read())"
}

if [ -z "$GITHUBUSER" ]; then
  GITHUBUSER=wtanaka
fi

if [ -z "$PROJECT" ]; then
  PROJECT=role-tester-ansible
fi

# Which version of role-tester-ansible to use, allow overriding with
# environment variable
if [ -z "$BRANCH" ]; then
  BRANCH=master
fi

# The role under test -- allow setting from environment variable
if [ -z "$ROLENAME" ]; then
  PWD="`pwd`"
  ROLENAME="${PWD##*/}"
fi

while getopts a:b:ho:r: opt; do
  case "$opt" in
    a)
      ANSIBLE_VERSIONS="$OPTARG"
      ;;
    b)
      BRANCH="$OPTARG"
      ;;
    o)
      DOCKER_IMAGES="$OPTARG"
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

ANSIBLE_VERSION_ARG=
# The role under test -- allow setting from environment variable
if [ -n "$ANSIBLE_VERSIONS" ]; then
  ANSIBLE_VERSION_ARG='ANSIBLE_VERSIONS='"$ANSIBLE_VERSIONS"
fi

DOCKER_IMAGES_ARG=
# The role under test -- allow setting from environment variable
if [ -n "$DOCKER_IMAGES" ]; then
  DOCKER_IMAGES_ARG='DOCKER_IMAGES='"$DOCKER_IMAGES"
fi

URL=https://github.com/"$GITHUBUSER"/"$PROJECT"/archive/"$BRANCH".tar.gz

download "$URL" | tar xvfz -

env ROLE_UNDER_TEST="$ROLENAME" make -s -C "$PROJECT"-"$BRANCH" "$ANSIBLE_VERSION_ARG" "$DOCKER_IMAGES_ARG"
