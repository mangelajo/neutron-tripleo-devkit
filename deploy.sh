#!/bin/sh

source ./containers
source ./host

for host in $HOSTS
do
	ssh -t -t heat-admin@$host <<-SSH

		for i in $CONTAINERS
		do  
			   IDS="\$(sudo docker ps | grep \$i | awk '{ print \$1 }')" 
			   for ID in \$IDS; do
			     sudo docker stop \$ID 
			     sudo docker rm \$ID
			   done
			   sudo paunch debug --file /var/lib/tripleo-config/hashed-docker-container-startup-config-step_4.json --container \$i --action run 
		done
		exit
	SSH
done


