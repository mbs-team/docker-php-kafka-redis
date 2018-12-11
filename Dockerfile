FROM php:7.2-fpm-alpine
ARG TIMEZONE=UTC
ARG MEMORY_LIMIT='2G'
ARG MAX_EXECUTION='300'
ARG MAX_UPLOAD='128M'

# Set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "%s"\n' '${TIMEZONE}' > /usr/local/etc/php/conf.d/tzone.ini

# Memory limit PHP
RUN printf '[PHP]\nmemory_limit = "%s"\n' '${MEMORY_LIMIT}' > /usr/local/etc/php/conf.d/memory-limit.ini

# Execution time PHP
RUN printf '[PHP]\nmax_execution_time = "%s"\n' '${MAX_EXECUTION}' > /usr/local/etc/php/conf.d/execution_time.ini

# Max Upload
RUN printf '[PHP]\npost_max_size = "%s"\n' '${MAX_UPLOAD}' > /usr/local/etc/php/conf.d/upload.ini
RUN printf 'upload_max_filesize = "%s"\n' '${MAX_UPLOAD}' >> /usr/local/etc/php/conf.d/upload.ini

# Security
RUN printf '[PHP]\nexpose_php = "%s"\n' 'Off' >> /usr/local/etc/php/conf.d/security.ini
RUN printf 'display_errors = "%s"\n' '0' >> /usr/local/etc/php/conf.d/security.ini

# Extension dependencies
RUN apk --no-cache add \
	libffi-dev \
        postgresql-dev \
        zlib-dev \
        icu-dev \
        librdkafka-dev

# PHP extensions
RUN docker-php-ext-install pdo pdo_pgsql zip intl hash opcache bcmath pcntl sockets

# PHP PECL extensions
RUN docker-php-source extract \
    && apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && pecl install apcu \
    && docker-php-ext-enable apcu  \
    && pecl install rdkafka \
    && docker-php-ext-enable rdkafka \
    && apk del .phpize-deps-configure \
    && docker-php-source delete
