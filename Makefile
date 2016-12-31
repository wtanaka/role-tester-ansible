# Use "system" for the built-in ansible, or specify explicit version
# numbers to install via pip
# Precise has 1.4.4
# Trusty has 1.5.4 and 1.7.2
# Vivid has 1.7.2
# Wily has 1.9.2
# Xenial has 2.0.0.2
# Yakkety has 2.1.0.0
ANSIBLE_VERSIONS ?= 1.4.4 1.5.4 1.7.2 1.9.2 2.0.0.2 2.1.0.0
ANSIBLES=$(patsubst %,ansible%, $(filter-out system,$(ANSIBLE_VERSIONS)))
DOCKER_IMAGES ?= \
	centos:5 \
	centos:7 \
	debian:7 \
	debian:8 \
	fedora:20 \
	fedora:24 \
	ubuntu:12.04 \
	ubuntu:16.04 \
# "v" for verbose, empty string for non-verbose.  Make defaults to
# empty string
# PIP_VERBOSE ?=

ifeq ($(PIP_VERBOSE),)
  PIP_OPTS=-q --isolated
else
  PIP_OPTS=--isolated
endif

.PHONY: ansiblesystem

all: test

print:
	# Use this to debug the values of the variables
	echo ANSIBLE_VERSIONS is $(ANSIBLE_VERSIONS)
	echo ANSIBLES is $(ANSIBLES)

clean:
	find . -name "*~" -exec rm \{\} \;
	rm -rf .bundle
	rm -rf fake-role-no-tests/role-tester
	rm -rf fake-role/role-tester
	rm -rf Gemfile.lock
	rm -rf .kitchen
	rm -rf .kitchen.local.yml
	rm -rf rewritevenv
	rm -rf vendor

rewrite: rewritevenv
	rewritevenv/bin/python update_kitchen_yml.py \
		-a "$(ANSIBLE_VERSIONS)" \
		-o "$(DOCKER_IMAGES)"

rewritevenv:
	virtualenv "$@"
	env VIRTUAL_ENV="$@" $@/bin/pip $(PIP_OPTS) install PyYAML
	env VIRTUAL_ENV="$@" $@/bin/pip $(PIP_OPTS) install atomicwrites

all-ansibles: $(ANSIBLES)

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

test: vendor/bundle rewrite all-ansibles
	bundle exec kitchen test all -l debug
