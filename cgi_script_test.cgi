#!/usr/bin/python

import cgi, cgitb
import json
import subprocess
import os

# Create instance of FieldStorage
form = cgi.FieldStorage()

# Get data from fields
json_string = """{"Truseq":"0","Nextera":"0","NEB":"0","Bioo-6mer":"0","Bioo-8mer":"27","HumanTCRa":"0","HumanTCRb":"0","MouseTCRa":"0","MouseTCRb":"0","Amaryllis":"0","barcodes":" - "}"""

#json_output = os.system("perl barcode_json.pl '"+json_string+"'")
#json_output = os.system("ls")

print("Content-type:text/html\r\n\r\n")
print('<html>')
print('<head>')
print('<title>Hello Word - First CGI Program</title>')
print('</head>')
print('<body>')
print('<h2>Hello Word! This is my first CGI program</h2>')
print(json_string)
#print(json_output)
print('</body>')
print('</html>')
