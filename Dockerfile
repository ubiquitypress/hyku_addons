# Base stage for building final images
FROM phusion/passenger-ruby27:2.0.0 as base_image

RUN apt-get update && \
    install_clean --allow-unauthenticated \
      sendmail \
      libxml2-dev \
      libxslt-dev \
      dumb-init \
      default-jre \
      ghostscript \
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

RUN apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a stage for installing just our updated dependencies
FROM base_image as dependencies_image

# Install an updated verion of ImageMagick, older versions have issues with Greyscale PDFs
RUN apt-get update && \
    install_clean libjpeg-dev \
      libjpeg-turbo8-dev \
      libjpeg8-dev \
      libexif-dev \
      libtiff-dev \
      libtiff5-dev \
      libtiffxx5 \
      libpng-dev \
      libltdl-dev && \
    cd /tmp && \
    curl -fsSL -o ImageMagick.tar.gz https://www.imagemagick.org/download/ImageMagick.tar.gz && \
    DIR_NAME=$(tar -tf ImageMagick.tar.gz | head -1 | cut -f1 -d"/") && \
    tar xzvf ImageMagick.tar.gz && \
    cd $DIR_NAME && \
    ./configure --with-rsvg --with-modules && \
    make install && \
    ldconfig /usr/local/lib && \
    cd /home/app

RUN apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# If changes are made to fits version or location, amend `LD_LIBRARY_PATH` in docker-compose.yml accordingly.
RUN mkdir -p /opt/fits && \
    curl -fsSL -o /opt/fits/fits-latest.zip https://projects.iq.harvard.edu/files/fits/files/fits-1.3.0.zip && \
    cd /opt/fits && unzip fits-latest.zip && \
    chmod +X /opt/fits/fits.sh

# Entry point from the docker-compose - last stage as Docker works backwards
FROM dependencies_image as development_image

WORKDIR /home/app

COPY --chown=app:app . /home/app
COPY --chown=app:app lib/hyku_addons/version.rb ./lib/hyku_addons/version.rb
COPY --chown=app:app hyku_addons.gemspec ./hyku_addons.gemspec
COPY --chown=app:app Gemfile ./Gemfile
COPY --chown=app:app Gemfile.lock ./Gemfile.lock
COPY --chown=app:app spec/internal_test_hyku/Gemfile ./spec/internal_test_hyku/Gemfile
COPY --chown=app:app spec/internal_test_hyku/Gemfile.lock ./spec/internal_test_hyku/Gemfile.lock

ENV CFLAGS=-Wno-error=format-overflow

RUN bundle config build.nokogiri --use-system-libraries && \
    bundle config set without "production" && \
    bundle config set with "aws development test postgres" && \
    setuser app bundle install --jobs=4 --retry=3 && \
    chmod 777  -R .bundle/*  # Otherwise `app` owns this file and the host cannot run bundler commands

