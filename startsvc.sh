#!/bin/bash
i=$1
sed -i 's/^$/+ : '$i' : ALL/' /etc/security/access.conf
echo "$i ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$i
/usr/sbin/sshd -e
service mysql restart
service asterisk restart
service freepbx restart
