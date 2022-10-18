FROM php:7.4.7-fpm-alpine

WORKDIR /var/www

RUN apk update && \
    apk add --no-cache build-base vim lynx tzdata libxml2-dev

RUN docker-php-ext-install mysqli pdo_mysql soap


RUN echo 'pm.max_children = 15' >> /usr/local/etc/php-fpm.d/zz-docker.conf && \
    echo 'pm.max_requests = 500' >> /usr/local/etc/php-fpm.d/zz-docker.conf

COPY ./app_files /var/www

# Add new user
RUN adduser --disabled-password --no-create-home englosdet_web_user &&\
    chown -R englosdet_web_user:englosdet_web_user /var/www &&\
    chmod -R 775 /var/www/ &&\
    chmod -R 775 /var/www/wp-content
USER englosdet_web_user

EXPOSE 9000
