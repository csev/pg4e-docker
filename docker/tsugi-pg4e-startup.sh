
echo "Running PG4E Startup"

bash /usr/local/bin/tsugi-dev-startup.sh return

echo Starting PostgreSQL
service postgresql start

echo "Starting elasticsearch"

service --status-all
service elasticsearch start

CHARLES_POSTGRES_HOST=localhost ; export CHARLES_POSTGRES_HOST
CHARLES_POSTGRES_PORT=5432 ; export CHARLES_POSTGRES_PORT
CHARLES_ELASTICSEARCH_URI=http://localhost:9200 ; export CHARLES_ELASTICSEARCH_URI

# Test with
# curl -X GET http://127.0.0.1:8001/v1/elasticsearch
# {"errors":[{"title":"Scope Error","detail":"No token provided.","status":403}]}

if [ -z "$CHARLES_POSTGRES_USER" ]; then
CHARLES_POSTGRES_USER=charles; export CHARLES_POSTGRES_USER;
fi
if [ -z "$CHARLES_POSTGRES_PASSWORD" ]; then
CHARLES_POSTGRES_PASSWORD=secret; export CHARLES_POSTGRES_PASSWORD;
fi
if [ -z "$CHARLES_POSTGRES_DATABASE" ]; then
CHARLES_POSTGRES_DATABASE=charles; export CHARLES_POSTGRES_DATABASE;
fi

# Make sure this has execute permission
chmod +x /etc/init.d/charles-server
chmod +x /usr/local/bin/charles-server-start.sh

COMPLETE=/usr/local/bin/tsugi-pg4e-complete
if [ -f "$COMPLETE" ]; then
    echo "Starting charles-server"
    service --status-all
    # https://github.com/fhd/init-script-template
    service charles-server start

    echo "https://certbot.eff.org/lets-encrypt/ubuntubionic-apache"
    echo " "
    echo "certbot --apache --dry-run"
    echo "cron: certbot renew --dry-run"
    echo "PG4E Startup Already has run"
else

# https://stackoverflow.com/questions/18715345/how-to-create-a-user-for-postgres-from-the-command-line-for-bash-automation
if [ -z "$PSQL_ROOT_PASSWORD" ]; then
PSQL_ROOT_PASSWORD=password; export PSQL_ROOT_PASSWORD;
fi

echo "Setting psql root password to $PSQL_ROOT_PASSWORD"
sudo -i -u postgres psql -c "ALTER ROLE postgres WITH PASSWORD '$PSQL_ROOT_PASSWORD'"

echo "Creating user/database for charles-server with password $CHARLES_POSTGRES_PASSWORD"
sudo -i -u postgres psql -c "CREATE USER charles WITH PASSWORD '$CHARLES_POSTGRES_PASSWORD'"
sudo -i -u postgres psql -c "CREATE DATABASE charles WITH OWNER charles"

# http://wiki.postgresql.org/wiki/Shared_Database_Hosting
echo "Tighten up template1 for shared hosting 123"
sudo -i -u postgres psql template1 -f - << EOT

REVOKE CREATE ON DATABASE template1 FROM public;
REVOKE CONNECT ON DATABASE template1 FROM public;

REVOKE ALL ON pg_user FROM public;
REVOKE ALL ON pg_roles FROM public;
REVOKE ALL ON pg_group FROM public;
REVOKE ALL ON pg_authid FROM public;
REVOKE ALL ON pg_auth_members FROM public;

REVOKE ALL ON pg_database FROM public;
REVOKE ALL ON pg_tablespace FROM public;
REVOKE ALL ON pg_settings FROM public;

EOT

echo "Removing phpMyAdmin"
rm -rf /var/www/html/phpMyAdmin /var/www/html/phppgadmin

echo "Adding and configuring phppgadmin"
cd /var/www/html/
git clone https://github.com/csev/phppgadmin.git
cp /var/www/html/scripts/config.inc.php /var/www/html/phppgadmin/conf/config.inc.php

cat >> /var/www/html/tsugi/config.php << EOF
\$CFG->tool_folders = array("admin", "../tools", "mod");
\$CFG->psql_root_password = "$PSQL_ROOT_PASSWORD";
\$CFG->theme = array(
    "primary" => "#336791", //default color for nav background, splash background, buttons, text of tool menu
    "secondary" => "#EEEEEE", // Nav text and nav item border color, background of tool menu
    "text" => "#111111", // Standard copy color
    "text-light" => "#5E5E5E", // A lighter version of the standard text color for elements like "small"
    "font-url" => "https://fonts.googleapis.com/css2?family=Open+Sans", // Optional custom font url for using Google fonts
    "font-family" => "'Open Sans', Corbel, Avenir, 'Lucida Grande', 'Lucida Sans', sans-serif", // Font family
    "font-size" => "14px", // This is the base font size used for body copy. Headers,etc. are scaled off this value
);

EOF

# Open things up all but postgres user
# https://dba.stackexchange.com/questions/83984/connect-to-postgresql-server-fatal-no-pg-hba-conf-entry-for-host
# https://stackoverflow.com/questions/61179852/how-to-configure-postgessql-to-accept-all-incoming-connections-except-postgres
cat >> /etc/postgresql/11/main/pg_hba.conf << EOF
host    all             postgres        0.0.0.0/0               reject
host    all             charles         127.0.0.1/32            md5
host    all             charles         0.0.0.0/0               reject
host    all             all             0.0.0.0/0               md5
EOF

# https://blog.bigbinary.com/2016/01/23/configure-postgresql-to-allow-remote-connection.html
rm -f /tmp/x
sed "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" < /etc/postgresql/11/main/postgresql.conf > /tmp/x
cp /tmp/x /etc/postgresql/11/main/postgresql.conf
rm -f /tmp/x

cat > /root/.vimrc << EOF
set sw=4 ts=4 sts=4 et
filetype plugin indent on
autocmd FileType java setlocal sw=4 ts=4 sts=4 noet
syntax on
EOF

echo "Restart PostgreSQL"
service postgresql restart

# Fix the composer bits
EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
then
    >&2 echo 'ERROR: Invalid installer checksum'
    rm composer-setup.php
    exit 1
fi

# php composer-setup.php --quiet
php composer-setup.php --install-dir=/usr/local/bin
RESULT=$?
rm composer-setup.php

# Run composer
PWD=`pwd`
cd /var/www/html/tools/sql
php /usr/local/bin/composer.phar install
echo $PWD

fi

echo "Starting charles-server"
service --status-all
service charles-server start

echo "https://certbot.eff.org/lets-encrypt/ubuntubionic-apache"
echo " "
echo "certbot --apache --dry-run"
echo "cron: certbot renew --dry-run"

touch $COMPLETE

echo ""
if [ "$@" == "return" ] ; then
  echo "Tsugi PG4E Startup Returning..."
  exit
fi

exec bash /usr/local/bin/monitor-apache.sh

# Should never happen
# https://stackoverflow.com/questions/2935183/bash-infinite-sleep-infinite-blocking
echo "Tsugi PG4E Sleeping forever..."
while :; do sleep 2073600; done
