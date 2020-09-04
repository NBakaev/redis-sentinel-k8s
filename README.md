# Redis sentinel for k8s

Helm 3 charts for Redis Sentinel and kubernetes.

The main goal is to run redis sentinel with the ability to connect **outside** the kubernetes cluster
Other sentinel charts does not support that (e.g. issue for bitnami https://github.com/bitnami/charts/issues/3524)

Internally it uses nodes IPs (not k8s network) for redis communication

## Node configuration

It's recommended to follow redis recommendation for the best performance

```bash
sysctl -w vm.overcommit_memory=1
sysctl -w net.core.somaxconn=1024
echo -n "never" > /tph/enabled
```