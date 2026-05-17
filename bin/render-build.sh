#!/usr/bin/env bash
# エラーが発生したら即座に終了する
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
bundle exec rails runner "Admin.find_or_create_by!(email: ENV.fetch('ADMIN_EMAIL', 'admin@example.com')) { |a| a.password = ENV.fetch('ADMIN_PASSWORD', 'password'); a.password_confirmation = ENV.fetch('ADMIN_PASSWORD', 'password'); a.display_name = '管理者ユーザー' }.update!(role: :owner)"
bundle exec rails runner "Admin.find_or_create_by!(email: 'reviewer@smart-entry-lot.com') { |a| a.password = 'password'; a.password_confirmation = 'password'; a.display_name = '検証用管理者ユーザー' }.update!(role: :store)"