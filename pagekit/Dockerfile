FROM php:7-fpm
MAINTAINER Alexander Herrmann <darignac@gmail.com>
ENV PAGEKIT_VERSION=1.0.10
RUN apt-get update \
    && apt-get -y install \
    unzip \
    wget \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install zip pdo_mysql \
    && docker-php-source delete \
    && mkdir -p /pagekit \
    && mkdir -p /pagekit-custom
WORKDIR /pagekit
RUN wget https://github.com/pagekit/pagekit/releases/download/${PAGEKIT_VERSION}/pagekit-${PAGEKIT_VERSION}.zip -O /pagekit/pagekit.zip \
    && unzip /pagekit/pagekit.zip \
    && rm /pagekit/pagekit.zip \
    && chown www-data:www-data -R /pagekit \
    && chmod g+w -R /pagekit \
    && chmod +x /pagekit/pagekit
ADD entrypoint.sh /pagekit
RUN chmod +x /pagekit/entrypoint.sh
VOLUME ["/pagekit", "/pagekit-custom"]
