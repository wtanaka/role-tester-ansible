#!/usr/bin/env python
# coding=utf-8
# Copyright (C) 2016 Wesley Tanaka <http://wtanaka.com/>
"""Rewrite .kitchen.yml with a specific list of ansible versions
"""

import os.path
import sys

from atomicwrites import atomic_write
import yaml

def main():
  ansible_versions = sys.argv[1:]
  kitchen_filename = os.path.join(
      os.path.dirname(__file__), '.kitchen.local.yml')
  old_ansible_filename = os.path.join(os.path.dirname(__file__),
      'broken-wheel-versions.txt')
  kitchen = {}
  with open(old_ansible_filename, 'rb') as fp:
    old_ansible_versions = fp.read().split()

  kitchen['suites'] = []
  for version in ansible_versions:
    suite = { 'name': 'ansible%s' % version }

    if version == 'system':
      pass
    else:
      suite['ansible_playbook_bin'] = \
          'ansible%s/bin/ansible-playbook' % version
      if version in old_ansible_versions:
        suite['raw_arguments'] = \
            '--module-path=ansible%s/share/ansible' % version
    kitchen['suites'].append(suite)

  with atomic_write(kitchen_filename, overwrite=True) as fp:
    yaml.dump(kitchen, fp)

if __name__ == "__main__":
  main()
