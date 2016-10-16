FROM phusion/baseimage
MAINTAINER Alexander Herrmann <darignac@gmail.com>
ENV PAGEKIT_VERSION=1.0.8
RUN apt-get update \
    && apt-get -y install \
    unzip \
    wget \
    ca-certificates \
    php7.0 \
    php7.0-fpm \
    php7.0-cli \
    php7.0-json \
    php7.0-mysql \
    php7.0-curl \
    php7.0-simplexml \
    php7.0-dom \
    php7.0-mbstring \
    php7.0-zip \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /pagekit
WORKDIR /pagekit
VOLUME ["/pagekit/storage", "/pagekit/app/cache"]
RUN wget https://github.com/pagekit/pagekit/releases/download/${PAGEKIT_VERSION}/pagekit-${PAGEKIT_VERSION}.zip -O /pagekit/pagekit.zip \
    && unzip /pagekit/pagekit.zip \
    && rm /pagekit/pagekit.zip
CMD ["sh" "-c" "service php7.0-fpm start"]
