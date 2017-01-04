#!/usr/bin/env bash
# mount the custom packages
for d in /pagekit-custom/*; do
	PACKAGE_PATH=/pagekit/packages/pagekit/$(basename ${d})
	ln -s -d ${d} ${PACKAGE_PATH}
	chown www-data:www-data -R ${PACKAGE_PATH}
done;

# install pagekit but wait for DB
sleep 10

# if there is a custom config.php, copy it and chown correctly, else execute the setup
if [ -f "/pagekit-config/config.php" ]
then
	echo "copying existing custom config to /pagekit"
	cp /pagekit-config/config.php /pagekit/config.php
	chown www-data:www-data /pagekit/config.php
else
	echo "executing pagekit setup via CLI"
	# this is run as root
	/pagekit/pagekit setup -vvv --no-interaction \
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

	# adjust config.php ownership
	chown www-data:www-data config.php
fi

# run the default entrypoint and command of php image
/usr/local/bin/docker-php-entrypoint php-fpm