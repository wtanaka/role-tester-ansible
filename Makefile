# Precise has 1.4.4
# Trusty has 1.5.4 and 1.7.2
# Vivid has 1.7.2
# Wily has 1.9.2
# Xenial has 2.0.0.2
# Yakkety has 2.1.0.0
ANSIBLES=ansible1.4.4 \
   ansible1.5.4 \
	ansible1.6.1 \
	ansible1.7.2 \
	ansible1.8.4 \
	ansible1.9.2 \
	ansible2.0.0.2 \
	ansible2.1.0.0 \

PIP_OPTS=-q --isolated

all: test

virtualenvs: $(ANSIBLES)

clean:
	find . -name "*~" -exec rm \{\} \;
	rm -rf fake-role/role-tester

ansible1.4.4:
	test -d $@ || virtualenv $@
	# without --no-use-wheel, module command scripts end up in
	# ansible1.6.1/lib/python2.7/site-packages/
	#    ANOTHER_PATH.../ansible1.6.1/ANSIBLE_LIBRARY/commands/raw
	# ANSIBLE_LIBRARY is required because otherwise the package tries
	# to write to /usr/share
	env VIRTUAL_ENV="$@" ANSIBLE_LIBRARY=share/ansible \
		$@/bin/pip $(PIP_OPTS) install --no-use-wheel ansible==1.4.4

ansible1.5.4:
	test -d $@ || virtualenv $@
	# without --no-use-wheel, module command scripts end up in
	# ansible1.6.1/lib/python2.7/site-packages/
	#    ANOTHER_PATH.../ansible1.6.1/ANSIBLE_LIBRARY/commands/raw
	# ANSIBLE_LIBRARY is required because otherwise the package tries
	# to write to /usr/share
	env VIRTUAL_ENV="$@" ANSIBLE_LIBRARY=share/ansible \
		$@/bin/pip $(PIP_OPTS) install --no-use-wheel ansible==1.5.4

ansible1.6.1:
	test -d $@ || virtualenv $@
	# without --no-use-wheel, module command scripts end up in
	# ansible1.6.1/lib/python2.7/site-packages/
	#    ANOTHER_PATH.../ansible1.6.1/ANSIBLE_LIBRARY/commands/raw
	# ANSIBLE_LIBRARY is required because otherwise the package tries
	# to write to /usr/share
	# (. $@/bin/activate; env ANSIBLE_LIBRARY=../../../../share/ansible \
	#	$@/bin/easy_install ansible==1.6.1)
	env VIRTUAL_ENV="$@" ANSIBLE_LIBRARY=share/ansible \
		$@/bin/pip $(PIP_OPTS) install --no-use-wheel ansible==1.6.1

ansible1.7.2:
	test -d $@ || virtualenv $@
	# without --no-use-wheel, module command scripts end up in
	# ansible1.6.1/lib/python2.7/site-packages/
	#    ANOTHER_PATH.../ansible1.6.1/ANSIBLE_LIBRARY/commands/raw
	# ANSIBLE_LIBRARY is required because otherwise the package tries
	# to write to /usr/share
	env VIRTUAL_ENV="$@" ANSIBLE_LIBRARY=share/ansible \
		$@/bin/pip $(PIP_OPTS) install --no-use-wheel ansible==1.7.2

ansible%:
	test -d $@ || virtualenv $@
	env VIRTUAL_ENV="$@" $@/bin/pip $(PIP_OPTS) install ansible==$*

vendor/bundle:
	bundle install --path "$@"

test: vendor/bundle virtualenvs
	bundle exec kitchen test all
