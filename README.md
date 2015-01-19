Consul example
==============

Requires [Vagrant](https://www.vagrantup.com/).

Start the Vagrant images. This will also install Consul on the virtual servers.
```
$ vagrant up
```

Start Consul by running
```
$ consul -config-file /etc/consul.d/consul.conf
```