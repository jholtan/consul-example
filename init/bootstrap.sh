#!/bin/sh

TYPE=$1
WEBUI=$2

PID_FILE="/var/run/consul.pid"
BOOTSTRAP_ROOT="/tmp/bootstrap"

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

  cp $BOOTSTRAP_ROOT/init/consul.conf.upstart /etc/init/consul.conf
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
  if [ -e "$BOOTSTRAP_ROOT/gossip_secret" ]; then
      log "Enabling encryption using $BOOTSTRAP_ROOT/gossip_secret"
      GOSSIP_SECRET="\"encrypt\": \"$(cat $BOOTSTRAP_ROOT/gossip_secret)\","
  else
    log "No gossip_secret file found. Encryption is disabled."
  fi

  if [ $SERVER = "true" ]; then
    log "Generating bootstrap configuration file to /etc/consul.d/bootstrap.conf"
    sed -e "s;%NODENAME%;$NODENAME;g" \
    -e "s;%IPADDR%;$IPADDR;g" \
    -e "s;%GOSSIP_SECRET%;$GOSSIP_SECRET;g" \
    $BOOTSTRAP_ROOT/init/bootstrap.conf.template > /etc/consul.d/bootstrap.conf
  fi

  sed -e "s;%NODENAME%;$NODENAME;g" -e "s;%SERVER%;$SERVER;g" \
  -e "s;%IPADDR%;$IPADDR;g" -e "s;%UI_DIR%;$UI_DIR;g" \
  -e "s;%BROADCAST_EXPECT%;$BROADCAST_EXPECT;g" -e "s;%GOSSIP_SECRET%;$GOSSIP_SECRET;g" \
  $BOOTSTRAP_ROOT/init/consul.conf.template > /etc/consul.d/consul.conf
}

function install_consul_web() {
  yum install -y nginx
  cd /tmp
  curl -sL -O https://dl.bintray.com/mitchellh/consul/0.4.1_web_ui.zip
  mkdir /opt/consul_web && cd /opt/consul_web
  unzip /tmp/0.4.1_web_ui.zip
  cp $BOOTSTRAP_ROOT/init/nginx.conf /etc/nginx/conf.d/default.conf
  service nginx start
}

function consul_info() {
  log "To boostrap the cluster, SSH into a server and run"
  log " \$ consul agent -config-file /etc/consul.d/bootstrap.conf"
  log "This will put the server into bootstrap mode and the server will"
  log "self-elect as leader. Now shutdown the server using Ctrl-C and"
  log "restart it in server mode using "
  log " \$ start consul"
  log ""
  log "Start the other nodes in your network using the same command."
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

consul_info