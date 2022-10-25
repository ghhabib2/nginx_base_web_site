ARG NGINX_VER=1.22.0
FROM nginx:${NGINX_VER}-alpine

RUN sed -i 's/https/http/' /etc/apk/repositories

RUN apk add --update \
       ca-certificates \
    && update-ca-certificates

RUN apk update && \
    apk add vim lynx openssl apache2-utils curl tzdata zip unzip

RUN apk add --no-cache --virtual general-dependencies \
    autoconf \
    automake \
    byacc \
    curl-dev \
    flex \
    g++ \
    gcc \
    geoip-dev \
    git \
    libc-dev \
    libmaxminddb-dev \
    libstdc++ \
    libtool \
    libxml2-dev \
    linux-headers \
    lmdb-dev \
    make \
    openssl-dev \
    pcre-dev \
    yajl-dev \
    zlib-dev \
    busybox-extras \
    bash


RUN cd /opt
RUN mkdir ModSecurity
COPY ./config/ModSecurity /opt/ModSecurity

RUN cd /opt/ModSecurity && \
    chmod +x build.sh && \
    ./build.sh && \
    ./configure --prefix=/ModSec && \
    make && \
    make install 
    
ENV MODSECURITY_INC=/ModSec/include                                                                                                        
ENV MODSECURITY_LIB=/ModSec/lib                                                                                                        

RUN mkdir ModSecurity-nginx
COPY ./config/ModSecurity-nginx ./ModSecurity-nginx
COPY ./config/nginx-${NGINX_VERSION} ./nginx-${NGINX_VERSION}

RUN cd nginx-${NGINX_VERSION} && \
    chmod +x configure && \
    ./configure --with-compat --prefix=/nginx-ModSec --add-dynamic-module=../ModSecurity-nginx && \        
    make && \
    make install && \
    cp /nginx-ModSec/modules/ngx_http_modsecurity_module.so /etc/nginx/modules/ngx_http_modsecurity_module.so && \
    sed -i "3i load_module /etc/nginx/modules/ngx_http_modsecurity_module.so;" /etc/nginx/nginx.conf

COPY ./ssl /usr/ssl
COPY ./config/modsec /etc/nginx/modsec
RUN cp /opt/ModSecurity/unicode.mapping /etc/nginx/modsec/ && rm /var/log/nginx/*

COPY ./config/nginx/conf.d/app.conf /etc/nginx/conf.d/app.conf
COPY ./app_files/ /var/www

ADD ./config/nginx/backup/cron.rule /etc/cron.d/cron.rule
COPY ./config/nginx/backup/backup.sh /home/backup.sh
RUN dos2unix /home/backup.sh && dos2unix /etc/cron.d/cron.rule

RUN crontab /etc/cron.d/cron.rule

CMD crond && nginx -g "daemon off;";
