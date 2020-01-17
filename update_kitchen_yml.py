#!/usr/bin/env python
# coding=utf-8
# Copyright (C) 2016 Wesley Tanaka <http://wtanaka.com/>
"""Rewrite .kitchen.yml with a specific list of ansible versions
"""

import optparse
import os
import os.path
import sys

from atomicwrites import atomic_write
import yaml

def suites(ansible_versions):
  kitchen = {}
  broken_wheel_filename = os.path.join(os.path.dirname(__file__),
      'broken-wheel-versions.txt')
  with open(broken_wheel_filename, 'rb') as fp:
    broken_wheel_versions = fp.read().split()

  use_sudo_filename = os.path.join(os.path.dirname(__file__),
      'sudo-versions.txt')
  with open(use_sudo_filename, 'rb') as fp:
    use_sudo_versions = fp.read().split()

  kitchen['suites'] = []
  for version in ansible_versions:
    suite = { 'name': 'ansible%s' % version }

    if version == 'system':
      pass
    else:
      suite['provisioner'] = {}
      suite['provisioner']['ansible_playbook_bin'] = \
          '.bootci/ansible-playbook%s.sh' % version
      if version in use_sudo_versions:
        suite['provisioner']['playbook'] = \
            'kitchen-playbook-sudo.yml'
      if version in broken_wheel_versions:
        suite['provisioner']['raw_arguments'] = \
            '--module-path=.bootci/venv-ansible%s/share/ansible' % version
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


def provisioner(role_under_test):
  kitchen = {
    'provisioner': {
      'extra_vars': {
        'role_under_test': role_under_test,
      }
    }
  }
  return kitchen


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
  parser.add_option("-a", "--ansible-versions",
      dest="ansible_versions",
      help="space-separated list of ansible versions (e.g. 'system 1.5.4')")
  parser.add_option("-o", "--os-versions",
      dest="os_versions",
      help="space-separated list of docker OS images"
      " (e.g.'ubuntu:15.10 ubuntu:16.04')")
  parser.add_option("-r", "--role-under-test",
      dest="role_under_test",
      help="Name of role directory. "
      "Falls back to ROLE_UNDER_TEST environment, "
      "then to the name of this file's parent directory. "
      " (e.g. 'ansible-role-python-numpy')")
  (options, args) = parser.parse_args()

  if not options.ansible_versions or not options.os_versions:
    parser.print_help()
    sys.exit(2)

  ansible_versions = options.ansible_versions.split()
  os_versions = options.os_versions.split()
  role_under_test = get_role_under_test(options.role_under_test)

  kitchen = {}
  kitchen.update(suites(ansible_versions))
  kitchen.update(platforms(os_versions))
  kitchen.update(provisioner(role_under_test))

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
