#!/usr/bin/env bash
# mount the custom packages
for d in /pagekit-custom/*; do
	PACKAGE_PATH=/pagekit/packages/pagekit/$(basename ${d})
	ln -s -d ${d} ${PACKAGE_PATH}
	chown www-data:www-data -R ${PACKAGE_PATH}
done;

# run the default entrypoint and command of php image
/usr/local/bin/docker-php-entrypoint php-fpm