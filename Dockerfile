# Ripped off from Avalon
# Base stage for building gems
FROM        ruby:2.7.2-buster as bundle
RUN         echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list \
         && apt-get update \
         && rm -rf /var/lib/apt/lists/* \
         && apt-get clean

COPY        lib/hyku_addons/version.rb ./lib/hyku_addons/version.rb
COPY        hyku_addons.gemspec ./hyku_addons.gemspec
COPY        Gemfile ./Gemfile
COPY        Gemfile.lock ./Gemfile.lock
COPY        spec/internal_test_hyku/Gemfile ./spec/internal_test_hyku/Gemfile
COPY        spec/internal_test_hyku/Gemfile.lock ./spec/internal_test_hyku/Gemfile.lock

RUN         gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)" \
         && bundle config build.nokogiri --use-system-libraries


# Build development gems
FROM        bundle as bundle-dev
RUN         bundle config set without 'production'
RUN         bundle config set with 'aws development test postgres'
ENV         CFLAGS=-Wno-error=format-overflow
RUN         bundle install


# Base stage for building final images
FROM        ruby:2.7.1-slim-buster as base

RUN         apt-get update && apt-get install -y --no-install-recommends curl gnupg2 \
         && curl -sL http://deb.nodesource.com/setup_8.x | bash -
RUN         apt-get update && apt-get install -y --no-install-recommends --allow-unauthenticated \
            nodejs \
            sendmail \
            git \
            libxml2-dev \
            libxslt-dev \
            openssh-client \
            zip \
            dumb-init \
            default-jre \
            # Below copied from hyku's Dockerfile
            build-essential \
            ghostscript \
            imagemagick \
            libpq-dev \
            libreoffice \
            libsasl2-dev \
            netcat \
            postgresql-client \
            rsync \
            tzdata \
            unzip \
            && \
            apt-get clean && \
            rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# If changes are made to fits version or location,
# amend `LD_LIBRARY_PATH` in docker-compose.yml accordingly.
RUN mkdir -p /opt/fits && \
    curl -fSL -o /opt/fits/fits-latest.zip https://projects.iq.harvard.edu/files/fits/files/fits-1.3.0.zip && \
    cd /opt/fits && unzip fits-latest.zip && chmod +X /opt/fits/fits.sh

RUN         useradd -m -U app \
         && su -s /bin/bash -c "mkdir -p /home/app" app
WORKDIR     /home/app

# Build devevelopment image
FROM        base as dev

COPY        --from=bundle-dev /usr/local/bundle /usr/local/bundle

ARG         RAILS_ENV=development
RUN         dpkg -i /chrome.deb || apt-get install -yf


# Build production gems
FROM        bundle as bundle-prod
RUN         bundle install --without development test --with aws production postgres


# Build production assets
FROM        base as assets
COPY        --from=bundle-prod --chown=app:app /usr/local/bundle /usr/local/bundle
COPY        --chown=app:app . .

USER        app
ENV         RAILS_ENV=production

RUN         SECRET_KEY_BASE=$(ruby -r 'securerandom' -e 'puts SecureRandom.hex(64)') bundle exec rake assets:precompile


# Build production image
FROM        base as prod
COPY        --from=assets --chown=app:app /home/app /home/app
COPY        --from=bundle-prod --chown=app:app /usr/local/bundle /usr/local/bundle

USER        app
ENV         RAILS_ENV=production
