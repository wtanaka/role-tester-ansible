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
PYTHON=.bootci/python.sh
PIP=$(PYTHON) -m pip

venv: virtualenv
	$(PYTHON) -m virtualenv "$@"
	(. venv/bin/activate; \
		$(PIP) install --upgrade pip ; \
	)

virtualenv: pip
	command -v virtualenv || $(PIP) install --user virtualenv

pip: .bootci/download.sh .bootci/python.sh
	# PYTHONHTTPSVERIFY=0 to work around Ubuntu 16.04.1
	# [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed
	$(PIP) --version || ( \
		env PYTHONHTTPSVERIFY=0 .bootci/download.sh \
			https://bootstrap.pypa.io/get-pip.py > get-pip.py && \
		$(PYTHON) get-pip.py --user ; )

.bootci/python.sh: .bootci .bootci/python.mk
	echo '#!/bin/sh' > "$@"
	echo 'for i in python python3 python2; do' >> "$@"
	echo 'if command -v "$$i" 2>&1 > /dev/null; then exec "$$i" "$$@"; fi' >> "$@"
	echo 'done' >> "$@"
	echo 'echo "no python found"' >> "$@"
	chmod +x "$@"

sinclude .bootci/shell.mk
