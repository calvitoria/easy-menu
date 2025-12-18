FROM ruby:3.4.7

USER root

RUN apt-get update -qq && \
    apt-get install -y \
      build-essential \
      curl \
      nodejs \
      npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json package-lock.json ./
RUN npm install

RUN gem install foreman

RUN addgroup --gid 1000 app && \
    adduser --uid 1000 --gid 1000 --shell /bin/sh --disabled-password app

USER app

COPY --chown=app:app . .

EXPOSE 3000

ENTRYPOINT ["./bin/docker-entrypoint"]
CMD ["./bin/dev"]
