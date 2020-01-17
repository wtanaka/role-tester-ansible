#!/bin/sh -ex
# Copyright (C) 2016 Wesley Tanaka <http://wtanaka.com/>
#
# This script is a self-test for role-tester-ansible, used in the
# project's CI.  It would not normally be run by users.

DIRNAME="`dirname $0`"
PYDISTUTILSCFG="$HOME/.pydistutils.cfg"
PYDISTUTILSCFGBACKUP="$HOME/.pydistutils.cfg.backedup"
ANSIBLE_CANARY_VERSION="1.5.4"

. "$DIRNAME"/_functions.sh

restore_config()
{
  if [ -f "$PYDISTUTILSCFGBACKUP" ]; then
     >&2 echo "Restoring $PYDISTUTILSCFG"
     mv "$PYDISTUTILSCFGBACKUP" "$PYDISTUTILSCFG"
  fi
}

install_trap()
{
   for signal in ABRT ALRM BUS FPE HUP \
         ILL INT KILL PIPE QUIT SEGV TERM \
         TSTP TTIN TTOU USR1 USR2 PROF \
         SYS TRAP VTALRM XCPU XFSZ; do
      trap "restore_config; trap $signal; kill -$signal"' $$' $signal
   done
}

run_pip_installs()
{
   cp_role_tester . fake-role/role-tester
   for ver in $ANSIBLE_CANARY_VERSION; do
      fake-role/role-tester/.bootci/make-ansible.sh "$ver"
   done
}

run_kitchen()
{
   cp_role_tester . fake-role-no-tests/role-tester
   cp_serverspecs fake-role fake-role/role-tester
   env ROLE_UNDER_TEST=fake-role-no-tests \
      make -s -C fake-role-no-tests/role-tester \
         ANSIBLE_VERSIONS=1.5.4 \
         DOCKER_IMAGES=ubuntu:12.04
   env ROLE_UNDER_TEST=fake-role make -s -C fake-role/role-tester
}

if [ -f "$PYDISTUTILSCFG" ]; then
  >&2 echo WARNING -- "$PYDISTUTILSCFG" already exists
  >&2 echo Moving to "$PYDISTUTILSCFGBACKUP" temporarily
  install_trap
  mv "$PYDISTUTILSCFG" "$PYDISTUTILSCFGBACKUP"
fi

>&2 echo "Testing virtualenv works with user=1 in pydistutils"
cat > "$PYDISTUTILSCFG" <<EOF
[install]
user=1
EOF

make clean

run_pip_installs

>&2 echo "Running kitchen test"
run_kitchen

restore_config
