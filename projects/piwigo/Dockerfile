FROM php:8.5.12-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpng-dev libjpeg62-turbo-dev libfreetype-dev libwebp-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j2 gd exif mysqli \
    && apt-get purge -y --auto-remove libpng-dev libjpeg62-turbo-dev libfreetype-dev libwebp-dev \
    && apt-get install -y --no-install-recommends libpng16-16t64 libjpeg62-turbo libfreetype6 libwebp7 libsharpyuv0 \
    && rm -rf /var/lib/apt/lists/* \
    && a2enmod rewrite remoteip

COPY php.ini /usr/local/etc/php/conf.d/piwigo.ini
COPY remoteip.conf /etc/apache2/conf-enabled/remoteip.conf
