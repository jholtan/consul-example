Consul example
==============


Initializing
------------

Requires [Vagrant](https://www.vagrantup.com/).

Start the Vagrant images. This will also install Consul on the virtual servers.
```
$ vagrant up
```

To log into the virtual machines use
```
$ vagrant ssh <app1|app2|...>
```

Starting consul:
```
$ sudo start consul
```

Consul will log to `/var/log/consul.log`

Bootstrapping the cluster
-------------------------

Start one of the servers in bootstrap mode
```
$ consul agent -config-file /etc/consul.d/bootstrap.conf
```

The server will bootstrap the cluster and elect itself as leader. Then bring the
other servers up by running the command
```
$ sudo start consul
```
To have a running server join the cluster bootstrapped by the leader, use
```
$ cluster join <ip address of leader>
```

As long as you have 3 or more servers in the cluster, you can bring down the 
leader and restart it in normal mode.


Enabling encryption
-------------------

**Gossip protocol encryption**

Enabling gossip protocol encryption protects your system against eavesdropping,
data tampering and fake nodes.

The command `consul keygen` will generate a 16-bit base64 encoded key that
can be used as the shared secret. If the provisioning script locates a file
called `gossip_secret` in the root of this project, it will use the contents of
that file as the shared secret.

```
$ consul keygen > gossip_secret
```

All agents in the cluster need to have the same 16-bit key in order to 
communicate with eachother.

**RPC protocol encryption**

The RPC protocol supports TLS encryption. This example does not enable TLS
encryption.

[More on encryption](https://www.consul.io/docs/agent/encryption.html).

Services and health checks
--------------------------



To register a health check you can POST 
```
{
  "ID": "hw-health-check",
  "Name": "Hello World Health Check",
  "Notes": "Simple example of a check",
  "Script": "curl -s http://localhost:8090/",
  "Interval": "10s"
}
```

to `http://localhost:8080/v1/agent/check/register`

DNS interface
-------------
`dig @127.0.0.1 -p 8600 service.datacenter.consul`


Key/value store
---------------




Tools
-----

**envconsul**

**consul_template**


Stuff not covered
-----------------

- [Watches](https://www.consul.io/docs/agent/watches.html)
- [Sessions](https://www.consul.io/docs/internals/sessions.html)
- [Access Control Lists](http://www.consul.io/docs/internals/acl.html)