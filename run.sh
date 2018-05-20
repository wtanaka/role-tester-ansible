#!/bin/sh
# Copyright (C) 2016 Wesley Tanaka <http://wtanaka.com/>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
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

# Retry function
# Copied from https://github.com/wtanaka/bootci/blob/master/.bootci/common.sh
RETRY_SLEEP_SEC=10
RETRY_COUNT=5
retry()
{
  for i in $(seq 1 $RETRY_COUNT); do
    [ $i -gt 1 ] && sleep $RETRY_SLEEP_SEC; "$@" && s=0 && break ||
      s=$? && >&2 echo "$@: failed try #$i; will retry in $RETRY_SLEEP_SEC sec";
  done;
  (exit $s)
}

download()
{
  wget -O - "$@" || curl -L "$@" ||
  python3 -c "import sys; from urllib.request import urlopen as u
sys.stdout.buffer.write(u('""$@""').read())"
}

# The github user to download the role-tester-ansible distribution
# from.  Default: wtanaka
if [ -z "$GITHUBUSER" ]; then
  GITHUBUSER=wtanaka
fi

# The github project name.  Default: role-tester-ansible
if [ -z "$PROJECT" ]; then
  PROJECT=role-tester-ansible
fi

# Which branch/tag/release of role-tester-ansible to use, allow
# overriding with environment variable
if [ -z "$BRANCH" ]; then
  BRANCH=master
fi

# The role under test -- allow setting from environment variable
if [ -z "$ROLENAME" ]; then
  PWD="`pwd`"
  ROLENAME="${PWD##*/}"
fi

if [ -z "$COMMAND" ]; then
  COMMAND=all
fi

# Also allow overriding parameters with the command line instead of
# environment variables.
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

# Download the code
URL=https://github.com/"$GITHUBUSER"/"$PROJECT"/archive/"$BRANCH".tar.gz

retry download "$URL" | tar xvfz -

# Internal environment variable name for ROLENAME
ROLE_UNDER_TEST="$ROLENAME"
export ROLE_UNDER_TEST

# Inlined from _functions.sh because we're bootstrapping
ROLE_DIR="."
ROLE_TESTER_DIR="$PROJECT"-"$BRANCH"
if [ -d "$ROLE_DIR"/test/integration/default/serverspec ]; then
   (cd $ROLE_TESTER_DIR; bundle exec kitchen diagnose |
      grep '^[ ]*suite_name: ' | cut -d: -f2 | cut -c2- | uniq) |
   while read LINE; do
      mkdir -p "$ROLE_TESTER_DIR"/test/integration/"$LINE"
      cp -a "$ROLE_DIR"/test/integration/default/serverspec \
         "$ROLE_TESTER_DIR"/test/integration/"$LINE"
   done
fi

case "$COMMAND" in
  preparecache)
    # Not sure if this is ruby-version-independent
    # "$ROLE_TESTER_DIR/.bootci/make-vendor-bundle.sh"
    echo "Running preparecache command"
    if [ -z "$ANSIBLE_VERSIONS" ]; then
      echo "ANSIBLE_VERSIONS missing"
      cat "$ROLE_TESTER_DIR"/all-versions.txt | while read VERSION; do
        echo "generating $VERSION"
        "$ROLE_TESTER_DIR"/.bootci/make-ansible.sh "$VERSION"
      done
    else
      echo "ANSIBLE_VERSIONS found"
      for VERSION in $ANSIBLE_VERSIONS; do
        echo "generating $VERSION"
        "$ROLE_TESTER_DIR"/.bootci/make-ansible.sh "$VERSION"
      done
    fi
    ;;
  all)
    make -s -C "$PROJECT"-"$BRANCH"
    ;;
esac
