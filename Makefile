# Precise has 1.4.4
# Trusty has 1.5.4 and 1.7.2
# Vivid has 1.7.2
# Wily has 1.9.2
# Xenial has 2.0.0.2
# Yakkety has 2.1.0.0
ANSIBLE_VERSIONS ?= system 1.4.4 1.5.4 1.6.1 1.7.2 1.8.4 1.9.2 2.0.0.2 2.1.0.0
ANSIBLES=$(patsubst %,ansible%, $(filter-out system,$(ANSIBLE_VERSIONS)))

PIP_OPTS=-q --isolated

.PHONY: ansiblesystem

all: test

print:
	# Use this to debug the values of the variables
	echo ANSIBLE_VERSIONS is $(ANSIBLE_VERSIONS)
	echo ANSIBLES is $(ANSIBLES)

clean:
	find . -name "*~" -exec rm \{\} \;
	rm -rf fake-role/role-tester

rewrite: rewritevenv
	rewritevenv/bin/python update_kitchen_yml.py $(ANSIBLE_VERSIONS)

rewritevenv:
	virtualenv "$@"
	env VIRTUAL_ENV="$@" $@/bin/pip $(PIP_OPTS) install PyYAML
	env VIRTUAL_ENV="$@" $@/bin/pip $(PIP_OPTS) install atomicwrites

ansible%:
	# without ANSIBLE_LIBRARY, package tries to write to /usr/share
	# without --no-use-wheel, module command scripts end up in
	# ansible1.6.1/lib/python2.7/site-packages/
	#    ANOTHER_PATH.../ansible1.6.1/ANSIBLE_LIBRARY/commands/raw
	# easy_install also puts module command scripts in site-packages
	test -d $@ || { virtualenv $@; \
	( if grep "^$*$$" broken-wheel-versions.txt > /dev/null; then \
			ANSIBLE_LIBRARY=share/ansible; \
			export ANSIBLE_LIBRARY; \
			INSTALL_OPTS=--no-use-wheel; \
		fi; \
		env VIRTUAL_ENV="$@" \
			$@/bin/pip $(PIP_OPTS) install $$INSTALL_OPTS ansible==$*; \
		if [ ! -x $@/bin/ansible-playbook ]; then \
			>&2 echo "Missing $@/bin/ansible-playbook"; \
			rm -rf "$@"; \
			exit 1; \
		fi; \
	) ; }

vendor/bundle:
	bundle install --path "$@"

test: vendor/bundle rewrite $(ANSIBLES)
	bundle exec kitchen test all
