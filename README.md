# Postgresql-12
postgres 12 on ubuntu 16.04

This is specifically designed for ejabberd application.

The init.sql file should be in same folder while building docker image. 

Use below command to connect remotely once the container and Database is up

psql -h localhost -U postgresq --password 
