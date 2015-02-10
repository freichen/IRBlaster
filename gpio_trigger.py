#!/usr/bin/python

import RPi.GPIO as GPIO
from pylms.server import Server
from pylms.player import Player
import sys
import time
import subprocess
from urllib2 import Request, urlopen, URLError

# initialise variables
client_name = ""
power_before = ""
power_after = ""
main_command = ""
sub_command = ""

# set variables if provided as command line parameters
if len(sys.argv) > 1:
	client_name = sys.argv[1]
if len(sys.argv) > 2:
	power_before = sys.argv[2]
if len(sys.argv) > 3:
	power_after = sys.argv[3]
if len(sys.argv) > 4:
	main_command = sys.argv[4]
if len(sys.argv) > 5:
	sub_command = sys.argv[5]

print client_name, power_before, power_after, main_command, sub_command

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(18, GPIO.OUT)

if power_after == "1" and power_before == "0":
	print "Turn amp and dac power sockets ON via 433MHz."
	subprocess.Popen(["/home/pi/codesend", "2175199"])
	time.sleep(0.5)
	subprocess.Popen(["/home/pi/codesend", "2175191"])
	time.sleep(11)
	print "Set GPIO trigger to 5v to bring amp out of standby."
	GPIO.output(18, GPIO.HIGH)
	time.sleep(1)
elif power_after == "0" and power_before == "1":
	print "Turn the telly off by making upnp http post request."
	data = '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:X_SendKey xmlns:u="urn:panasonic-com:service:p00NetworkControl:1#X_SendKey"><X_KeyEvent>NRC_POWER-ONOFF</X_KeyEvent></u:X_SendKey></s:Body></s:Envelope>'
	headers = { "SOAPACTION" : "urn:panasonic-com:service:p00NetworkControl:1#X_SendKey" }
	url = 'http://tv.home:55000/nrc/control_0'
	req = urllib2.Request(url, data, headers)
	try: urllib2.urlopen(req)
	except URLError as e:
		print e.reason
	print "Set GPIO trigger to 0v to send amp in to standby."
	GPIO.output(18, GPIO.LOW)
	time.sleep(3)
	print "Turn dac power socket OFF via 433MHz transmitter."
	subprocess.Popen(["/home/pi/codesend", "2175198"])
	time.sleep(0.5)
else:
	print "Power state unchanged or script error."
