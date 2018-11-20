FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y --no-install-recommends wget jq

RUN wget https://hyper-install.s3.amazonaws.com/hyper-linux-x86_64.tar.gz -O- | tar -xzf - -C /usr/local/bin

COPY scripts/* /opt/resource/
