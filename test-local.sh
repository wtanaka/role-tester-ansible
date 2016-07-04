#!/bin/sh -e
# Copyright (C) 2016 Wesley Tanaka <http://wtanaka.com/>

DIRNAME="`dirname $0`"
PYDISTUTILSCFG="$HOME/.pydistutils.cfg"
PYDISTUTILSCFGBACKUP="$HOME/.pydistutils.cfg.backedup"
ANSIBLE_CANARY_VERSION="1.5.4"

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
   rm -rf fake-role/role-tester
   mkdir -p fake-role/role-tester
   tar cf - . | (cd fake-role/role-tester; tar xf -)
   for ver in $ANSIBLE_CANARY_VERSION; do
      make -s -C fake-role/role-tester "ansible$ver"
   done
}

run_kitchen()
{
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
run_pip_installs

>&2 echo "Running kitchen test"
run_kitchen

restore_config
