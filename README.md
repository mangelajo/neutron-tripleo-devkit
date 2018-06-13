# neutron-tripleo-devkit

On the undercloud do

```bash
git clone https://github.com/mangelajo/neutron-tripleo-devkit
cd neutron-tripleo-devkit
git clone https://github.com/openstack/neutron
```

then edit the: containers and hosts file

After that you can use like:

```bash
./prep_images.sh
```

That command will take the existing images and install neutron
from sources on top, then push them back to the registry, one by one.


```bash
./deploy.sh
```

This second command will go into each host of the hosts file,
stop and remove the old neutron containers, and restart new
ones via "paunch" command.

Voila!


