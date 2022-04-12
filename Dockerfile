FROM ruby:2.7.2-alpine3.13

COPY . /app
WORKDIR /app

RUN apk add --no-cache --update build-base bash jq curl libffi-dev \
    && bundle config mirror.https://rubygems.org https://gems.ruby-china.com \
    && bundler install --without development test \
    && gem cleanup

EXPOSE 3000

CMD ["bin/rails", "server"]
