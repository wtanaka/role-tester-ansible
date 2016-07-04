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

Test a different list of ansible versions than the default.  `system`
indicates that you want to test with the `ansible-playbook` on your
PATH (when you specify a version number, those are installed via
`pip`)

```
wget -O- bit.ly/ansibletest | env ANSIBLE_VERSIONS="system 1.5.4 2.0.0.2" sh
```


License
-------

GPLv2

Author Information
------------------

http://wtanaka.com/
