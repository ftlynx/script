#!/bin/env python
#
#Author : ftlynx
#Time   : 2014-07-31

import sys
import httplib
import getopt
import time


namelist=('accepts', 'handled', 'requests', 'Reading', 'Writing', 'Waiting')

def Usage():
	print "Usage: %s [options]" %sys.argv[0]
	print "	-h	host. Default: 127.0.0.1."
	print "	-p	port. Default: 80."
	print "	-u	url.  Default: /nginx_status"
	print "	-t	time interval. Default: 1s"
	print "	--help	help.\n"
	print "	eg: %s -h 127.0.0.1 -p 80 -t 1 -u /nginx_status" %sys.argv[0]
	exit(0)

def RequestHandle(host, port, url):
	header={'User-Agent':'ftlynx'}
	try:
		conn=httplib.HTTPConnection(host, port)
		conn.request('GET', url, headers=header)
		data=conn.getresponse()
		if data.status != 200:
			return 0
		html=data.read()
	except Exception, e:
		return 0
	finally:
		conn.close()
	return html

def NginxHtmlHandle(html):
	data={'accepts':0, 'handled':0, 'requests':0, 'Reading':0, 'Writing':0, 'Waiting':0}
	if html:
		rlist=html.split('\n')
		data['accepts']=rlist[2].split()[0]
		data['handled']=rlist[2].split()[1]
		data['requests']=rlist[2].split()[2]
		data['Reading']=rlist[3].split()[1]
		data['Writing']=rlist[3].split()[3]
		data['Waiting']=rlist[3].split()[5]
	return data	

def NginxRequestRate(now_data, last_data, rate):
	data={}
	for name in namelist:
		if name in ('accepts', 'handled', 'requests'):
			data[name]=(int(now_data[name])-int(last_data[name]))/rate
		else:
			data[name]=now_data[name]
	return data

def Main():
	host='127.0.0.1'
	port=80
	url="/nginx_status"
	interval=1
	try:
		opts, arg=getopt.getopt(sys.argv[1:], 'h:p:u:t:', ['help',])
	except Exception, e:
		print "Error: %s" %e
		Usage()
	for name, value in opts:
		if name == '-h':
			host=value
		if name == '-p':
			port=int(value)
		if name == '-u':
			url=value
		if name == '-t':
			interval=int(value)
		if name == "--help":
			Usage()
	while True:
		try:
			last_data=now_data
		except NameError:
			last_data=NginxHtmlHandle(RequestHandle(host, port, url))
		try:
			time.sleep(interval)
		except KeyboardInterrupt:
			exit(0)
		now_data=NginxHtmlHandle(RequestHandle(host, port, url))	
		data=NginxRequestRate(now_data, last_data, interval)
		print "[%s] " % time.strftime('%Y-%m-%d %H:%M:%S'),
		for key in namelist:
			print "%s : %s " %(key, data[key]),
		print 

if __name__ == "__main__":
	Main()
