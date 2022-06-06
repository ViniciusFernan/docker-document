# pego uma imagem já pronta com o PHP e Apache
FROM php:7.4-apache
USER root

# install the necessary packages
RUN apt-get update -y && apt-get install -y \
    curl \
    nano \
    npm \
    g++ \
    git \
    zip \
    vim \
    sudo \
    unzip \
    nodejs \
    libpq-dev \
    libicu-dev \
    libbz2-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libmcrypt-dev \
    libreadline-dev \
    libfreetype6-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql \
    && docker-php-ext-install mysqli pdo_mysql \
    && docker-php-ext-enable mysqli

RUN docker-php-ext-install \
    zip \
    bz2 \
    intl \
    iconv \
    bcmath \
    opcache \
    calendar


# instala o Composer
RUN apt update && apt install -y zip
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer
RUN composer require google/apiclient:^2.11 \
    && composer clear-cache

RUN chmod 777 -R /var/www/html/ && \
    chown -R www-data:www-data /var/www/ && \
    a2enmod rewrite

# configuração apache
COPY avfconf/vhost.conf /etc/apache2/sites-available/000-default.conf

# install xdebug -configure phpstorn port 9000
RUN pecl install xdebug-2.9.3 && docker-php-ext-enable xdebug
#RUN echo 'zend_extension=xdebug.so' >> $PHP_INI_DIR/php.ini //comentado devido a duplicidade de chamadas
RUN echo 'xdebug.mode=develop,debug' >> $PHP_INI_DIR/php.ini
RUN echo 'xdebug.remote_host=host.docker.internal' >> $PHP_INI_DIR/php.ini
RUN echo 'xdebug.remote_enable=on' >> $PHP_INI_DIR/php.ini
RUN echo 'xdebug.remote_autostart=1' >> $PHP_INI_DIR/php.ini
RUN echo 'xdebug.idekey=PHPSTORM' >> $PHP_INI_DIR/php.ini
RUN echo 'xdebug.show_local_vars=1' >> $PHP_INI_DIR/php.ini
RUN echo 'xdebug.start_with_request=yes' >> $PHP_INI_DIR/php.ini
RUN echo 'session.save_path="/tmp"' >> $PHP_INI_DIR/php.ini

RUN service apache2 restart