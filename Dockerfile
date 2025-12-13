# https://hub.docker.com/_/ruby
FROM ruby:3.4.7

# Install build essential tools (necessary for some gems)
USER root
RUN apt-get update -qq && apt-get install -y build-essential

WORKDIR /app

# Create a non-root user
RUN addgroup --gid 1000 app && \
    adduser --uid 1000 --gid 1000 --shell /bin/sh --disabled-password app
USER app

COPY --chown=app:app Gemfile Gemfile.lock ./

RUN bundle install

COPY --chown=app:app . .

RUN chmod +x bin/docker-entrypoint

ENTRYPOINT ["./bin/docker-entrypoint"]

EXPOSE 3000

CMD ["./bin/rails", "server", "-b", "0.0.0.0"]