#!/bin/sh
set -e
# Copy test user ssh keys if they exist, so that ssh clients don't get a new
# entry in their known_hosts each time they conbect to a new container instance
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	/usr/bin/ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	/usr/bin/ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi

if [ -n "$AUTH_KEY" ]; then
    /bin/mkdir -p /root/.ssh/
	echo "$AUTH_KEY" > /root/.ssh/authorized_keys
	/bin/chmod 400 /root/.ssh/*
    /bin/mkdir -p /home/test/.ssh/
	echo "$AUTH_KEY" > /home/test/.ssh/authorized_keys
    /bin/chown test:test /home/test/.ssh/*
    /bin/chmod 400 /home/test/.ssh/*
fi

/usr/sbin/sshd
dockerd-entrypoint.sh

