#!/usr/bin/env bash
# エラーが発生したら即座に終了する
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
bundle exec rails runner "Admin.find_or_create_by!(email: 'admin@example.com') { |a| a.password = 'password'; a.password_confirmation = 'password'; a.display_name = '管理者ユーザー' }"