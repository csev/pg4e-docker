
Tsugi PG4E Test harness

Pre-Requisite - build these - https://github.com/tsugiproject/docker-php.git

    docker build --tag tsugi_pg4e .

    docker run -p 8080:80 -p 3306:3306 -p 5000:5432 -p 8001:8001 -e TSUGI_APPHOME=http://localhost:8080 -e TSUGI_SERVICENAME=PG4E -e MYSQL_ROOT_PASSWORD=secret -e PSQL_ROOT_PASSWORD=secret -e MAIN_REPO=https://github.com/csev/pg4e -e CHARLES_AUTH_SECRET=secret -e CHARLES_POSTGRES_PASSWORD=zippy --volume-driver=nfs  -v /Users/csev/docker:/mnt/csev --name pg4e -dit tsugi_pg4e:latest

    navigate to http://localhost:8080/

    docker exec -it pg4e bash

This should fail from outside the container because `postgres` is blocked

    host: psql -h 127.0.0.1 -p 5000 -U postgres -W

These should work inside the container with the `postgres` account:

    psql -h 127.0.0.1 -p 5432 -U postgres -W
    CREATE USER x WITH PASSWORD 'y';
    CREATE DATABASE pg4e WITH OWNER x;

This should work outside the container once the account is created:

    psql -h 127.0.0.1 -p 5000 -U x pg4e

This is a quick test of `charles-server` and `elasticsearch:

    curl -X GET http://127.0.0.1:8001/v1/elasticsearch
    # {"errors":[{"title":"Scope Error","detail":"No token provided.","status":403}]}

When configuring the sql autograder:

    es_prefix: v1/basicauth/elasticsearch

