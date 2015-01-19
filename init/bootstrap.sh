#!/bin/sh

TYPE=$1
WEBCLIENT=$2

function err() {
  echo $1
  exit 1
}

function usage_and_exit() {
  err "Usage: $0 [type]<server|client> [install web ui]<true|false>"
}

function install_consul() {
  cd /tmp
  curl -L -O https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip
  cd /usr/local/bin/
  unzip /tmp/0.4.1_linux_amd64.zip
}

function install_consul_web() {
  cd /tmp
  curl -L -O https://dl.bintray.com/mitchellh/consul/0.4.1_web_ui.zip
  mkdir /opt/consul_web && cd /opt/consul_web
  unzip /tmp/0.4.1_web_ui.zip
}

test -n "$TYPE" || usage_and_exit

# Install dependencies
yum install -y curl bind-utils

test -e "/usr/local/bin/consul" || install_consul
if [ $WEBCLIENT = "true" ]; then
  test -d "/opt/consul_web" || install_consul_web
fi
