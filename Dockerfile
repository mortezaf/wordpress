FROM alpine:3.19

ARG ALPINE_VERSION=3.19

LABEL Maintainer="Morteza Fathi <mortezaa.fathi@gmail.com>" \
    Description="Lightweight wordspress container with www 1.24 & PHP-FPM 8.2 based on Alpine Linux."

RUN echo https://mirrors.pardisco.co/alpine/v$ALPINE_VERSION/main > /etc/apk/repositories
RUN echo https://mirrors.pardisco.co/alpine/v$ALPINE_VERSION/community >> /etc/apk/repositories

# Install packages and remove default server definition
RUN apk add --no-cache php83 \
    php83-curl\
    php83-dom\
    php83-exif\
    php83-fileinfo\
    php83-json\
    php83-mbstring\
    php83-mysqli\
    php83-sodium\
    php83-openssl\
    php83-xml\
    php83-zip\
    php83-gd\
    php83-iconv\
    php83-simplexml\
    php83-xmlreader\
    php83-fpm\
    php83-zlib

RUN apk add --no-cache nginx\
    supervisor \
    curl \
    tzdata\
    nano \
    htop\
    supercronic \
    redis

RUN ln -s /usr/bin/php83 /usr/bin/php

# Configure nginx
COPY .docker/config/nginx.conf /etc/www/nginx.conf

# Configure PHP-FPM
COPY .docker/config/fpm.conf /etc/php83/php-fpm.d/www.conf

# Configure PHP
COPY .docker/config/php.ini /etc/php83/conf.d/custom.ini

# Configure supervisord
COPY .docker/config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nginx:nginx /run && \
    chown -R nginx:nginx /var/lib/nginx && \
    chown -R nginx:nginx /var/log/nginx

# Switch to use a non-root user from here on
USER nginx

WORKDIR /var/www/wordpress

COPY ./wordpress /var/www/wordpress
RUN chown nginx:nginx /var/www/wordpress
RUN chmod 755 /var/www/wordpress

# Expose the port www is reachable on
EXPOSE 8080

# ENTRYPOINT
CMD ["/usr/bin/supervisord" , "-c" , "/etc/supervisor/conf.d/supervisord.conf"]
