#!/bin/sh
# Copyright (C) 2018 Wesley Tanaka
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
