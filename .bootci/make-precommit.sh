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

"$DIRNAME"/download.sh \
  https://raw.githubusercontent.com/pre-commit/pre-commit.github.io/real_master/install-local.py \
 | "$DIRNAME"/withnopydist.sh "$DIRNAME"/python.sh

(
  . "$HOME"/.pre-commit-venv/bin/activate
  # this script pip installs pre-commit-hooks, and we don't have
  # control over passing it the --isolated flag, so we run it with
  # "withnopydist.sh"
  env PATH="$HOME"/.pre-commit-venv/bin:"$PATH" \
    "$DIRNAME"/withnopydist.sh "$HOME"/bin/pre-commit
)
