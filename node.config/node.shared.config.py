#!/usr/bin/python

import subprocess
import time

lsblk = subprocess.Popen(['lsblk'], stdout=subprocess.PIPE,)
grep = subprocess.Popen(['grep', '260G'], stdin=lsblk.stdout, stdout=subprocess.PIPE,)
disk = grep.stdout.readlines()
id = []
for i in disk:
  subprocess.call(['sudo', 'parted', '-s', '/dev/' + i.split()[0], 'mklabel', 'gpt'])
  time.sleep(2)
  subprocess.call(['sudo', 'parted', '-s', '-a', 'opt', '/dev/' + i.split()[0], 'mkpart', 'extended', '0%', '100%'])
  time.sleep(2)
  subprocess.call(['sudo', 'mkfs.gfs2', '-O', '-t', 'hacluster:mygfs2', '-p', 'lock_dlm', '-j', '5', '/dev/' + i.split()[0] + '1'])