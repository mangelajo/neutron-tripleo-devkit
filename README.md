# neutron-tripleo-devkit

On the undercloud do

```bash
git clone https://github.com/mangelajo/neutron-tripleo-devkit
cd neutron-tripleo-devkit
git clone https://github.com/openstack/neutron
```

feel free to edit the containers.yml to suit your needs
```bash
cp containers.yml.sample containers.yml
vi containers.yml
```

## Build the images

```bash
./devkit.sh prep-images
```

That command will take the existing images and install neutron
from sources on top, then push them back to the registry, one by one.

## Deploy the images to the hosts

```bash
./devkit.sh deploy
```
This last command will go into each host of the hosts file,
stop and remove the old neutron containers, and restart new
ones via "paunch" command.

Voila!


