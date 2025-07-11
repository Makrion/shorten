# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for development. Use with:
# docker build -t shorten .
# docker run -d -p 3000:3000 --name shorten shorten

# For production deployment, see the production Dockerfile or use Kamal

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.4
FROM docker.io/library/ruby:$RUBY_VERSION-slim

# Rails app lives here
WORKDIR /rails

# Install packages needed for development
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    libjemalloc2 \
    libvips \
    libyaml-dev \
    pkg-config \
    sqlite3 \
    default-mysql-client \
    libmariadb3 \
    default-libmysqlclient-dev \
    vim \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set development environment
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle" \
    BASE_URL="https://shorten.com"

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Create directories that Rails expects
RUN mkdir -p tmp/pids log storage

# Expose port 3000 (default Rails development port)
EXPOSE 3000

# Start the Rails server
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
