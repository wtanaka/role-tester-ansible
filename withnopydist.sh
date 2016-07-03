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

"$@"

