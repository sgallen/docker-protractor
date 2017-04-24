FROM debian:jessie

RUN apt-get update && \
  apt-get install -y \
    curl \
    gnupg \
    apt-transport-https \
    ca-certificates && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  curl --fail -ssL -o setup-nodejs https://deb.nodesource.com/setup_7.x && \
  bash setup-nodejs

# ffmpeg is hosted at deb-multimedia.org
# RUN curl http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb \
#   -o /tmp/deb-multimedia-keyring.deb && \
#   dpkg -i /tmp/deb-multimedia-keyring.deb && \
#   rm /tmp/deb-multimedia-keyring.deb && \
#   echo "deb http://www.deb-multimedia.org stretch main non-free" >> /etc/apt/sources.list

# Install jre-8
RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list.d/bp.list && \
  apt-get update && \
  apt-get -t jessie-backports install -y openjdk-8-jre

RUN apt-get update && \
  apt-get install -y \
    build-essential \
    nodejs \
    xvfb \
    libgconf-2-4 \
    libexif12 \
    chromium \
    supervisor \
    netcat-traditional && \
    # ffmpeg && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install Protractor
RUN npm install -g protractor jasmine-reporters protractor-jasmine2-screenshot-reporter

# Install Selenium and Chrome driver
RUN webdriver-manager update

# Add a non-privileged user for running Protrator
RUN adduser --home /project --uid 1100 \
  --disabled-login --disabled-password --gecos node node

# Add main configuration file
ADD supervisor.conf /etc/supervisor/supervisor.conf

# Add service defintions for Xvfb, Selenium and Protractor runner
ADD supervisord/*.conf /etc/supervisor/conf.d/

# By default, tests in /data directory will be executed once and then the container
# will quit. When MANUAL envorinment variable is set when starting the container,
# tests will NOT be executed and Xvfb and Selenium will keep running.
ADD bin/run-protractor /usr/local/bin/run-protractor

# Container's entry point, executing supervisord in the foreground
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisor.conf"]

# Protractor test project needs to be mounted at /project
VOLUME ["/project"]
