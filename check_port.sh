#!/bin/bash

if [[ "${SENTINEL}" == "true" ]]; then
  redis-cli -p 26379 ping
else
  redis-cli -p 6379 ping
fi