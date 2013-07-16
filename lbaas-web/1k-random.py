# Copyright 2012 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

#!/usr/bin/python
# adapted from http://www.deitel.com/articles/internet_web_tutorials/20060225/PythonCGIProgramming/

import os
import cgi
import string
import socket
import datetime
import random

print "Content-type: text/html"
print

print """<!DOCTYPE html PUBLIC
   "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "DTD/xhtml1-transitional.dtd">"""

print """
<html xmlns = "http://www.w3.org/1999/xhtml" xml:lang="en"
   lang="en">
   <head><title>1k random char output</title></head>
   <META HTTP-EQUIV="Pragma" CONTENT="no-cache">
   <META HTTP-EQUIV="Expires" CONTENT="-1">
   <body><table style = "border: 0">"""

rowNumber = 0
report_data = {}
y = []
char_count = 1000
for i in range(char_count):
    y.append(random.choice(string.printable))
report_data['__RANDOM_CONTENT'] = ''.join(y)
desired_keys = ['SERVER_SIGNATURE'
               ,'SERVER_NAME'
               ,'REMOTE_ADDR'
               ,'SERVER_ADDR'
               ]
for item in desired_keys:
    report_data[item] = os.environ[item]
report_data['HOSTNAME'] = socket.gethostname()
report_data['GENERATED_ON'] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

report_keys = report_data.keys()
report_keys.sort()
for item in report_keys:
   rowNumber += 1
   if rowNumber % 2 == 0:
      backgroundColor = "white"
   else:
      backgroundColor = "lightgrey"
   print """<tr style = "background-color: %s">
   <td>%s</td><td>%s</td></tr>""" \
      % ( backgroundColor, item,
         cgi.escape( report_data[item]))
print """</table>"""
print """<br>"""
print """</body></html>"""
