#!/bin/sh

NTP_SERVER=time.euro.apple.com

JDK=jdk1.7.0_65
JDK_FILE=jdk-7u65-linux-x64.tar.gz

GO_VERSION=14.2.0
GO_NAME=go-server-${GO_VERSION}
GO_ARCHIVE=${GO_NAME}-377.zip
GO_SERVER_URL=http://download.go.cd/gocd/$GO_ARCHIVE
GO_DIR=/opt/${GO_NAME}
GO_USER=go
GO_GROUP=go

# Install various packages required to run Go Server
if [ -f /etc/redhat-release ]; then
    yum -y install ntp
else
    apt-get update -y
    apt-get install -y -q ntp
    apt-get install -y -q unzip
    apt-get install -y -q subversion
    apt-get install -y -q mercurial
    apt-get install -y -q git
fi

# Configure ntp server
sudo /etc/init.d/ntp stop
sed -e "s/^server.*$/server $NTP_SERVER/" < /etc/ntp.conf > /tmp/ntp.conf && sudo mv /tmp/ntp.conf /etc/ntp.conf
sudo /etc/init.d/ntp start

# Install Java
mkdir -p /opt
if [ ! -d /opt/$JDK ]; then
    tar -xzf /vagrant/files/$JDK_FILE -C /opt
fi

# Install Go Server file
if [ ! -f $GO_DIR/server.sh ]; then
    if [ ! -f /vagrant/files/$GO_ARCHIVE ]; then
        wget -q --no-proxy $GO_SERVER_URL -P /vagrant/files
    fi
    unzip -q /vagrant/files/$GO_ARCHIVE -d /opt
    chmod +x $GO_DIR/*.sh
fi

# Setup a user to run the Go Server
/usr/sbin/groupadd -r $GO_GROUP 2>/dev/null
/usr/sbin/useradd -c $GO_USER -r -s /bin/bash -d $GO_DIR -g $GO_GROUP $GO_USER 2>/dev/null

chown -R $GO_USER:$GO_GROUP $GO_DIR
