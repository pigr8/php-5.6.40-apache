FROM php:5.6.40-apache
LABEL maintainer="Azure App Services Container Images <appsvc-images@microsoft.com>"

COPY apache2.conf /etc/apache2/
COPY init_container.sh /bin/
RUN chmod +x /bin/init_container.sh

RUN a2enmod rewrite expires include deflate

# install the PHP extensions we need
RUN apt-get update \ 
    && apt-get install -y --no-install-recommends \
        libpng-dev \
        libjpeg-dev \
        libmcrypt-dev \
        nano \
        curl \
        wget \
    && chmod 755 /bin/init_container.sh \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd \
        mysqli \
        opcache \
        mcrypt \
        zip \
        exif
		
RUN { \
                echo 'opcache.memory_consumption=128'; \
                echo 'opcache.interned_strings_buffer=8'; \
                echo 'opcache.max_accelerated_files=4000'; \
                echo 'opcache.revalidate_freq=60'; \
                echo 'opcache.fast_shutdown=1'; \
                echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
                echo 'error_log=/var/log/apache2/php-error.log'; \
                echo 'display_errors=Off'; \
                echo 'log_errors=On'; \
                echo 'display_startup_errors=Off'; \
                echo 'date.timezone=UTC'; \
    } > /usr/local/etc/php/conf.d/php.ini

ENV PORT 80
EXPOSE 80

ENV APACHE_RUN_USER www-data

# setup default site
RUN mkdir -p /opt/startup
COPY generateStartupCommand.sh /opt/startup/generateStartupCommand.sh
RUN chmod 755 /opt/startup/generateStartupCommand.sh

WORKDIR /var/www/html

ENTRYPOINT ["/bin/init_container.sh"]
