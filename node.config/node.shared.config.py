#!/usr/bin/python

import subprocess

lsblk = subprocess.Popen(['lsblk'], stdout=subprocess.PIPE,)
grep = subprocess.Popen(['grep', '-w', '64G'], stdin=lsblk.stdout, stdout=subprocess.PIPE,)
disk = grep.stdout.readlines()
id = []
for i in disk:
  subprocess.call(['sudo', 'parted', '-s', '/dev/' + i.split()[0], 'mklabel', 'gpt'])
  subprocess.call(['sudo', 'parted', '-s', '-a', 'opt', '/dev/' + i.split()[0], 'mkpart', 'extended', '0%', '100%'])
  subprocess.call(['sudo', 'mkfs.gfs2', '-O', '-t', 'hacluster:mygfs2', '-p', 'lock_dlm', '-j', '2', '/dev/' + i.split()[0] + '1'])