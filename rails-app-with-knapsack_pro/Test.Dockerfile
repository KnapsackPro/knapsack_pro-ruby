FROM ruby:3.3.1-alpine3.20

# Prepare Docker image for Nokogiri
RUN apk add --update \
  build-base \
  libxml2-dev \
  libxslt-dev \
  jq \
  nodejs \
  npm \
  postgresql-dev \
  python3-dev \
  sqlite-dev \
  git \
  && rm -rf /var/cache/apk/*

# Use libxml2, libxslt a packages from alpine for building nokogiri
RUN bundle config build.nokogiri --use-system-libraries

# Install Codefresh CLI
RUN wget https://github.com/codefresh-io/cli/releases/download/v0.31.1/codefresh-v0.31.1-alpine-x64.tar.gz
RUN tar -xf codefresh-v0.31.1-alpine-x64.tar.gz -C /usr/local/bin/

COPY . /src

WORKDIR /src

RUN USE_KNAPSACK_PRO_FROM_RUBYGEMS=true bundle install
