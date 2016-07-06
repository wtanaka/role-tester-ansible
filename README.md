[![Build Status](https://travis-ci.org/wtanaka/role-tester-ansible.svg?branch=master)](https://travis-ci.org/wtanaka/role-tester-ansible)

Role Tester for Ansible Roles
=============================

Requirements
------------

* Docker
* bundler
* ffi.h (brew install pkg-config libffi on Mac OS X)

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
specify a version number, those are installed via `pip`

```
wget -O- bit.ly/ansibletest | env ANSIBLE_VERSIONS="system 1.5.4 2.0.0.2" sh
```

To test a different list of operating system images than the default,
use the `DOCKER_IMAGES` environment variable.

```
wget -O- bit.ly/ansibletest |
    env DOCKER_IMAGES="ubuntu:12.04 ubuntu:14.04 ubuntu:15.10 ubuntu:16.04" sh
```

License
-------

GPLv2

Author Information
------------------

http://wtanaka.com/
