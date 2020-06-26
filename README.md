[![Build Status](https://travis-ci.com/wtanaka/role-tester-ansible.svg?branch=master)](https://travis-ci.com/wtanaka/role-tester-ansible)
[![CircleCI](https://circleci.com/gh/wtanaka/role-tester-ansible.svg?style=svg)](https://circleci.com/gh/wtanaka/role-tester-ansible)
[![Build Status](https://semaphoreci.com/api/v1/wtanaka/role-tester-ansible/branches/master/shields_badge.svg)](https://semaphoreci.com/wtanaka/role-tester-ansible)

Role Tester for Ansible Roles
=============================

Requirements
------------

* Docker
* bundler
* Python.h
  * Ubuntu: sudo apt-get install python-dev
* ffi.h
  * Ubuntu: sudo apt-get install libffi-dev
  * Mac OSX Homebrew: brew install pkg-config libffi
* openssl/opensslv.h
  * Ubuntu: sudo apt-get install libssl-dev

Usage
-----

Run this command to execute tests:

```
wget -O- bit.ly/ansibletest | sh
```

If you fork this project and want to run from your own branch, you can
specify that with environment variables:

```
wget -O- bit.ly/ansibletest | env GITHUBUSER=mygituser BRANCH=mybranch sh
```

To test a different list of ansible versions than the default, use the
`ANSIBLE_VERSIONS` environment variable.  `system` indicates that you
want to test with the `ansible-playbook` on your PATH.  When you
specify a version number, those are installed via `pip`.  Ansible
versions prior to 1.4 are not supported due to kitchen-ansiblepush
ruby gem use of a dynamic inventory script.

```
wget -O- bit.ly/ansibletest | env ANSIBLE_VERSIONS="system 1.4 2.0.0.2" sh
```

To test a different list of operating system images than the default,
use the `DOCKER_IMAGES` environment variable.

```
wget -O- bit.ly/ansibletest |
    env DOCKER_IMAGES="ubuntu:12.04 ubuntu:14.04 ubuntu:15.10 ubuntu:16.04" sh
```

To increase ansible-playbook verbose setting, use ANSIBLE_VERBOSE

```
wget -O- bit.ly/ansibletest |
    env ANSIBLE_VERBOSE="vvv" sh
```

License
-------

GPLv2

Author Information
------------------

http://wtanaka.com/
