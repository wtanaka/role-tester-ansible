# Use "system" for the built-in ansible, or specify explicit version
# numbers to install via pip
# Ansible Galaxy init defaults to 1.2
# Precise has 1.4.4
# Trusty has 1.5.4 and 1.7.2
# Vivid has 1.7.2
# Wily has 1.9.2
# Xenial has 2.0.0.2
# Yakkety has 2.1.0.0
# 2.1.1.0 to test for https://github.com/ansible/ansible/issues/16868
# Zesty has 2.2.1.0
# Artful has 2.3.1.0
# Bionic has 2.5.1
# Focal has 2.9.6
# Versions before 1.4 are not currently supported due to
# kitchen-ansiblepush use of dynamic inventory script
ANSIBLE_VERSIONS ?= \
	1.4 \
	1.5.4 \
	1.7.2 \
	2.0.0.2 \
	2.1.1.0 \
	2.2.1.0 \
	2.5.1 \
	2.6.16 \
	2.7.8 \
	2.8.3 \
	2.9.6
ANSIBLES=$(patsubst %,.bootci/venv-ansible%, $(filter-out system,$(ANSIBLE_VERSIONS)))
DOCKER_IMAGES ?= \
	centos:6 \
	centos:7 \
	debian:8 \
	fedora:20 \
	fedora:25 \
	ubuntu:12.04 \
	ubuntu:18.04 \
# "v" for verbose, empty string for non-verbose.  Make defaults to
# empty string
# PIP_VERBOSE ?=

ifeq ($(PIP_VERBOSE),)
  PIP_OPTS=-q --isolated
else
  PIP_OPTS=--isolated
endif

# Default kitchen log level is "info" if no "-l" flag were passed per
# https://docs.chef.io/ctl_kitchen.html -- we clone it here to allow
# overriding this with an environment variable or make parameter
KITCHEN_LOG_LEVEL ?= info

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
		-r "$(ROLE_UNDER_TEST)" \
		-o "$(DOCKER_IMAGES)"

rewritevenv:
	(. .bootci/common.sh; \
		retry .bootci/python.sh -m virtualenv "$@"; \
	)
	(. "$@"/bin/activate; \
		"$@"/bin/python -m pip --version; \
		"$@"/bin/python -m pip install --upgrade pip; \
		"$@"/bin/python -m pip --version; \
		"$@"/bin/python -m pip $(PIP_OPTS) install PyYAML; \
		"$@"/bin/python -m pip $(PIP_OPTS) install atomicwrites; \
	)

.bootci/venv-ansible%:
	.bootci/make-ansible.sh "$*"

all-ansibles: $(ANSIBLES)

.bootci/vendor/bundle:
	# Gemfile
	if [ `(ruby --version | cut -d' ' -f2; echo '2.3') | sort -rV | head -1` \
			= '2.3' ]; then \
		cp Gemfile-2.2 Gemfile; else cp Gemfile-current Gemfile; fi
	bundle install --path "$@"

test: .bootci/vendor/bundle rewrite all-ansibles
	bundle exec kitchen test all -l $(KITCHEN_LOG_LEVEL)
