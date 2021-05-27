#!/bin/sh
set -e

sh -c "sudo chown -R root /github"
sh -c "sudo chmod -R 777 /github"
sh -c "sudo chown -R root /__w"
sh -c "sudo chmod -R 777 /__w"

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi

exec "$@"
