# darignac/pagekit

## Intro

Docker image for [Pagekit CMS](https://pagekit.com).

**This image is currently in development!! Not fully functional!**

Pagekit Version: 1.0.10

PHP Version: 7

Dockerhub: https://hub.docker.com/r/darignac/pagekit/


## Usage

Best to be used with [docker-compose](https://docs.docker.com/compose/).

It uses these docker images:

* [mysql:5.7](https://hub.docker.com/_/mysql/) (MySQL)
* darignac/pagekit (this image)
* [nginx](https://hub.docker.com/_/nginx/) (Web server)
* [cogniteev/echo](https://hub.docker.com/r/cogniteev/echo/) (Docker mounts)

Sample ``docker-compose.yml``:

```
version: '2'
services:
  db:
	image: mysql:5.7
	env_file: compose.env
	ports:
	   - "3306:3306"
	volumes_from:
	  - data
  pagekit:
	image: darignac/pagekit
	env_file: compose.env
	ports:
	  - "9000:9000"
	links:
	  - db:db
	depends_on:
	  - db
	volumes_from:
	  - data
  nginx:
	image: nginx
	env_file: compose.env
	ports:
	  - "80:80"
	depends_on:
	  - pagekit
	volumes_from:
	  - data
	  - pagekit
  data:
    image: cogniteev/echo
    volumes:
      - ./docker/mounts/mysql:/var/lib/mysql/
      - ./docker/nginx:/etc/nginx/conf.d/
      - ./packages/pagekit:/pagekit-custom/
      - ./docker/pagekit:/pagekit-config/
```

This setup assumes the following folder layout:

```
.
├── compose.env
├── docker
│   ├── mounts
│   └── nginx
│       └── mywebsite.conf
├── docker-compose.yml
└── packages
    └── pagekit
        └── custom-package(s)
```

Folders and files explained:

* ``compose.env``
	* environment file for ``docker-compose`` according to the environment variables of the [MySQL docker image](https://hub.docker.com/_/mysql/)
		```
		MYSQL_ROOT_PASSWORD=XXX
		MYSQL_DATABASE=XXX
		MYSQL_USER=XXX
		MYSQL_PASSWORD=XXX
		```
* ``docker``
	* ``mounts``
		* contains the mountpoints setup through ``docker-compose.yml``
	* ``nginx``
		* contains custom nginx configurations, files have to end with ``.conf``
		* example file (I basically only adjusted the server name, the rest is fpm config)::
			```
			server {
				server_name mywebsite.com;
				listen 80;
				root /pagekit;
				index index.php;
			
				location / {
						# This is cool because no php is touched for static content.
						# include the "?$args" part so non-default permalinks doesn't break when using query string
						try_files $uri $uri/ /index.php?$args;
				}
			
				location ~ \.php$ {
					# Zero-day exploit defense.
					# http://forum.nginx.org/read.php?2,88845,page=3
					# Won't work properly (404 error) if the file is not stored on this server, which is entirely possible with php-fpm/php-fcgi.
					# Comment the 'try_files' line out if you set up php-fpm/php-fcgi on another machine.  And then cross your fingers that you won't get hacked.
					try_files $uri =404;
			
					fastcgi_split_path_info ^(.+\.php)(/.+)$;
					fastcgi_pass pagekit:9000;
					fastcgi_index index.php;
					fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
					include fastcgi_params;
				}
			}
			```
* ``docker-compose.yml``
	* ties all images together
	* the entrypoint of the ``darignac/pagekit`` image is overwritten to mount the custom packages (see below)
* ``packages``
	* ``pagekit``
		* the default structure as within a pagekit installation
		* put your custom packages here, they'll be mounted to the page installation path within the container (/pagekit/packages/pagekit)
		* to use this, you have to adjust some things, [see below](#automatic-with-custom-packages)

## Pagekit installation
### Default
Open the website (in my example http://mywebsite.com) and enter the appropriate values (see your ``compose.env`` file), the database host is ``db``:

![Pagekit installation](https://raw.githubusercontent.com/dArignac/docker/master/pagekit/pki.png "Pagekit Installation screen")

### Automatic with custom packages
To have pagekit being installed automatically and custom packages (like your custom theme) being installed automatically, follow the following steps.

#### Adjust compose.env
You have to setup at least the database specific values within the environment file. The environment variable names are based on the parameters of the ``pagekit setup`` CLI command:

```
root@991f89bf2c32:/pagekit# ./pagekit setup -h
Usage:
  setup [options]

Options:
  -u, --username=USERNAME      Admin username [default: "admin"]
  -p, --password=PASSWORD      Admin account password
  -t, --title[=TITLE]          Site title [default: "Pagekit"]
  -m, --mail[=MAIL]            Admin account email [default: "admin@example.com"]
  -d, --db-driver=DB-DRIVER    DB driver ('sqlite' or 'mysql') [default: "sqlite"]
      --db-prefix[=DB-PREFIX]  DB prefix [default: "pk_"]
  -H, --db-host[=DB-HOST]      MySQL host
  -N, --db-name[=DB-NAME]      MySQL database name
  -U, --db-user[=DB-USER]      MySQL user
  -P, --db-pass[=DB-PASS]      MySQL password
  -l, --locale[=LOCALE]        Locale [default: "en_GB"]
  -h, --help                   Display this help message
  -q, --quiet                  Do not output any message
  -V, --version                Display this application version
      --ansi                   Force ANSI output
      --no-ansi                Disable ANSI output
  -n, --no-interaction         Do not ask any interactive question
  -v|vv|vvv, --verbose         Increase the verbosity of messages: 1 for normal output, 2 for more verbose output and 3 for debug

Help:
 Setup a Pagekit installation
```

##### Minimum compose.env

```
MYSQL_ROOT_PASSWORD=XXX
MYSQL_DATABASE=pkdb
MYSQL_USER=pku
MYSQL_PASSWORD=Avavefuba662
PAGEKIT_DB_DRIVER=mysql
PAGEKIT_DB_PREFIX=pk_
PAGEKIT_DB_HOST=db
PAGEKIT_DB_USERNAME=pku
PAGEKIT_DB_NAME=pkdb
PAGEKIT_DB_PASSWORD=Avavefuba662
```

##### Full compose.env

```
MYSQL_ROOT_PASSWORD=XXX
MYSQL_DATABASE=pkdb
MYSQL_USER=pku
MYSQL_PASSWORD=Avavefuba662
PAGEKIT_USERNAME=admin
PAGEKIT_PASSWORD=password
PAGEKIT_TITLE=My Pagekit Website
PAGEKIT_MAIL=admin@mywebsite.com
PAGEKIT_LOCALE=en_GB
PAGEKIT_DB_DRIVER=mysql
PAGEKIT_DB_PREFIX=pk_
PAGEKIT_DB_HOST=db
PAGEKIT_DB_USERNAME=pku
PAGEKIT_DB_NAME=pkdb
PAGEKIT_DB_PASSWORD=Avavefuba662
```

#### Adjust docker-compose.yml
Add the ``command`` keyword to the pagekit container:

```
...
pagekit:
    image: darignac/pagekit
    env_file: compose.env
    entrypoint: "/pagekit/entrypoint.sh"
    ports:
      - "9000:9000"
...
```

#### Keeping the database
If there is no ``./docker/pagekit/config.php`` file locally and you use the automatic setup then pagekit will be setup each time the containers are newly created. As the database files are mounted this is probably not what you want. If you put your custom ``config.php`` under ``./docker/pagekit/config.php`` then this file will be copied to the pagekit directory and no setup will be executed. Please remember that you have to recreate the container if you adjusted this config file.

You can obtain the initial config file after the automatic setup from the container itself:

```
docker exec -it <CONTAINERNAME> /bin/bash
cat /pagekit/config.php
```