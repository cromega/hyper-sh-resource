#!/bin/bash -e

cd code
bundle install
bundle exec rspec
