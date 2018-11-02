#! /usr/bin/env bash

set -e -x -u

pushd hoe-debugging

  apt-get update
  apt-get install -y valgrind
  gem install bundler # get the latest!
  bundle install
  bundle exec rake spec

popd
