#!/bin/sh
# Copyright (C) 2016 Wesley Tanaka <http://wtanaka.com/>
rm -rf fake-role/role-tester
mkdir -p fake-role/role-tester
tar cvf - . | (cd fake-role/role-tester; tar xvf -)
env ROLE_UNDER_TEST=fake-role make -C fake-role/role-tester
