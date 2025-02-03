#!/bins/bash

# Update searchsploit
searchsploit -u

# Build linwinpwn
bash /opt/linWinPwn/install.sh

# Build Hoax Shell
cd /opt/hoaxshell; sudo pip3 install -r requirements.txt
chmod +x hoaxshell.py

# Add all tools in /opt to path
export PATH=$(find /opt -mindepth 1 -maxdepth 1 -type d -exec sh -c 'find "$1" -maxdepth 1 -type f -executable -print -quit' _ {} \; | tr '\n' ':' | sed 's/:$//'):$PATH