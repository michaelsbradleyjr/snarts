#!/usr/bin/env bash

set -eo pipefail

source extras/examples.sh

for module in ${modules[@]}; do
  echo
  echo nim c "$@" examples/${module}.nim
  if [[ ! ("$@" = *"-d:release"* || "$@" = *"--define:release"*) ]]; then
    echo
  fi
  nim c "$@" examples/${module}.nim
done

echo
if [[ -v MSYSTEM ]]; then
  ls -ladh examples/*.exe
else
  find examples -maxdepth 1 -type f | grep -v '\..*$' | xargs ls -ladh
fi
