#!/bin/bash

# Detect and navigate to the python user site packages
# Some systems use `python3` instead of `python` so this is not entirely portable
cd "/home/freetak/FreeTAKServer-UI/" || raise error "Could not navigate to the user-sites path. Are you using a distro that requires python3 instead of python?"

# OBE as this is handled in the dockerfile, could be helpful in other kinds of deployments
# If config.py exists
#if test -f config.py; then
  # Then we need to move it to a "backup"
  # this way we can always give the user a new one if they delete theirs
#  mv config.py config.bak
#fi

# Check if there is *NOT* a config.py in the shared volume
if [[ ! -f "/home/freetak/data/config.py" ]]
  then
    # If there isn't, then we need to give one to the user
    cp config.bak /home/freetak/data/config.py
fi

# If the symlink has not been created yet, then we will do that
if [[ ! -f "config.py" ]]
  then
    ln -s /home/freetak/data/config.py config.py
fi

# TODO This can be implemented once the FTS-UI has an SSL operation mode
# Check if SSL certificates in the shared volumes exists
#if -n compgen -G "/home/freetak/data/*.crt" > /dev/null || compgen -G "/home/freetak/data/*.key" > /dev/null
#  then
    # generate some certs
#    openssl req -x509 -newkey rsa:4096 -keyout autgenerated-key.pem -out autogenerated-cert.pem -sha256 -days 3650 -nodes -subj "/C=XX/ST=Unknown/L=Unknown/O=FreeTAKServer/OU=FTS-UI/CN=localhost"
#fi

# Now we can start the server
python run.py