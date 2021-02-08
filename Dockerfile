FROM ruby:3.0.0-buster

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install --assume-yes percona-toolkit \
    && apt-get autoremove && apt-get autoclean && apt-get clean

RUN curl -LO https://github.com/skeema/skeema/releases/download/v1.4.7/skeema_1.4.7_linux_amd64.tar.gz \
  && tar -xzvf skeema_1.4.7_linux_amd64.tar.gz skeema \
  && mv skeema /usr/local/bin/

WORKDIR /srv/app
COPY . /srv/app
RUN bundle install -j 4
