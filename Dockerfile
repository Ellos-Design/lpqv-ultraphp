# Pull de origem.
FROM php:7.3-apache

LABEL maintainer="LPQV <contato@lpquevende.com.br>"

COPY . /var/www/html
WORKDIR /var/www/html

# Instala as ferramentas necessárias
RUN apt-get clean && apt-get update && apt-get install --fix-missing wget apt-transport-https lsb-release ca-certificates gnupg2 -y
RUN apt-get clean && apt-get update && apt-get install --fix-missing -y \
    ruby-dev \
    rubygems \
    imagemagick \
    graphviz \
    libwebp-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libmagickwand-dev \
    libxpm-dev \
    libxml2-dev \
    libfreetype6-dev \
    libxslt1-dev \
    sudo \
    zip \
    wget \
    dnsutils \
    linux-libc-dev \
    libyaml-dev \
    libpng-dev \
    zlib1g-dev \
    libzip-dev \
    libicu-dev \
    libpq-dev \
    bash-completion \
    libldap2-dev \
    libssl-dev \
    libonig-dev

# Instala mod-pagespeed
RUN wget https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb -O /tmp/modpagespeed.deb \
    && dpkg -i /tmp/modpagespeed.deb

# instala o mcrypt
RUN pecl install mcrypt-1.0.3 && \
    docker-php-ext-enable mcrypt

# Instala YAML extension
RUN pecl install yaml-2.0.4 && echo "extension=yaml.so" > /usr/local/etc/php/conf.d/ext-yaml.ini

# Instala php e as extensões
RUN docker-php-ext-install opcache pdo_mysql && docker-php-ext-install mysqli
RUN docker-php-ext-configure gd \
    --with-gd \
    --with-webp-dir \
    --with-jpeg-dir \
    --with-png-dir \
    --with-zlib-dir \
    --with-xpm-dir \
    --with-freetype-dir
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-install gd mbstring zip soap pdo_mysql mysqli xsl opcache calendar intl exif pgsql pdo_pgsql ftp bcmath ldap

# Instala Imagick
RUN printf "\n" | pecl install imagick
RUN docker-php-ext-enable imagick

#Baixa php.ini otimizado
RUN cd /tmp \
    wget https://raw.githubusercontent.com/Ellos-Design/lpqv-ultraphp/master/php.config \
    mv php.config /usr/local/etc/php/php.ini

# Apache encore
RUN a2enmod rewrite expires && service apache2 restart

# Abre as portas 80,443 par  apache
EXPOSE 80 443 


