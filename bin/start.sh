#!/bin/bash -x

COMPOSE_VERSION="1.23.2"
COMPOSE_URL="https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)"

install_microkube() {
  sudo -u app bash <<EOS
  cd /home/app
  source /home/app/.rvm/scripts/rvm
  rvm install --quiet-curl 2.6.1
  rvm use --default 2.6.1
  gem install bundler


  cd microkube

  bundle install
  rake render:config
  rake service:cryptonodes && \
  until rake wallet:create['deposit','http://0.0.0.0:8545','changeme']; do sleep 15; done && \
  rake wallet:create['hot','http://0.0.0.0:8545','changeme'] && \
  rake wallet:create['warm','http://0.0.0.0:8545','changeme'] && \
  rake render:config && \
  rake service:all && \
  rake service:daemons && \
  chmod +x bin/install_webhook
  ./bin/install_webhook
EOS
}

install_microkube
