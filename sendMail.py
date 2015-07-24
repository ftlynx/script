#!/bin/env python

#coding=utf8
#Time   : 2014-07-04
#author : ftlynx

import smtplib
import sys
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

#smtp server config
mail_server_name="smtp.exmail.qq.com"
login_user="11111111111@qq.com"
login_password="1111111111"
ssl=False

def SendEmail(to_adder, Subject, Body):
	msg = MIMEMultipart()
	msg['From'] = login_user
	msg['To'] = to_adder
	msg['Subject']=Subject
	txt = MIMEText(Body)
	msg.attach(txt)
	if ssl :
		#smtplib.SMTP_SSL() after  python2.6 support
		smtp = smtplib.SMTP_SSL()
	else:
		smtp = smtplib.SMTP()
	try:
	#	smtp.set_debuglevel(1)
		smtp.connect(mail_server_name)
		smtp.login(login_user, login_password)
		smtp.sendmail(msg['From'], msg['To'], msg.as_string())
		smtp.quit()
	except KeyboardInterrupt:
		pass
	except Exception, e:
		print 'Error: %s' % e

if __name__ == '__main__':
	SendEmail(sys.argv[1], sys.argv[2], sys.argv[3])
