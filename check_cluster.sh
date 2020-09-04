#!/bin/bash

set +e

while true; do
  sleep 3

  echo "Trying connect to sentinel..."
  slaves=$(redis-cli -h ${SENTINEL_HOST} -p 26379 --raw sentinel masters | grep -A1 "num-slaves" | grep -v "num-slaves")

  status=$?

  if [[ "${status}" != "0" ]]; then
    echo "sentinel is not ready"
    continue
  fi

  echo "Trying connect to sentinel..."
  sentinels=$(redis-cli -h ${SENTINEL_HOST} -p 26379 --raw sentinel masters | grep -A1 "num-other-sentinels" | grep -v "num-other-sentinels")

  status=$?

  if [[ "${status}" != "0" ]]; then
    echo "sentinel is not ready"
    continue
  fi

  echo "slaves count: ${slaves}, expected: ${EXPECTED_SLAVES}"
  echo "sentinels count: $((${sentinels}+1)), expected: ${EXPECTED_SENTINELS}"

  if redis-cli -h ${SENTINEL_HOST} -p 26379 sentinel ckquorum mycluster | grep -q ${EXPECTED_SENTINELS} ; then
    echo "Sentinel quorum check success"
  else
    echo "Sentinel quorum check failed, not enough sentinels found"
    continue
  fi

  if [[ "${slaves}" == "${EXPECTED_SLAVES}" && "$((${sentinels}+1))" == "${EXPECTED_SENTINELS}" ]]; then
    echo "Cluster is ready"
    exit 0
  fi
done