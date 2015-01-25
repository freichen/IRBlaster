#!/usr/bin/python

import RPi.GPIO as GPIO
from pylms.server import Server
from pylms.player import Player
import sys
import time
import subprocess

print "Running ", sys.argv[0], " script."

# slightly inelegant way of setting variables if they exist
if sys.argv[1]:
	client_name = sys.argv[1]
else:
	client_name = ""
if sys.argv[2]:
	power_before = sys.argv[2]
else:
	power_before = ""
if sys.argv[3]:
	power_after = sys.argv[3]
else:
	power_after = ""
if sys.argv[4]:
	main_command = sys.argv[4]
else:
	main_command = ""
if sys.argv[5]:
	sub_command = sys.argv[5]
else:
	sub_command = ""

print client_name, power_before, power_after, main_command, sub_command

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(18, GPIO.OUT)

if power_after == "1" and power_before == "0":
	print "Turn amp and dac power sockets ON via 433MHz. Set GPIO trigger to 5v to bring amp out of standby."
	subprocess.Popen(["/home/pi/codesend", "2175199"])
	time.sleep(0.5)
	subprocess.Popen(["/home/pi/codesend", "2175191"])
	time.sleep(11)
	GPIO.output(18, GPIO.HIGH)
	time.sleep(1)
elif power_after == "0" and power_before == "1":
	"Turn dac power socket OFF via 433MHz. Set GPIO trigger to 0v to send amp to standby."
	GPIO.output(18, GPIO.LOW)
	time.sleep(3)
	subprocess.Popen(["/home/pi/codesend", "2175198"])
	time.sleep(0.5)
else:
	print "Power state unchanged or script error."
