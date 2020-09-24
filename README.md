# Redis Cluster

This repo has various resources on redis cluster. If you are like me, and wants to cut BS as much as possible, please head to the official redis-cluster spec, and tutorial:

 - [Redis Cluster Specification](https://redis.io/topics/cluster-spec) (requires 🍷)
 - [Redis Cluster Tutorial](https://redis.io/topics/cluster-tutorial) (requires 💻)

## Running Redis Cluster

You can run a Redis cluster locally with the help of Docker, which will help you create a deterministic environment. This repo comes with a pre-built setup to do just that, just run the following command to get up and running:

```bash
docker-compose up
```

### How Initializer Works

The initializer logic you can see under `./initializer` folder in this repository wires up the redis node together. It has the hardcoded list of
Redis node IP addresses. It:

 - makes sure all of them are up first by pinging. It keeps going till we have all nodes up
 - makes a `CLUSTER NODES` call to first node to get the IP addresses of all the configured nodes
 - takes the diff between our list of IP addresses and `CLUSTER NODES` output
 - adds the missing nodes to the cluster

### Connecting to the Redis Cluster with redis-cli

The `redis-cli` utility implements basic cluster support when started with the -c switch (e.g. performing )

```bash
docker run -it --rm \
    --net redis-cluster_redis_cluster_network \
    redis \
    redis-cli -c -h redis_1
```

#### Inspecting the Cluster

Redis provides bunch of subcommands that you can use with the `CLUSTER` command. As of `v5.0.3`, the list of those commands are as following:

```
redis_1:6379> CLUSTER HELP
 1) CLUSTER <subcommand> arg arg ... arg. Subcommands are:
 2) ADDSLOTS <slot> [slot ...] -- Assign slots to current node.
 3) BUMPEPOCH -- Advance the cluster config epoch.
 4) COUNT-failure-reports <node-id> -- Return number of failure reports for <node-id>.
 5) COUNTKEYSINSLOT <slot> - Return the number of keys in <slot>.
 6) DELSLOTS <slot> [slot ...] -- Delete slots information from current node.
 7) FAILOVER [force|takeover] -- Promote current replica node to being a master.
 8) FORGET <node-id> -- Remove a node from the cluster.
 9) GETKEYSINSLOT <slot> <count> -- Return key names stored by current node in a slot.
10) FLUSHSLOTS -- Delete current node own slots information.
11) INFO - Return onformation about the cluster.
12) KEYSLOT <key> -- Return the hash slot for <key>.
13) MEET <ip> <port> [bus-port] -- Connect nodes into a working cluster.
14) MYID -- Return the node id.
15) NODES -- Return cluster configuration seen by node. Output format:
16)     <id> <ip:port> <flags> <master> <pings> <pongs> <epoch> <link> <slot> ... <slot>
17) REPLICATE <node-id> -- Configure current node as replica to <node-id>.
18) RESET [hard|soft] -- Reset current node (default: soft).
19) SET-config-epoch <epoch> - Set config epoch of current node.
20) SETSLOT <slot> (importing|migrating|stable|node <node-id>) -- Set slot state.
21) REPLICAS <node-id> -- Return <node-id> replicas.
22) SLOTS -- Return information about slots range mappings. Each range is made of:
23)     start, end, master and replicas IP addresses, ports and ids
```

Let's check out one of the rudimentary ones: [`CLUSTER NODES`](https://redis.io/commands/cluster-nodes), which provides information about the nodes in our cluster (e.g. the current cluster configuration, given by the set of known nodes, the state of the connection we have with such nodes, their flags, properties and assigned slots, etc.):

```
redis_1:6379> cluster nodes
272613857b2ceb1d30c5f48c4c25836fb6350558 172.19.197.7:6379@16379 slave fe7614ba29ebca31b6a3d516db0095d17874f98c 0 1600976918106 6 connected
8e6d45810bef8253ed4ba4736a43f18756f0b559 172.19.197.2:6379@16379 myself,master - 0 1600976917000 1 connected 0-5460
fe7614ba29ebca31b6a3d516db0095d17874f98c 172.19.197.4:6379@16379 master - 0 1600976918512 3 connected 10923-16383
3959fb1b8ca1d5ef71ee12b01329d8aa14785ade 172.19.197.6:6379@16379 slave f21e37724ea99d411e7ae003f4f866f7257265aa 0 1600976918816 5 connected
a41e5b33bb6c05a7977010e8b07aab1d7f67b836 172.19.197.5:6379@16379 slave 8e6d45810bef8253ed4ba4736a43f18756f0b559 0 1600976918000 4 connected
f21e37724ea99d411e7ae003f4f866f7257265aa 172.19.197.3:6379@16379 master - 0 1600976917000 2 connected 5461-10922
```
