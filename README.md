# Shell-Gen
<a>A simple script to generate all kinds of reverse shells using your "Hack the box" or "Try Hack Me" Virtual IP address</a>
<a>This script also starts a listner for your reverse shell by default and copies the shell to clipboard</a>


## Getting Started

```bash
#From github
git clone https://github.com/VanshDeshwal/Shell-Gen.git
```
**Usage:**
 ```
 ./shells.sh -s<shell>
 ```
**Example:**

```
./shells.sh -s bash
```

## Basic Information
The goal of this script is to generate various types of reverse shells **preconfigured** to your needs quickly.
This script doesn't have any dependencies except **xclip** that is optional.
Shell-Gen uses **color codings** to keep you focus on the important stuff
The script tries to **automatically identify if you are connected to open vpn or not** to give you a quick hasstle free personalised shell
You can also select the **IP** and **PORT** you want to use through the following flags

**Other parameters:**
- **-v**   - This will **use the virtual ip address that Hack The Box, Try Hack Me or any other similar website provided you**
- **-l**   - This will **use you local ip address in case you are working with a Vulnhub Machine**
- **-u**   - Adding this flag will give you a **url encoded version of the shell** along with the shell itself
- **-x**   - This will **stop** the script from starting a **listner** for you shell
- **-p**   - You can specify the **port you want to use** for the reverse shell
- **-o**   - Show the **available Options/Shells**

## Dependencies
This script copies the reverse shell to you clipboard automatically so you would need x-clip for this functionality

```sudo apt install xclip```

## Improvements and modifications
Feel free to fix any bugs and make changes to the script

## To Do List

-Make the output more descriptive
-Make it installable
-Add more Shells



By VanshD<sup>(TM)</sup>
