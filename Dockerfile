 FROM ubuntu:16.04
 
 MAINTAINER Mahesh Nyayadhish <mahesh.nyayadhish@taashee.com>
 
# Add the PostgreSQL PGP key to verify their Debian packages.

RUN apt-get update
RUN apt-get -y install wget
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

 
# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``12``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" |tee  /etc/apt/sources.list.d/pgdg.list
RUN apt-get update

# Install ``python-software-properties``, ``software-properties-common`` and PostgreSQL 12
# There are some warnings (in red) that show up during the build. You can hide
# them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive
RUN apt-get install postgresql-12 -y

# Note: The official Debian and Ubuntu images automatically ``apt-get clean``
# after each ``apt-get``
 
# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.6`` package when it was ``apt-get installed``
USER postgres
ENV POSTGRES_PASSWORD postgres
 
# Create a PostgreSQL role named ``postgresq`` with ``postgresq`` as the password and
# then run the script init.sql
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
COPY init.sql /docker-entrypoint-initdb.d/
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER postgresq WITH SUPERUSER PASSWORD 'postgresq';" &&\
    createdb -O postgresq postgresq &&\
psql -d postgresq -af /docker-entrypoint-initdb.d/init.sql
   
 
# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/12/main/pg_hba.conf
 
# And add ``listen_addresses`` to ``/etc/postgresql/9.6/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/12/main/postgresql.conf
 
# Expose the PostgreSQL port
EXPOSE 5432
 
# Add VOLUMEs to allow backup of config, logs and databases
#VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
 
# Set the default command to run when starting the container
RUN service postgresql start
CMD ["/usr/lib/postgresql/12/bin/postgres", "-D", "/var/lib/postgresql/12/main", "-c", "config_file=/etc/postgresql/12/main/postgresql.conf"]
