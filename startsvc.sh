#!/bin/bash
i=$1
sed -i 's/^$/+ : '$i' : ALL/' /etc/security/access.conf
echo "$i ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$i
mkdir -p /run/sshd
/usr/sbin/sshd -e
service apache2 restart
chown -R asterisk. /var/www
service mysql restart
/usr/sbin/fwconsole restart
/bin/bash

#cd /usr/src/freepbx
#./start_asterisk start
#./install -n
