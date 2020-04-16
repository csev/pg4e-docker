Setting up PG4E in Production
=============================

To do this in a real EC2 Instance - create an instance based on ubuntu 18.04.
Use a security group which opens ports 80, 5432, and 8001.  Then and login
and become root:

    sudo bash

To test the ami scripts in a docker container so you can start over:

    docker run -p 8080:80 -p 5000:5432 -p 8001:8001 --name ubuntu -dit ubuntu:18.04
    docker exec -it ubuntu bash

Common commands for EC2 or docker once in as `root`:

    apt-get update
    apt-get install -y git vim

Check out this repository and Tsugi's php-docker:

    cd /root
    git clone https://github.com/tsugiproject/docker-php.git
    git clone https://github.com/csev/pg4e-docker.git

Then fill up our disk the the Tsugi pre-requisites:

    cd docker-php

    bash ami/build.sh

Do *not* run the `tsugi-dev-startup.sh`

Then come back here and add more to the kernel

    cd ../pg4e-docker
    bash ami/prepare.sh docker

At this point if you are in an ECS and want to snapshot an AMI for an autoscaling group
or something - do it now.  The rest is configuration and startup:

    cp ami-env-dist.sh  ami-env.sh

Edit the config...

    source ami-env.sh
    bash /usr/local/bin/tsugi-pg4e-startup.sh return

The `pg4e-startup` script will run all the Tsugi scripts in the right order.

The navigate to http://localhost:8080/ or http://12.34.56.78/ depending on your server.

If you are goging to code - here is the git config:

    git config user.name "Charles R. Severance"
    git config user.email "csev@umich.edu"


