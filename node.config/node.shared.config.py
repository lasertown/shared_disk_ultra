#!/usr/bin/python

import subprocess

lsblk = subprocess.Popen(['lsblk'], stdout=subprocess.PIPE,)
grep = subprocess.Popen(['grep', '512G'], stdin=lsblk.stdout, stdout=subprocess.PIPE,)
disk = grep.stdout.readlines()
id = []
for i in disk:
  ls = subprocess.Popen(['ls', '-la', '/dev/disk/by-id/'], stdout=subprocess.PIPE,)
  grep2 = subprocess.Popen(['grep', i[0:3]], stdin=ls.stdout, stdout=subprocess.PIPE,)
  grep3 = subprocess.Popen(['grep', 'scsi-3'], stdin=grep2.stdout, stdout=subprocess.PIPE,)
  id.append('/dev/disk/by-id/' + grep3.stdout.read().split()[8])
for i in id:
#  subprocess.call(['sudo', 'sbd', '-d', i, '-1', '60', '-4', '120', 'create'])
  print i