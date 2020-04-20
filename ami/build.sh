

cd /root/docker-php
bash ami/build.sh

echo 
echo ========================
echo Starting pg4e build
echo ========================
echo 

cd /root/pg4e-docker
bash ami/prepare.sh docker

