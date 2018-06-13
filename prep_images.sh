#!/bin/bash

source images

set -x
set -e

if [ ! -d ./neutron ]; then 
 git clone https://github.com/openstack/neutron neutron
fi

for img in $IMAGES
do 
	echo ""
	echo "Building $img"
	cat Dockerfile.template | sed s/IMAGENAME/$img/g > Dockerfile
	TAG="192.168.24.1:8787/tripleomaster/$img:current-tripleo"
	docker build . -t $TAG 
	docker push $TAG
done


