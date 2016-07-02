#!/bin/sh
# Copyright (C) 2016 Wesley Tanaka
# Removes the local .pydistutils.cfg, then runs a command, then
# restores it.  This is a race-condition prone hack which is needed
# because:
# easy_install of ansible within a virtualenv does not install the
#   ansible module library in the correct spot (although easy_install
#   will respect the existence of user=0 in setup.cfg
# pip install of ansible within a virtualenv will install dependencies
#   in .local if there is a .pydistutils.cfg, which causes
#   ansible-playbook to fail.  Additionally, pip as of version 8 does
#   not respect --no-user-cfg nor the presence of a setup.cfg which
#   overrides the user install in .pydistutils.cfg

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

if [ -f "$PYDISTUTILSCFG" ]; then
  >&2 echo WARNING -- "$PYDISTUTILSCFG" already exists
  >&2 echo Moving to "$PYDISTUTILSCFGBACKUP" temporarily
  install_trap
  mv "$PYDISTUTILSCFG" "$PYDISTUTILSCFGBACKUP"
fi

"$@"

restore_config
