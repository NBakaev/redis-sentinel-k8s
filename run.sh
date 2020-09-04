#!/bin/bash

# Redis sentinel network topology based on /data/sentinel.conf which is created at first run.
# Settings that configuration makes sense only at first run

set -e


FIRST_RUN=false

if [ ! -f /data/redis.conf ]; then
    FIRST_RUN=true
fi

K8S_FIRST_NODE_NAME=${POD_NAME%?}0

if [[ "${FIRST_RUN}" == "true" ]]; then
  announceAddr=${NODE_IP}
  echo "announce addr: ${announceAddr}"

  if [[ "${POD_NAME}" != $K8S_FIRST_NODE_NAME ]]; then
    masterIp=`redis-cli -h $K8S_FIRST_NODE_NAME -p 26379 --raw sentinel master mycluster | grep -A1 "ip" | grep -v "ip"`
    echo "master $masterIp"
   else
    echo "i am master $masterIp"
    masterIp=${NODE_IP}
  fi
fi

echo "master ip: ${masterIp}, FIRST_RUN=${FIRST_RUN}"

if [[ "${SENTINEL}" == "true" ]]; then
  if [[ "${FIRST_RUN}" == "true" ]]; then
    echo "Sentinel announce addr: ${announceAddr}:${announcePort}"

    echo -e "protected-mode no \n" > /data/sentinel.conf
    echo -e "sentinel monitor mycluster ${masterIp} ${REDIS_PUBLISHED_PORT} 2 \n" >> /data/sentinel.conf
    echo -e "sentinel down-after-milliseconds mycluster 10000 \n" >> /data/sentinel.conf
    echo -e "sentinel parallel-syncs mycluster 1 \n" >> /data/sentinel.conf
    echo -e "sentinel announce-ip ${announceAddr} \n" >> /data/sentinel.conf
    echo -e "sentinel announce-port ${SENTINEL_PUBLISHED_PORT} \n" >> /data/sentinel.conf
  fi

  exec docker-entrypoint.sh redis-server /data/sentinel.conf --sentinel "$@"
else
  if [[ "${FIRST_RUN}" == "true" ]]; then
    if [[ "${POD_NAME}" != $K8S_FIRST_NODE_NAME ]]; then
      replicaOf="replicaof ${masterIp} ${REDIS_PUBLISHED_PORT}"
    fi

    echo -e "protected-mode no \n" > /data/redis.conf
    echo -e "appendonly yes \n" >> /data/redis.conf
    echo -e "min-slaves-to-write 1 \n" >> /data/redis.conf
    echo -e "min-slaves-max-lag 10 \n" >> /data/redis.conf
    echo -e "replica-serve-stale-data no \n" >> /data/redis.conf
    echo -e "repl-backlog-size 100mb \n" >> /data/redis.conf
    echo -e "replica-announce-ip ${announceAddr} \n" >> /data/redis.conf
    echo -e "replica-announce-port ${REDIS_PUBLISHED_PORT} \n" >> /data/redis.conf
    echo -e "${replicaOf} \n" >> /data/redis.conf
  fi

  exec docker-entrypoint.sh redis-server /data/redis.conf "$@"
fi