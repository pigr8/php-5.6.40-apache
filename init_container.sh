#!/bin/bash
cat >/etc/motd <<EOL 
  _____                               
  /  _  \ __________ _________   ____  
 /  /_\  \\___   /  |  \_  __ \_/ __ \ 
/    |    \/    /|  |  /|  | \/\  ___/ 
\____|__  /_____ \____/ |__|    \___  >
        \/      \/                  \/ 
A P P   S E R V I C E   O N   L I N U X

PHP version : `php -v | head -n 1 | cut -d ' ' -f 2`
Apache version: `dpkg -l apache2 | grep ^ii | awk '{print $3}' | cut -f1 -d-`
EOL
cat /etc/motd

sed -i "s/{PORT}/$PORT/g" /etc/apache2/apache2.conf

echo "$@" > /opt/startup/startupCommand
/opt/startup/generateStartupCommand.sh
chmod 755 /opt/startup/startupCommand

STARTUPCOMMAND=$(cat /opt/startup/startupCommand)
echo "Running $STARTUPCOMMAND"
eval "exec $STARTUPCOMMAND"
