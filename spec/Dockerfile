FROM ruby:2.5-slim

COPY Gemfile /
COPY *.gemspec /

RUN ln -s /bin/true /usr/local/bin/hyper

RUN bundle install
