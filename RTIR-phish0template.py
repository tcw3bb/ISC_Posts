#!/usr/bin/python 
#version1.1
#Repalce the URL at the BOTTOM and enter a USER ID and PASSWORD
import requests,logging
import argparse
import re
import time

#ENTER VALID CREDENTIALS
login=""
passwd=""

parser = argparse.ArgumentParser(description='Create RT Ticket for Phishing')
parser.add_argument('--username', '-u', required=True, action="store", help='Username that got compromised')
parser.add_argument('--ip', action="store", required=True, help='IPs used by attacker')
parser.add_argument('--domain', required=True, help='Domain the attacker used for Phish')
parser.add_argument('--creator', required=True, help='Responder making ticket')
parser.add_argument('--time', required=True, help='Time worked in minutes')

args = parser.parse_args()
 
#logging.basicConfig(level=logging.DEBUG)
post_data = """
id: ticket/new
Queue: Incidents
Owner: %s
Subject: Automated Phishing Ticket %s
Text:Users Password was reset
TimeWorked: %s minutes
CF.{hacking.discovery_method}: Int-log review
CF.{hacking.targeted}: Opportunistic
CF.{impact.security_incident}: Confirmed
CF.{social.variety}: Phishing
CF.{social.vector}: Email
CF.{social.target}: End-user
CF.{confidentiality.data.variety}: Credentials
CF.{misuse.variety}: Email misuse
CF.{victim-username}: %s
CF.{ioc.attacker.ip}: %s
CF.{ioc.attacker.domain}: %s
""" %(args.creator,args.username, args.time, args.username, args.ip, args.domain)

payload = {'user': '%s'%(login), 'pass': '%s'%(passwd),'content':post_data} 
response=requests.post("https://MAKE YOUR IP:443/REST/1.0/ticket/new", payload , verify=False)
#print payload

#PARSE THE CONTENT FOR TICKET NUMBER
ticketnum= re.findall("\d\d\d\d", response.content)[0]

#########################
#RESOLVE TICKET
time.sleep(1) #Wait 1 sec 
close_data="""
Status: resolved
"""
url="https://MAKE YOUR IP:443/REST/1.0/ticket/%s/edit" %(ticketnum)

payload = {'user': '%s'%(login), 'pass': '%s'%(passwd),'content':close_data}
close=requests.post(url, payload , verify=False) 

print close.content
