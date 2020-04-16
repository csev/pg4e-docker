Setting up PG4E in Production
=============================

To do this in a real EC2 Instance - create an instance based on ubuntu 18.04.
Use a security group which opens ports 80, 5432, and 8001.  Then and login
and become root:

    sudo bash
    set -o history

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
or something - do it now.  Or perhaps take a docker snapshot to come back to this point:

    docker commit d6c36062e38b tsugi:snap

The rest is configuration and startup:

    cp ami-env-dist.sh  ami-env.sh

Edit the config if you are building a production box:

    export APACHE_SERVER_NAME=www.pg4e.com
    export TSUGI_APPHOME=https://www.pg4e.com

Then complete install and configure:

    source ami-env.sh
    bash /usr/local/bin/tsugi-pg4e-startup.sh return

The `pg4e-startup` script will run all the Tsugi scripts in the right order.

The navigate to http://localhost:8080/ or http://12.34.56.78/ depending on your server.

Es configuration:

    es_host:  127.0.0.1  or test.pg4e.com
    es_port:  8001
    es_prefix: v1/basicauth/elasticsearch

If you are goging to code - here is the git config:

    git config user.name "Charles R. Severance"
    git config user.email "csev@umich.edu"

Getting a Certificate
---------------------

    root@ip-172-31-2-126:/root/pg4e-docker# certbot --apache
    Saving debug log to /var/log/letsencrypt/letsencrypt.log
    Plugins selected: Authenticator apache, Installer apache
    Enter email address (used for urgent renewal and security notices) (Enter 'c' to
    cancel): csev@umich.edu

    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Please read the Terms of Service at
    https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
    agree in order to register with the ACME server at
    https://acme-v02.api.letsencrypt.org/directory
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    (A)gree/(C)ancel: A

    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Would you be willing to share your email address with the Electronic Frontier
    Foundation, a founding partner of the Let's Encrypt project and the non-profit
    organization that develops Certbot? We'd like to send you email about our work
    encrypting the web, EFF news, campaigns, and ways to support digital freedom.
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    (Y)es/(N)o: Y
    No names were found in your configuration files. Please enter in your domain
    name(s) (comma and/or space separated)  (Enter 'c' to cancel): www.pg4e.com
    Obtaining a new certificate
    Performing the following challenges:
    http-01 challenge for www.pg4e.com
    Waiting for verification...
    Cleaning up challenges
    Created an SSL vhost at /etc/apache2/sites-available/000-default-le-ssl.conf
    Enabled Apache socache_shmcb module
    Enabled Apache ssl module
    Deploying Certificate to VirtualHost /etc/apache2/sites-available/000-default-le-ssl.conf
    Enabling available site: /etc/apache2/sites-available/000-default-le-ssl.conf

    Please choose whether or not to redirect HTTP traffic to HTTPS, removing HTTP access.
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    1: No redirect - Make no further changes to the webserver configuration.
    2: Redirect - Make all requests redirect to secure HTTPS access. Choose this for
    new sites, or if you're confident your site works on HTTPS. You can undo this
    change by editing your web server's configuration.
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Select the appropriate number [1-2] then [enter] (press 'c' to cancel): 2
    Redirecting vhost in /etc/apache2/sites-enabled/000-default.conf to ssl vhost in /etc/apache2/sites-available/000-default-le-ssl.conf

    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Congratulations! You have successfully enabled https://www.pg4e.com

    You should test your configuration at:
    https://www.ssllabs.com/ssltest/analyze.html?d=www.pg4e.com
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    IMPORTANT NOTES:
     - Congratulations! Your certificate and chain have been saved at:
       /etc/letsencrypt/live/www.pg4e.com/fullchain.pem
       Your key file has been saved at:
       /etc/letsencrypt/live/www.pg4e.com/privkey.pem
       Your cert will expire on 2020-07-15. To obtain a new or tweaked
       version of this certificate in the future, simply run certbot again
       with the "certonly" option. To non-interactively renew *all* of
       your certificates, run "certbot renew"

