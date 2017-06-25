# backup-db-s3
This docker image intends to provide functionality to backup your databases running in docker containers and to store them on AWS S3.
It simply calls the appropriate database backup script and uploads the file using [s3cmd](http://s3tools.org/s3cmd).

## Supported databases
- postgres

## Image and sources
The image is automatically built and can be found here: [https://hub.docker.com/r/darignac/backup-db-s3/](https://hub.docker.com/r/darignac/backup-db-s3/)
The source code can be found on Github: [https://github.com/dArignac/docker/backup-db-s3](https://github.com/dArignac/docker/tree/master/backup-db-s3)

## Usage
This image is in development, but you can already use it with the described scenarios below:

### docker-compose
Add the image as service to your compose file.
Below is an example with a default postgres container, the user name as well as the database name are `postgres` in this case.
You have to set all given environment variables.

    version: '2'
    services:
      db:
        image: postgres
      backup:
        image: darignac/backup-db-s3
        command: backup --noop
        depends_on:
          - db
        environment:
          DB_HOST: db
          DB_USER: postgres
          DB_NAME: postgres
          DB_PASSWORD: postgres
          S3_PATH: <BUCKET>/<PATH>/
          AWS_ACCESS_KEY: <AWS_ACCESS_KEY>
          AWS_SECRET_ACCESS_KEY: <AWS_SECRET_ACCESS_KEY>

Then run the backup with: `docker-compose run backup`.
Note that the compose file overrides the default command with `backup --noop` which results in nothing being done on compose up. You surely do not want to run the backup and put it to S3 on each `docker-compose up -d`.

If you do not like to store the AWS secrets in your probably SCM versioned `docker-compose.yml` (which is always a good pratice), then use a `docker-compose.override.yml` containing the secrets (and SCN ignore it), see [here](https://docs.docker.com/compose/extends/).