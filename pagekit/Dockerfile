FROM php:7-fpm
MAINTAINER Alexander Herrmann <darignac@gmail.com>
ENV PAGEKIT_VERSION=1.0.10
RUN apt-get update \
    && apt-get -y install \
    unzip \
    wget \
    zlib1g-dev \
#    ca-certificates \
#    php7.0 \
#    php7.0-fpm \
#    php7.0-cli \
#    php7.0-json \
#    php7.0-mysql \
#    php7.0-curl \
#    php7.0-simplexml \
#    php7.0-dom \
#    php7.0-mbstring \
#    php7.0-zip \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install zip pdo_mysql \
    && docker-php-source delete \
    && mkdir -p /pagekit
WORKDIR /pagekit
RUN wget https://github.com/pagekit/pagekit/releases/download/${PAGEKIT_VERSION}/pagekit-${PAGEKIT_VERSION}.zip -O /pagekit/pagekit.zip \
    && unzip /pagekit/pagekit.zip \
    && rm /pagekit/pagekit.zip \
    && chown www-data:www-data -R /pagekit \
    && chmod g+w -R /pagekit
    && chmod +x /pagekit/pagekit
VOLUME ["/pagekit", "/pagekit/storage", "/pagekit/app/cache"]
