#!/usr/bin/env bash

set -eo pipefail

declare -a modules=(
  snart1
)

for module in ${modules[@]}; do
  echo nim c "$@" examples/${module}.nim
  nim c "$@" examples/${module}.nim
  echo
done

if [[ -v MSYSTEM ]]; then
  ls -ladh examples/*.exe
else
  find examples -maxdepth 1 -type f | grep -v '\..*$' | xargs ls -ladh
fi
