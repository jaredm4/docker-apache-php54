# Apache & PHP 5.4, without MySQL. No Supervisor needed.
#
# To use Mongo driver, add this to your Dockerfile:
# RUN php5enmod mongo
#
# VERSION: 1.9
# DOCKER-VERSION: 0.9.1
# AUTHOR: Jared Markell <jaredm4@gmail.com>
# TO_BUILD: docker build -rm -t jaredm4/apache-php54 .
# TO_RUN: docker run -d -p 80:80 jaredm4/apache-php54
# CHANGELOG:
# 1.8 Upped upload max size to 10M.
# 1.7 prod.ini enhancements
# 1.6 Added php5-cli
# 1.5 Volume'd the /var/log directory entirely.
# 1.4 Cleaned up Dockerfile and created start.sh. No more replacing the entire php.ini.
# 1.3 Added Vim which helps when needing to debug.
# 1.2 Updated Ubuntu from 12.10 to 13.04 to increase Mongo driver to 1.3. PHP increased to 5.4.9.

FROM ubuntu:13.04

MAINTAINER Jared Markell, jaredm4@gmail.com

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV HOME /root

# Utilities and Apache, PHP
RUN echo "deb http://archive.ubuntu.com/ubuntu raring main restricted universe multiverse" > /etc/apt/sources.list &&\
    apt-get update &&\
    apt-get upgrade -y &&\
    DEBIAN_FRONTEND=noninteractive apt-get -y install git subversion curl apache2 php5 php5-cli libapache2-mod-php5 php5-mysql php-apc php5-gd php5-curl php5-memcached php5-mcrypt php5-mongo php5-sqlite &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

# PHP prod config
ADD files/prod.ini /etc/php5/conf.d/prod.ini

# Ensure PHP log file exists and is writable
RUN touch /var/log/php_errors.log && chmod a+w /var/log/php_errors.log

# Our start-up script
ADD files/start.sh /start.sh
RUN chmod a+x /start.sh

# Turn on some crucial apache mods
RUN a2enmod rewrite headers filter

VOLUME ["/var/log"]

ENTRYPOINT ["/start.sh"]
EXPOSE 80
