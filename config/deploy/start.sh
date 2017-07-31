#!/bin/sh

set -xe

export RAILS_ENV=development

# wait for services
until mysqladmin -uroot -p$MYSQL_ROOT_PASSWORD -h$DB_HOST ping; do sleep 1; done

echo 'Setting up db...'
bundle exec rake db:create db:migrate

echo 'Precompiling assets...'
bundle exec rake assets:precompile

echo 'Starting server...'
bundle exec rails server -p 8080 -b 0.0.0.0
