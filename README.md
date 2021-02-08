Skeema for Rails
================

Here is a Docker container to help make using the Skeema tool with a Rails application abit easier to start.

Yes, this is against the skeema.io documentation but I am just starting to try this out and would
like to avoid having get used to a maintaining migrations in a new way. For now this container will help me
integrate skeema into a pipeline when we deploy.

Docker
------

      docker build -t smart-skeema .

Usage
-----

To have a play about, spin up target and source mysql containers

      docker run -d --name sourcedb -e MYSQL_ALLOW_EMPTY_PASSWORD=yes mysql:5.7
      docker run -d --name targetdb -e MYSQL_ALLOW_EMPTY_PASSWORD=yes mysql:5.7

Next start this container linked to the 2 databases. In order to seed the source database you will need to mount a volume containing the rails db directory.

      docker run -it --rm                \
       -v /some/rails/app/db:/srv/app/db \
       --link sourcedb --link targetdb i \
       smart-skeema rake demo

