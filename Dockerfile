# Cockpit
# Forked from Ryan Seto <ryanseto@yak.net>
# http://wiki.nginx.org/
# http://us.php.net/

FROM ubuntu:trusty
MAINTAINER Mark Steve Samson <hello@marksteve.com>

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get update

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

# Install packages
RUN apt-get -y install apt-utils
RUN apt-get -y install nginx
RUN apt-get -y install php5-fpm
RUN apt-get -y install php5-mysql
RUN apt-get -y install php-apc
RUN apt-get -y install php5-imagick
RUN apt-get -y install php5-imap
RUN apt-get -y install php5-mcrypt
RUN apt-get -y install php5-gd
RUN apt-get -y install libssh2-php
RUN apt-get -y install php5-cli
RUN apt-get -y install php5-sqlite

# Install composer
RUN apt-get -y install git
RUN php -r "readfile('https://getcomposer.org/installer');" | php
RUN mv composer.phar /usr/local/bin/composer

# Install cockpit
RUN composer create-project aheinze/cockpit cockpit --stability="dev"

# Setup nginx
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
ADD nginx.conf /etc/nginx/nginx.conf
# ADD https://raw.github.com/h5bp/server-configs-nginx/master/h5bp/location/expires.conf /etc/nginx/conf/expires.conf
# ADD https://raw.github.com/h5bp/server-configs-nginx/master/h5bp/directive-only/x-ua-compatible.conf /etc/nginx/conf/x-ua-compatible.conf
# ADD https://raw.github.com/h5bp/server-configs-nginx/master/h5bp/location/cross-domain-fonts.conf /etc/nginx/conf/cross-domain-fonts.conf
# ADD https://raw.github.com/h5bp/server-configs-nginx/master/h5bp/location/protect-system-files.conf /etc/nginx/conf/protect-system-files.conf
ADD nginx-site.conf /etc/nginx/sites-available/default
# RUN sed -i -e '/access_log/d' /etc/nginx/conf/expires.conf
RUN sed -i -e 's/^listen =.*/listen = \/var\/run\/php5-fpm.sock/' /etc/php5/fpm/pool.d/www.conf

# Decouple our data from our container.
VOLUME ["/data"]

EXPOSE 80
ADD start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
