FROM ruby:2.3

ENV APP_HOME /opt/letsencrypt-heroku
RUN mkdir /opt/letsencrypt-heroku
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

RUN bundle install
