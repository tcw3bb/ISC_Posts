#!/bin/bash
#version 2
#Author Tom Webb @twsecblog
#based off script by Pablo Delgado 
#This script is to be ran on the Secuirty Onion Master Server to collect information about all the servers and send a notification error. 


#Set who you want to be notified. Speraated by comma
email_address=""

 # -f email of the sender(e.g. sender@test.com)  -s smtp server to use (e.g. test.yahoo.com:25)
send_email ()
{
sendemail -f <sender@aol.com> -s <smtp.test.com:25> -o tls=no -u $1  -a parsed_result.txt -m check it out -t $email_address
}

tdir=$(mktemp -d /tmp/tmp.XXXX)
cd $tdir

echo
echo "==================================== INITIATING Scripts =========================================="
echo
 
#2 - Checks Elasticsearch node to see if there's any Red Indexes. Red means that there's a problem with elasticsearch indexes and no data is being sent
elastic_check () {
echo "Checking ElasticsearchServer Processes"
salt '*' cmd.run "curl -s 127.0.0.1:9200/_cat/indices?v" 2>/dev/null |grep -i -E ' red'
if [ $? -eq 0 ] ; then #If red is in result
    echo "RED processes found"
    send_email  "ALERT-Elastic Cluster has a RED index on the server" 
else
    echo
    echo "Processes are running normal !"
fi
 
 
}
 
#3 - Checks for Low disk space on all servers.
disk_check() {
echo "===================="
echo
echo "Checking disk space usage above 85% on all servers"
disk_status=0
 salt '*' cmd.run "df -h" 2>/dev/null | awk '{print $5}'|grep -vE '^Filesystem|tmpfs|cdrom|Use' |cut -d '%' -f1,2|sed 's/%//'|awk 'NF'|while read percent drive;
	 do
		  if [ $percent -ge 85 ]; 
			then 
			  send_email "ALERT-LOW DISK SPACE on a Device"
			  disk_status=1 
			
			  return

		  fi 

	 done

#Check if any error. No repeats from While loop
	 if [ $disk_status -eq 0 ];
	    then 
		echo
		echo "Disk status GOOD"
 	fi		
echo "===================="

} 

# Checks to see if logstash is processing logs between 1 sec wait period on all systems
logstash_check () {
echo
echo "===================="
echo "Checking logstash output"
echo
for salt_minion in `salt-run manage.up 2>/dev/null |awk '{print $2}'`; 
	do

		start=`curl -s -XGET 'localhost:9600/_node/stats/events?pretty' |fgrep out |awk '{print $3}'|cut -d ',' -f1`
		sleep 1
		stop=`curl -s -XGET 'localhost:9600/_node/stats/events?pretty' |fgrep out |awk '{print $3}'|cut -d ',' -f1`

		 if [ $start -eq $stop ]
		   then
			echo "error"
		        echo	"send_email "ALERT-$salt_minion Logstash not processing logs""
		   else
			echo "$salt_minion is GOOD!"
		 fi
	done


echo
echo "===================="
 
#5 - Logstash - checks the logstash-plain.log for any Plugin errors. 
 
echo "Checking logstash for error messages"
tail -n40 /var/log/logstash/logstash.log > Status_logs.txt
grep -i -E 'A plugin had an unrecoverable error.' Status_logs.txt > parsed_result.txt
if [ $? -eq 0 ] ; then
    echo "ERROR FOUND"
    send_email "ALERT-Holmes logstash error" 
else
    echo
    echo "Logs are fine !"
fi
 
}

redius_check() {
echo
echo "===================="
#CHECK REDIS QUEUE Alerts if over 500,000
queue=`redis-cli LLEN logstash:redis|awk '{print $1}'`
re='^[0-9]+$'
echo "Checking Redis Queue"
if ! [[ $queue =~ $re ]] ; then 
	echo "REDDIS IS REALLY MESSED UP, Queue broke"
	send_email "ALERT-Holmes Redis Queue output error"
else
	if [ $queue -gt 500000 ] ; then 
	  send_email "ALERT-Holmes Redis Queue than 500k" 

	else 
	   echo "Redis Good Queue:" $queue
	fi
fi

}


disk_check
elastic_check
logstash_check
redius_check
 
echo
echo "====================================== SCRIPT SEQUENCE COMPLETE ========================================"
echo

rm -rf $tdir
exit 0
