FROM phusion/passenger-ruby27:2.0.0 as bundle

COPY lib/hyku_addons/version.rb ./lib/hyku_addons/version.rb
COPY hyku_addons.gemspec ./hyku_addons.gemspec
COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
COPY spec/internal_test_hyku/Gemfile ./spec/internal_test_hyku/Gemfile
COPY spec/internal_test_hyku/Gemfile.lock ./spec/internal_test_hyku/Gemfile.lock

RUN bundle config build.nokogiri --use-system-libraries


# Build development gems
FROM        bundle as bundle-dev

RUN         bundle config set without 'production'
RUN         bundle config set with 'aws development test postgres'
ENV         CFLAGS=-Wno-error=format-overflow
RUN         bundle install --jobs=4 --retry=3


# Base stage for building final images
FROM phusion/passenger-ruby27:2.0.0 as base

RUN install_clean --allow-unauthenticated \
	sendmail \
	libxml2-dev \
	libxslt-dev \
	dumb-init \
	default-jre \
	ghostscript \
	imagemagick \
	libpq-dev \
	libreoffice \
	libsasl2-dev \
	netcat \
	postgresql-client \
	rsync \
	zip \
	unzip \
	gnupg2 \
	ffmpeg \
	vim

RUN apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# If changes are made to fits version or location, amend `LD_LIBRARY_PATH` in docker-compose.yml accordingly.
RUN mkdir -p /opt/fits && \
    curl -fSL -o /opt/fits/fits-latest.zip https://projects.iq.harvard.edu/files/fits/files/fits-1.3.0.zip && \
    cd /opt/fits && unzip fits-latest.zip && chmod +X /opt/fits/fits.sh

WORKDIR /home/app

# Entry point from the docker-compose - build devevelopment image
FROM        base as dev

COPY        --from=bundle-dev /usr/local/bundle /usr/local/bundle
ARG         RAILS_ENV=development

