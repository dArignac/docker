PHP in a container with gettext. I use it for Wordpress tools.

Best to use it via a file `php`, make it executable and add the following:

```
#!/bin/bash
docker run --rm -i -v /home/alex:/home/alex php:alpine php "$@"
```

Then run for example:

```
cd /home/alex/projects/a-wordpress-theme
/home/alex/php /home/alex/projects/wordpress-core/tools/i18n/makepot.php wp-theme /home/alex/projects/a-wordpress-theme
```
