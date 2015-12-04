#!/bin/bash
#Created by Tom Webb tw3bb@gmail.com
#Version 1.0
#This assumes you are using Security Onion with the bro logs folder having subfolders with date line YYYY-MM-DD

####CONFIG SECTION
brolog=/nsm/sensor_data/itso-sen-1/bro/itso-sen-1-eth4
WORKINGDIR=$(/bin/mktemp -d)
STATS_LOG=/var/log/phish-stats.log
##### 
usage () {

echo "This scripts automates metrics for a phishing campagin using BRO"
echo "bro-phish subject sender-email url YYYY-MM-DD (2015-10-12)"
echo "example >bro-phish \"mailbox full\"  bob@aol.com http://click-me.now.ef/wp-content/phish.php 2015-10-13 "
}


if [ $# -le 3 ]
 then
	usage
	exit 1
fi

subject=$1
sender=$2
url=$3
date=$4

#Get the stats for how many emails were sent
zcat $brolog/$date/smtp*|fgrep -w "$subject" |fgrep -w "$sender" >$WORKINGDIR/email
total_mail=`wc -l $WORKINGDIR/email |cut -d ' ' -f1`

if [ "$total_mail" -eq 0 ]; then

	echo "No Emails found"
	rm -rf $WORKINGDIR
	exit 1
else
	email_responses=`fgrep -w "RE: $subject" $WORKINGDIR/email |wc -l`
	zcat $brolog/$date/http* |fgrep -w "$url" >$WORKINGDIR/web-traffic	
	web_visits=`cat $WORKINGDIR/web-traffic|cut -d$'\t' -f3| sort |uniq |wc -l`
	post_web_visits=`fgrep POST $WORKINGDIR/web-traffic|wc -l`
	malicious_ip=`cat $WORKINGDIR/email| cut -d$'\t' -f3| sort |uniq|sed ':a;N;$!ba;s/\n/, /g'`
 	mail_agent=`cat $WORKINGDIR/email|cut -d$'\t' -f23 | sort |uniq`
	#helo_from=`cat $WORKINGDIR/email|cut -d$'\t' -f8 | sort |uniq`
	echo
	echo "#######Summary Details#####"
	echo "Total number of emails:$total_mail"
	echo "Possible replies to mail:$email_responses"
	echo "Total numbers of visitors to site:$web_visits"
	echo "Number of POSTS to the website:$post_web_visits"
	echo

	echo '#######DETAILS#####'
	echo "Malicious IP mail sent from:" $malicious_ip
	echo "Senders email address: $sender"	
	echo "Senders mail agent"  $mail_agent
	echo "Mail helo from" $helo_from


	echo "IPs that accessed Phishing Site:" 
	if [ $web_visits -ne 0 ]; then
	 ip_access=`cat $WORKINGDIR/web-traffic|cut -d$'\t' -f3| sort |uniq |sed ':a;N;$!ba;s/\n/, /g'`
	 echo $ip_access
	 echo
	 else
	   echo "NONE"
	   echo 
	fi
	echo "IPs that sent POSTS to phishing Site:"
 	if [ $post_web_visits -ne 0 ]; then
	 vic_ip=`fgrep POST $WORKINGDIR/web-traffic|cut -d$'\t' -f3| sort |uniq|sed ':a;N;$!ba;s/\n/, /g'`
	echo $vic_ip
	 else
	  echo "NONE"
	  echo
	fi	

	#Create log
	echo "$date|$sender|$subject|$total_mail|$email_responses|$web_visits|$post_web_visits|$malicious_ip|$mail_agent|$vic_ip" >>$STATS_LOG

fi
rm -rf $WORKINGDIR 
