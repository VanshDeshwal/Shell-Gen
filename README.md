# Shell-Gen
<a>A simple script to generate all kinds of reverse shells with your "Hack the box" or "Try Hack Me" Virtual IP address built in</a>
<p>usage:
  ./shells.sh -s &lt;shell type&gt; </p>
  <p>For Help use:
  ./shells.sh -h </p>
  
<p>example:
./shells.sh -s bash </p>

## Basic Information
The goal of this script is to generate various types of reverse shells preconfigured to your needs quickly.
This script doesn't have any dependency.
Shell-Gen uses color codings to keep you focus on the important stuff
The script tries to automatically identify if you are connected to open vpn or not to give you a quick hasstle free personalised shell
You can also select the IP you want to use through the following flags

**Other parameters:**
- **-v**   - This will **use the virtual ip address that Hack The Box, Try Hack Me or any other similar website provided you**
- **-l**   - This will **use you local ip address in case you are working with a Vulnhub Machine**
- **-u**   - Adding this flag will give you a url encoded version of the shell along with the shell itself

## Improvements and modifications
Feel free to fix any bugs and make changes to the script

## To Do List

-Make the output more descriptive
-Make it installable
-Add more Shells



By VanshD<sup>(TM)</sup>
