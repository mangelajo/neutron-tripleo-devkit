#!/bin/bash

# Copyright 2018 Red Hat, Inc.
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

# With LANG set to everything else than C completely undercipherable errors
# like "file not found" and decoding errors will start to appear during scripts
# or even ansible modules
LANG=C

# Complete stackrc file path.
: ${STACKRC_FILE:=~/stackrc}

# Complete overcloudrc file path.
: ${OVERCLOUDRC_FILE:=~/overcloudrc}

check_for_necessary_files() {
    if [ ! -e inventory ]
    then
        echo "ansible inventory file not present"
        echo "Please run $0 generate-inventory"
        exit 1
    fi

    if [ ! -e containers.yml ]
    then
	echo "creating initial containers.yml, please modify to suit your needs"
        cp -v containers.yml.sample containers.yml
    fi

    if [ ! -d neutron ]
    then
        git clone https://github.com/openstack/neutron neutron
    fi
}

# Generate the inventory file for ansible playbooks.
generate_ansible_inventory_file() {
    echo "Generating the inventory file for ansible-playbook"
    source $STACKRC_FILE
    echo "[controllers]"  > inventory
    CONTROLLERS=`openstack server list -c Name -c Networks | grep controller | awk  '{ split($4, net, "="); print net[2] }'`
    for node_ip in $CONTROLLERS
    do
        echo $node_ip ansible_ssh_user=heat-admin ansible_become=true >> inventory
    done

    echo "" >> inventory
    echo "[computes]" >> inventory
    for node_ip in `openstack server list -c Name -c Networks | grep compute | awk  '{ split($4, net, "="); print net[2] }'`
    do
        echo $node_ip ansible_ssh_user=heat-admin ansible_become=true >> inventory
    done

    echo "" >> inventory

    echo "[undercloud]" >> inventory
    echo "localhost ansible_connection=local" >> inventory
    echo "" >> inventory

    echo "***************************************"
    cat inventory
    echo "***************************************"
    echo "Generated the inventory file - inventory"
}

prep_images() {
    source $STACKRC_FILE
    echo "Preparing images"
    ansible-playbook  ./playbooks/prep-images.yml \
    	              -e @containers.yml $*

    rc=$?
    return $rc
}
start_deployment() {
    source $STACKRC_FILE
    echo "Starting the deployment"
    ansible-playbook  ./playbooks/deployment.yml \
    		      -e @containers.yml -i inventory $*

    rc=$?
    return $rc
}

print_usage() {
        echo "Usage:"
        echo "./devkit.sh generate-inventory"
        echo "./devkit.sh prep-images"
        echo "./devkit.sh deploy"
}

command=$1

ret_val=0
case $command in
    generate-inventory)
        generate_ansible_inventory_file
        ret_val=$?
        ;;

    prep-images)
        check_for_necessary_files
        shift
        prep_images $*
        ret_val=$?
	;;

    deploy)
        check_for_necessary_files
        shift
        start_deployment $*
        ret_val=$?
        ;;

    *)
        print_usage;;
esac

exit $ret_val
