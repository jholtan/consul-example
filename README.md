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
$ vagrant ssh <app1|app2>
```

Start Consul by running
```
$ consul agent -config-file /etc/consul.d/consul.conf
```


Enabling encryption
-------------------

Enabling gossip encryption ensures that no foreign agents can join the cluster

The command `consul keygen` will generate a 16-bit base64 encoded key that 
can be used as the shared secret. If the provisioning script locates a file
called `gossip_secret` in the root of this project, it will use the contents of
that file as the shared secret.

```
$ consul keygen > gossip_secret
```

All agents in the cluster need to have the same 16-bit key in order to 
communicate with eachother.
