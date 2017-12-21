#!/usr/bin/env python
# coding=utf-8
# Copyright (C) 2017 Wesley Tanaka <http://wtanaka.com/>
"""Output a yml structure suitable for overwriting
kitchen-playbook.yml
"""

import optparse
import os
import os.path

from atomicwrites import atomic_write
import yaml


def get_role_under_test(role_under_test):
  if role_under_test:
    return role_under_test

  role_under_test = os.environ.get('ROLE_UNDER_TEST', None)
  if role_under_test:
    return role_under_test

  role_under_test = os.path.basename(
      os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
  return role_under_test


def main():
  parser = optparse.OptionParser()
  parser.add_option("-r", "--role-under-test",
      dest="role_under_test",
      help="Name of role directory. "
      "Falls back to ROLE_UNDER_TEST environment, "
      "then to the name of this file's parent directory. "
      " (e.g. 'ansible-role-python-numpy')")
  (options, args) = parser.parse_args()

  role_under_test = get_role_under_test(options.role_under_test)

  playbook = []
  playbook.append({'include': 'playbook-compat.yml'})
  playbook.append({
      'hosts': 'all',
      'roles': [
          {
            'role': role_under_test,
            'is_integration_test': True,
          },
      ]
  })

  playbook_filename = os.path.join(
      os.path.dirname(__file__), 'kitchen-playbook.yml')
  # Work around issue in atomic_write where if
  # os.path.dirname(__file__) == '' then we get OSError: [Errno 2] No
  # such file or directory: ''
  playbook_filename = os.path.abspath(playbook_filename)
  with atomic_write(playbook_filename, overwrite=True) as fp:
    yaml.dump(playbook, fp)

if __name__ == "__main__":
  main()
