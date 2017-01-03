#!/usr/bin/env bash
# mount the custom packages
for d in /pagekit-custom/*; do
	PACKAGE_PATH=/pagekit/packages/pagekit/$(basename ${d})
	ln -s -d ${d} ${PACKAGE_PATH}
	chown www-data:www-data -R ${PACKAGE_PATH}
done;

# install pagekit but wait for DB
sleep 10
/pagekit/pagekit setup \
	--username=${PAGEKIT_USERNAME} \
	--password=${PAGEKIT_PASSWORD} \
	--title="${PAGEKIT_TITLE}" \
	--mail="${PAGEKIT_MAIL}" \
	--db-driver=${PAGEKIT_DB_DRIVER} \
	--db-prefix=${PAGEKIT_DB_PREFIX} \
	--db-host=${PAGEKIT_DB_HOST} \
	--db-name=${PAGEKIT_DB_NAME} \
	--db-user=${PAGEKIT_DB_USERNAME} \
	--db-pass=${PAGEKIT_DB_PASSWORD} \
	--locale=${PAGEKIT_LOCALE}

# run the default entrypoint and command of php image
/usr/local/bin/docker-php-entrypoint php-fpm