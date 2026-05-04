#!/usr/bin/env bash
# エラーが発生したら即座に終了する
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate