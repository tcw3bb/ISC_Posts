#!/bin/bash
#Dshield Honeypot Log Report
#version .01
#Tom Webb
#@twsecblog
today=`date +%F`
today-post=`date +'%d %b %Y`'

#Move SQL file
cp /srv/www/DB/webserver.sqlite /tmp

echo
echo "############"
echo "Web Get Requests $today"
echo "############"
sqlite3 /tmp/webserver.sqlite "select datetime(date, 'unixepoch', 'localtime') AS mydate,path from requests where path != '/' and mydate like '%$today%';"

echo
echo
echo "############"
echo "Web POST Requests $today"
echo "############"
sqlite3 /tmp/webserver.sqlite "select date,path from postlogs where path != '/' and date like '%$today-post%';"

echo
echo
echo "############"
echo "Top USERAGENTS ALL TIME"
echo "############"
sqlite3 webserver.sqlite "select useragent from useragents;" |sort |uniq -c |sort -nr |head -n 20

echo
echo
echo "############"
echo "Top 20 COWRIE Usernames for $today"
echo "############"
cat /srv/cowrie/var/log/cowrie/cowrie.log |fgrep " auth " |cut -d ']' -f2 |awk '{print $1 "|" $4}'|sort |uniq -c |sort -nr|head -n 20

echo
echo
echo "############"
echo "Top 20 Connection Attempts for $today"
echo "############"
grep -o 'SRC=.*' /var/log/dshield.log  |cut -d '=' -f2|cut -d ' ' -f1 |sort |uniq -c |sort -nr |head -n 20

