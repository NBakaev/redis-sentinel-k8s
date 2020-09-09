# Redis sentinel for k8s

Helm 3 charts for Redis Sentinel and kubernetes.

The main goal is to run redis sentinel with the ability to connect from **outside** the kubernetes cluster

Other sentinel charts do not support that (e.g. issue for bitnami https://github.com/bitnami/charts/issues/3524)

Internally it uses node IPs (not k8s network) for communication between redis nodes and sentinel

## Deploy

```bash
export NAMESPACE=test-namespace
export RELEASE_NAME=release

helm upgrade -i --namespace ${NAMESPACE} \
 --set "redis.redisHostPort=36379" \
 --set "redis.sentinelHostPort=26379" \
 --atomic \
 --debug \
 --wait \
 $RELEASE_NAME \
 ./redis-ha
```

in that example, redis will use port 36379 and sentinel will use port 26379 (hostPort in k8s)

### Check

You can check that sentinel will return external IP of node e.g. execute inside container

```bash
redis-cli -h 127.0.0.1 -p 26379 --raw sentinel master mycluster | grep -A1 "ip" | grep -v "ip"
```

will return ip like that 192.168.10.45

## Node configuration

It's recommended to follow redis recommendations for the best performance

```bash
sysctl -w vm.overcommit_memory=1
sysctl -w net.core.somaxconn=1024
echo -n "never" > /tph/enabled
```

## Limitations

Because it uses hostPort, you should control on which nodes redis can be scheduled (to avoid changes in node external address). 
The best way is to use LocalVolume 