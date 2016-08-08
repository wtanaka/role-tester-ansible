#!/usr/bin/env python
# coding=utf-8
# Copyright (C) 2016 Wesley Tanaka <http://wtanaka.com/>
"""Rewrite .kitchen.yml with a specific list of ansible versions
"""

import optparse
import os.path
import sys

from atomicwrites import atomic_write
import yaml

def suites(ansible_versions):
  kitchen = {}
  old_ansible_filename = os.path.join(os.path.dirname(__file__),
      'broken-wheel-versions.txt')
  with open(old_ansible_filename, 'rb') as fp:
    old_ansible_versions = fp.read().split()

  kitchen['suites'] = []
  for version in ansible_versions:
    suite = { 'name': 'ansible%s' % version }

    if version == 'system':
      pass
    else:
      suite['provisioner'] = {}
      suite['provisioner']['ansible_playbook_bin'] = \
          'ansible%s/bin/ansible-playbook' % version
      if version in old_ansible_versions:
        suite['provisioner']['raw_arguments'] = \
            '--module-path=ansible%s/share/ansible' % version
    kitchen['suites'].append(suite)
  return kitchen


def platforms(os_versions):
  kitchen = {}
  kitchen['platforms'] = []
  for os_version in os_versions:
    platform = {
        'name': os_version.replace(':', '-'),
        'driver_config': {
            'image': os_version
        }
    }
    kitchen['platforms'].append(platform)
  return kitchen


def main():
  parser = optparse.OptionParser()
  parser.add_option("-a", "--ansible-versions",
      dest="ansible_versions",
      help="space-separated list of ansible versions (e.g. 'system 1.5.4')")
  parser.add_option("-o", "--os-versions",
      dest="os_versions",
      help="space-separated list of docker OS images"
      " (e.g.'ubuntu:15.10 ubuntu:16.04')")
  (options, args) = parser.parse_args()

  if not options.ansible_versions or not options.os_versions:
    parser.print_help()
    sys.exit(2)

  ansible_versions = options.ansible_versions.split()
  os_versions = options.os_versions.split()
  kitchen = {}
  kitchen.update(suites(ansible_versions))
  kitchen.update(platforms(os_versions))

  kitchen_filename = os.path.join(
      os.path.dirname(__file__), '.kitchen.local.yml')
  # Work around issue in atomic_write where if
  # os.path.dirname(__file__) == '' then we get OSError: [Errno 2] No
  # such file or directory: ''
  kitchen_filename = os.path.abspath(kitchen_filename)
  with atomic_write(kitchen_filename, overwrite=True) as fp:
    yaml.dump(kitchen, fp)

if __name__ == "__main__":
  main()
