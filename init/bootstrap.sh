#!/bin/sh

TYPE=$1
WEBUI=$2

PID_FILE="/var/run/consul.pid"

function err() {
  echo $1
  exit 1
}

function log() {
  echo "Config: $1"
}

function usage_and_exit() {
  err "Usage: $0 [type]<server|client> [install web ui]<true|false>"
}

function install_consul() {
  cd /tmp
  curl -sL -O https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip
  cd /usr/local/bin/
  unzip /tmp/0.4.1_linux_amd64.zip

  cp /tmp/bootstrap/init/consul.conf.upstart /etc/init/consul.conf
}

function configure_consul() {
  test -e "/etc/consul.d/consul.conf" && rm "/etc/consul.d/consul.conf"
  mkdir /etc/consul.d 2>/dev/null
  NODENAME=`hostname`
  IPADDR=$(/sbin/ifconfig eth1 | sed -n '2 p' | cut -d: -f2 | awk '{print $1}')
  log "Detected host IP address: $IPADDR"

  SERVER="false"
  BROADCAST_EXPECT="0"
  if [ $TYPE = "server" ]; then
    SERVER="true"
    BROADCAST_EXPECT="1"
  fi

  UI_DIR=""
  if [ $WEBUI = "true" ]; then
    log "Enabling Consul Web UI"
    UI_DIR="/opt/consul_web/dist"
  fi

  GOSSIP_SECRET=""
  if [ -e "/tmp/bootstrap/gossip_secret" ]; then
      log "Enabling encryption using /tmp/bootstrap/gossip_secret"
      GOSSIP_SECRET="\"encrypt\": \"$(cat /tmp/bootstrap/gossip_secret)\","
  else
    log "No gossip_secret file found. Encryption is disabled."
  fi

  sed -e "s;%NODENAME%;$NODENAME;g" -e "s;%SERVER%;$SERVER;g" \
  -e "s;%IPADDR%;$IPADDR;g" -e "s;%UI_DIR%;$UI_DIR;g" \
  -e "s;%BROADCAST_EXPECT%;$BROADCAST_EXPECT;g" -e "s;%GOSSIP_SECRET%;$GOSSIP_SECRET;g" \
  /tmp/bootstrap/init/consul.conf.template > /etc/consul.d/consul.conf 
}

function install_consul_web() {
  yum install -y nginx
  cd /tmp
  curl -sL -O https://dl.bintray.com/mitchellh/consul/0.4.1_web_ui.zip
  mkdir /opt/consul_web && cd /opt/consul_web
  unzip /tmp/0.4.1_web_ui.zip
}

function start_consul() {
  if [ -e $PID_FILE ]; then
    log "Consul running. Sending SIGHUP"
    kill -1 `cat $PID_FILE`
  else
    log "Starting consul"
    start consul
  fi
}

test -n "$TYPE" || usage_and_exit
test -n "$WEBUI" || usage_and_exit

# Install dependencies
yum install -y curl bind-utils

test -e "/usr/local/bin/consul" || install_consul
if [ $WEBUI = "true" ]; then
  test -d "/opt/consul_web" || install_consul_web
fi

configure_consul

start_consul