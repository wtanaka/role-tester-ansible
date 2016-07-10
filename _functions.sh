#!/bin/sh
# Copyright (C) 2016 Wesley Tanaka

cp_serverspecs()
{
   ROLE_DIR="$1"
   ROLE_TESTER_DIR="$2"

   if [ -d "$ROLE_DIR"/test/integration/default/serverspec ]; then
      (cd $ROLE_TESTER_DIR; bundle exec kitchen diagnose |
         grep '^[ ]*suite_name: ' | cut -d: -f2 | cut -c2- | uniq) |
      while read LINE; do
         mkdir -p "$ROLE_TESTER_DIR"/test/integration/"$LINE"
         cp -a "$ROLE_DIR"/test/integration/default/serverspec \
            "$ROLE_TESTER_DIR"/test/integration/"$LINE"
      done
   fi
}
