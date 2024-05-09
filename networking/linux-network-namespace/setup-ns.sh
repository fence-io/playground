#!/bin/bash

# Function to create namespace and veth pair
create_namespace_and_veth() {
    echo "***Creating namespace $1"
    ip netns add $1

    echo "Creating veth pair, hlink$2 & clink$2"
    ip link add hlink$2 type veth peer name clink$2

    echo "Moving clink$2 to $1 namespace"
    ip link set clink$2 netns $1
}

# Function to set up veth pair inside the network namespace
setup_namespace() {
    nsenter --net=/run/netns/$1 bash -c '
    echo "Setting up 'clink$2' and assigning '172.16.0.$3/16' to it"
    ip link set 'clink$2' up
    ip addr add '172.16.0.$3/16' dev 'clink$2'
    ip link set lo up 
    exit'
}

# Function to set up veth pair inside the root namespace
connect_namespace_to_root() {
    echo "Setting up hlink$1 and assigning 172.16.0.$2/16 to it"
    ip link set hlink$1 up
    ip addr add 172.16.0.$2/16 dev hlink$1
}

test_connectivity() {
    if [ "$1" = "root" ]; then
        echo "Testing connectivity from root namespace to $2 namespace"
        ping -c 2 172.16.0.$3
    else
        echo "Testing connectivity from $1 namespace to $2"
        nsenter --net=/run/netns/$1 ping -c 2 172.16.0.$3
    fi
}

# Function to create bridge and set up connectivity
create_bridge_and_connectivity() {
    echo "Creating the bridge br0"
    rmmod br_netfilter
    ip link add br0 type bridge 
    ip link set br0 up
    ip link set hlink$1 up
    ip link set hlink$2 up
    ip link set hlink$1 master br0
    ip link set hlink$2 master br0
    ip addr add 172.16.0.1/16 dev br0
    nsenter --net=/run/netns/app$1 ip route add default via 172.16.0.1
    nsenter --net=/run/netns/app$2 ip route add default via 172.16.0.1

    echo "Testing connectivity"
    test_connectivity app$1 app$2 40
    test_connectivity app$2 app$1 30
    test_connectivity root app$1 30
    test_connectivity root app$2 40

}
cleanup_namespaces() {
    ip netns delete app$1
}

scenario1() {
    create_namespace_and_veth app1 1
    setup_namespace app1 1 11
    connect_namespace_to_root 1 10
    test_connectivity app1 root 10
    test_connectivity root app1 11
    echo "Cleaning up network namespace app1"
    cleanup_namespaces 1
}

scenario2() {
    create_namespace_and_veth app3 3
    setup_namespace app3 3 30

    create_namespace_and_veth app4 4
    setup_namespace app4 4 40

    create_bridge_and_connectivity 3 4

    echo "Cleaning up network namespace app3 and app4, as well as br0"
    cleanup_namespaces 3
    cleanup_namespaces 4
    ip link delete br0
}

main() {
    scenario1
    scenario2
}

main
