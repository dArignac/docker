# backup-mysql-s3
This docker image intends to provide functionality to backup your MySQL database running in docker containers and to store them on AWS S3.
It simply calls the ``mysqldump`` and uploads the file using [s3cmd](http://s3tools.org/s3cmd).

## Image and sources
The image is automatically built and can be found here: [https://hub.docker.com/r/darignac/backup-mysql-s3/](https://hub.docker.com/r/darignac/backup-mysql-s3/)
The source code can be found on Github: [https://github.com/dArignac/docker/backup-mysql-s3](https://github.com/dArignac/docker/tree/master/backup-mysql-s3)

## Usage
This image is in development, but you can already use it with the described scenarios below:

### docker-compose
Add the image as service to your compose file.
Below is an example with a default mysql container.
You have to set all given environment variables.

    version: '2'
    services:
      db:
        image: mysql
        environment:
          MYSQL_DATABASE: mydb
          MYSQL_USER: myuser
          MYSQL_PASSWORD: mypassword
      backup:
        image: darignac/backup-db-s3
        entrypoint: /home/bu/backup --noop
        depends_on:
          - db
        environment:
          DB_HOST: db
          DB_PORT: 3306
          DB_USER: myuser
          DB_NAME: mydb
          DB_PASSWORD: mypassword
          S3_PATH: <BUCKET>/<PATH>/
          AWS_ACCESS_KEY: <AWS_ACCESS_KEY>
          AWS_SECRET_ACCESS_KEY: <AWS_SECRET_ACCESS_KEY>

Then run the backup with: `docker-compose run --rm --entrypoint /home/bu/backup backup`. You could add this call to a crontab to make periodic backups.
Note that the compose file overrides the default command with `backup --noop` which results in nothing being done on compose up. You surely do not want to run the backup and put it to S3 on each `docker-compose up -d`.

If you do not like to store the AWS secrets in your probably SCM versioned `docker-compose.yml` (which is always a good pratice), then use a `docker-compose.override.yml` containing the secrets (and SCN ignore it), see [here](https://docs.docker.com/compose/extends/).