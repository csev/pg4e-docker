#! /bin/bash

source /root/pg4e-docker/ami-env.sh
env

if [ -z "$CHARLES_POSTGRES_USER" ]; then
CHARLES_POSTGRES_USER=charles; export CHARLES_POSTGRES_USER;
fi
if [ -z "$CHARLES_POSTGRES_PASSWORD" ]; then
CHARLES_POSTGRES_PASSWORD=secret; export CHARLES_POSTGRES_PASSWORD;
fi
if [ -z "$CHARLES_AUTH_SECRET" ]; then
CHARLES_AUTH_SECRET=12345; export CHARLES_AUTH_SECRET;
fi

if [-z "$CHARLES_POSTGRES_DATABASE" ]; then
CHARLES_POSTGRES_DATABASE=charles; export CHARLES_POSTGRES_DATABASE;
fi

cd /charles-server
source .venv/bin/activate
python /charles-server/server --port 8001

