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

### Pagekit installation
Open the website (in my example http://mywebsite.com) and enter the appropriate values, the database host is ``db``.

With a ``compose.env`` file like this it has to look like that:

```
MYSQL_ROOT_PASSWORD=Iweka2Ufuk44
MYSQL_DATABASE=pkdb
MYSQL_USER=pku
MYSQL_PASSWORD=Iposa3Ebor61
```

![Pagekit installation](https://raw.githubusercontent.com/dArignac/docker/master/pagekit/pki.png "Pagekit Installation screen")
