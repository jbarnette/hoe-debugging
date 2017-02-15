#! /usr/bin/env bash

set -e -x -u

pushd hoe-debugging

  apt-get update
  apt-get install -y valgrind
  bundle install
  bundle exec rake spec

popd
