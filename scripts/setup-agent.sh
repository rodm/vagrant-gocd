#!/bin/sh

JDK=jdk1.7.0_65
JDK_FILE=jdk-7u65-linux-x64.tar.gz

# Install various packages required to run a Go Agent
if [ -f /etc/redhat-release ]; then
    cat > /etc/yum.repos.d/bintray-gocd-gocd-rpm.repo <<EOF
#bintraybintray-gocd-gocd-rpm - packages by gocd from Bintray
[bintraybintray-gocd-gocd-rpm]
name=bintray-gocd-gocd-rpm
baseurl=https://dl.bintray.com/gocd/gocd-rpm
gpgcheck=0
enabled=1
EOF
    yum -y install unzip
    yum -y install go-agent
else
    cat > /etc/apt/sources.list.d/bintray-gocd-deb.list <<EOF
#bintraybintray-gocd-gocd-deb - packages by gocd from Bintray
deb https://dl.bintray.com/gocd/gocd-deb /
EOF
    apt-get update -y
    apt-get install -y -q unzip
    apt-get install -y -q subversion
    apt-get install -y -q mercurial
    apt-get install -y -q git
    apt-get install -y -q --force-yes go-agent
fi

cat >> /etc/hosts <<EOF
192.168.80.40   goserver.localdomain goserver
EOF

# Configure Go Agent
sed -i -e "s/^GO_SERVER=.*$/GO_SERVER=goserver/g" /etc/default/go-agent

if [ -f /etc/redhat-release ]; then
    # Install Java
    mkdir -p /opt
    if [ ! -d /opt/$JDK ]; then
        tar -xzf /vagrant/files/$JDK_FILE -C /opt
    fi
    cat >> /etc/default/go-agent <<EOF
JAVA_HOME=/opt/jdk1.7.0_65
export JAVA_HOME
EOF
fi

/etc/init.d/go-agent start
