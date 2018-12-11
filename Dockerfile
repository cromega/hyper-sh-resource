FROM ruby:2.5-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get -y --no-install-recommends install wget
RUN wget https://hyper-install.s3.amazonaws.com/hyper-linux-x86_64.tar.gz -O- | tar -xzf - -C /usr/local/bin

COPY . /gem/

WORKDIR /gem
RUN bundle install --without=development && \
    gem build hyper_sh_resource.gemspec && \
    gem install --ignore-dependencies *.gem

COPY assets/* /opt/resource/
