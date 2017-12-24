#!/bin/sh
# Copyright (C) 2017 Wesley Tanaka
#
# This file is part of github.com/wtanaka/bootci
#
# github.com/wtanaka/bootci is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# github.com/wtanaka/bootci is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with github.com/wtanaka/bootci.  If not, see
# <http://www.gnu.org/licenses/>.

set -e

DIRNAME="`dirname $0`"

# PYTHONHTTPSVERIFY=0 to work around Ubuntu 16.04.1
# [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed
if ! "$DIRNAME"/python.sh -m pip --version; then
  (
    cd "$DIRNAME"
    env PYTHONHTTPSVERIFY=0 \
      ./download.sh https://bootstrap.pypa.io/get-pip.py > get-pip.py
    ./python.sh get-pip.py --user
  )
fi
