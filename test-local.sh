#!/bin/sh -ex
# Copyright (C) 2016 Wesley Tanaka <http://wtanaka.com/>

PYDISTUTILSCFG="$HOME/.pydistutils.cfg"

run_pip_installs()
{
   rm -rf fake-role/role-tester
   mkdir -p fake-role/role-tester
   tar cvf - . | (cd fake-role/role-tester; tar xvf -)
   env ROLE_UNDER_TEST=fake-role make -C fake-role/role-tester virtualenvs
   [ -x fake-role/role-tester/ansible1.6.1/bin/ansible-playbook ]
   [ -x fake-role/role-tester/ansible1.7.2/bin/ansible-playbook ]
   [ -x fake-role/role-tester/ansible1.8.4/bin/ansible-playbook ]
   [ -x fake-role/role-tester/ansible1.9.4/bin/ansible-playbook ]
   [ -x fake-role/role-tester/ansible2.0.0/bin/ansible-playbook ]
}

run_kitchen()
{
   env ROLE_UNDER_TEST=fake-role make -C fake-role/role-tester
}

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
