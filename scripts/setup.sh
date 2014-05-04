#!/bin/sh

HOST=`hostname -s`
if [ "$HOST" = "goserver" ]; then
    sh -x /vagrant/scripts/setup-server.sh
else
    sh -x /vagrant/scripts/setup-agent.sh
fi
