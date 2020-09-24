#!/bin/bash

declare -a nodes=("172.19.197.2" "172.19.197.3" "172.19.197.4" "172.19.197.5" "172.19.197.6" "172.19.197.7")
nodesToRegister=""
# force all the nodes to be available
for node in "${nodes[@]}"
do
   redis-cli -h $node ping
   nodesToRegister="$nodesToRegister $node:6379"
done

registeredNodeIPs=( $( redis-cli -h ${nodes[0]} CLUSTER NODES | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' ) )

if [[ ${#registeredNodeIPs[@]} == 0 ]];
then
    echo "⚠️ None of the nodes are joined to the cluster, init the cluster 🚀"
    echo "yes" | redis-cli --cluster create $nodesToRegister --cluster-replicas 1
else
    echo "registeredNodeIPs:"
    for registeredNode in "${registeredNodeIPs[@]}"
    do
        echo "💻 $registeredNode"
    done

    if [[ ${#registeredNodeIPs[@]} == ${#nodes[@]} ]];
    then
        echo "✅ All nodes are joined. Nothing else to do, exiting now 👋"
    else
        # diff the nodes
        # this can be done more efficiently by hash set, didn't bother
        UnregisteredNodes=()
        for i in "${nodes[@]}"; do
            skip=
            for j in "${registeredNodeIPs[@]}"; do
                [[ $i == $j ]] && { skip=1; break; }
            done
            [[ -n $skip ]] || UnregisteredNodes+=("$i")
        done
        declare -p UnregisteredNodes > /dev/null

        echo "⚠️ Below nodes are not joined to the cluster:"
        for unregisteredNode in "${UnregisteredNodes[@]}"
        do
            echo "💻 $unregisteredNode"
        done

        for unregisteredNode in "${UnregisteredNodes[@]}"
        do
            # the address of the new node as first argument, and the address of a random existing node in the cluster as second argument.
            echo "⚠️ Adding '$unregisteredNode' node to the cluster:"
            redis-cli --cluster add-node "$unregisteredNode:6379" "${nodes[0]}:6379"
        done
    fi
fi
