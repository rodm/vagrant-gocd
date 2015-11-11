#!/bin/sh

JDK=jdk1.7.0_65
JDK_FILE=jdk-7u65-linux-x64.tar.gz

GO_VERSION=14.2.0
GO_NAME=go-agent-${GO_VERSION}
GO_ARCHIVE=${GO_NAME}-377.zip
GO_AGENT_URL=http://download.go.cd/gocd/$GO_ARCHIVE
GO_DIR=/opt/${GO_NAME}
GO_USER=go
GO_GROUP=go

# Install various packages required to run a Go Agent
if [ -f /etc/redhat-release ]; then
    yum -y install unzip
else
    apt-get update -y
    apt-get install -y -q unzip
    apt-get install -y -q subversion
    apt-get install -y -q mercurial
    apt-get install -y -q git
fi

cat >> /etc/hosts <<EOF
192.168.80.40   goserver.localdomain goserver
EOF

# Install Java
mkdir -p /opt
if [ ! -d /opt/$JDK ]; then
    tar -xzf /vagrant/files/$JDK_FILE -C /opt
fi

# Install Go Agent file
if [ ! -f $GO_DIR/agent.sh ]; then
    if [ ! -f /vagrant/files/$GO_ARCHIVE ]; then
        wget -q --no-proxy $GO_AGENT_URL -P /vagrant/files
    fi
    unzip -q /vagrant/files/$GO_ARCHIVE -d /opt
    chmod +x $GO_DIR/*.sh
fi

# Setup a user to run the Go Agent
/usr/sbin/groupadd -r $GO_GROUP 2>/dev/null
/usr/sbin/useradd -c $GO_USER -r -s /bin/bash -d $GO_DIR -g $GO_GROUP $GO_USER 2>/dev/null

chown -R $GO_USER:$GO_GROUP $GO_DIR
