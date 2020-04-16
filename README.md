Setting up PG4E in Production

To test the ami scripts in a docker container so you can start over

    docker run -p 8080:80 -p 3306:3306 -p 5000:5432 -p 8001:8001 --name ubuntu -dit ubuntu:18.04
    docker exec -it ubuntu bash

Then augment the kernel for Tsugi in the docker:

    apt-get update
    apt-get install -y git
    apt-get install -y vim
    git config user.name "Charles R. Severance"
    git config user.email "csev@umich.edu"

    cd /root
    git clone https://github.com/tsugiproject/docker-php.git

    cd docker-php

    bash ami/build.sh

Then come back here:

    cd ../pg4e-production

    cp ami-env-dist.sh  ami-env.sh

Add lines like:



