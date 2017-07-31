FROM ruby:2.3.1

ENV APP_HOME /home/web
ENV RAILS_ENV development
ENV BUNDLE_APP_CONFIG $APP_HOME/.bundle

RUN groupadd -r web --gid=1000 \
    && useradd -r -m -g web -d $APP_HOME --uid=1000 web

RUN wget https://deb.nodesource.com/setup_6.x -O - | bash

RUN apt-get update && apt-get install -y mysql-client libmysqlclient-dev nodejs gcc cmake

RUN gem install bundler
RUN npm install -g yarn

WORKDIR $APP_HOME

COPY Gemfile $APP_HOME/Gemfile
COPY Gemfile.lock $APP_HOME/Gemfile.lock

RUN chown web:web Gemfile Gemfile.lock

USER web
RUN bundle install --path vendor/bundle

COPY tmp/bc.tar.gz $SITE_DIR
RUN tar xf bc.tar.gz .

RUN bin/rake tmp:create
RUN yarn install --modules-folder=vendor/assets/components

EXPOSE 8080

CMD ["sh", "config/deploy/start.sh"]
