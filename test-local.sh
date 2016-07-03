#!/bin/sh -ex
# Copyright (C) 2016 Wesley Tanaka <http://wtanaka.com/>

PYDISTUTILSCFG="$HOME/.pydistutils.cfg"
PYDISTUTILSCFGBACKUP="$HOME/.pydistutils.cfg.backedup"

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
   env ROLE_UNDER_TEST=fake-role make -C fake-role/role-tester virtualenvs
   [ -x fake-role/role-tester/ansible1.4.4/bin/ansible-playbook ]
   [ -x fake-role/role-tester/ansible1.5.4/bin/ansible-playbook ]
   [ -x fake-role/role-tester/ansible1.6.1/bin/ansible-playbook ]
   [ -x fake-role/role-tester/ansible1.7.2/bin/ansible-playbook ]
   [ -x fake-role/role-tester/ansible1.8.4/bin/ansible-playbook ]
   [ -x fake-role/role-tester/ansible1.9.2/bin/ansible-playbook ]
   [ -x fake-role/role-tester/ansible2.0.0.2/bin/ansible-playbook ]
   [ -x fake-role/role-tester/ansible2.1.0.0/bin/ansible-playbook ]
}

run_kitchen()
{
   env ROLE_UNDER_TEST=fake-role make -C fake-role/role-tester
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

>&2 echo "Testing virtualenv works with no pydistutils"
rm -f "$PYDISTUTILSCFG"
run_pip_installs

>&2 echo "Running kitchen test"
run_kitchen

restore_config
