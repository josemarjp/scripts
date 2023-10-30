echo "*******************************************************"
echo "*                                                     *"
echo "*                       JOTA'S                        *"
echo "*                     SOLUÇÕES EM TI                  *"
echo "*                                                     *"
echo "*******************************************************"

echo Instaling and configuring Docker - Grafana, MySQL e Zabbix.


#!/bin/bash

# Instalin dependences.
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common

# Add GPG key from Docker repository
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

# Add the Docker repository to the system
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

# Update the package list and install Docker
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Starts and enables the Docker service
systemctl start docker
systemctl enable docker

# Exec Grafana, MySQL and Zabbix containers
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.9.3
docker run -d -p 3000:3000 --name grafana grafana/grafana-enterprise
docker run --name mysql-server -t -e MYSQL_DATABASE="zabbix" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="zabbix" -e MYSQL_ROOT_PASSWORD="zabbix" -d mysql:8.0.30 --character-set-server=utf8 --collation-server=utf8_bin --default-authentication-plugin=mysql_native_password
docker run --name zabbix-java-gateway -t --restart unless-stopped -d zabbix/zabbix-java-gateway
docker run --name zabbix-server -t -e DB_SERVER_HOST="mysql-server" -e MYSQL_DATABASE="zabbix" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="zabbix" -e MYSQL_ROOT_PASSWORD="zabbix" -e ZBX_JAVAGATEWAY="zabbix-java-gateway" --link mysql-server:mysql --link zabbix-java-gateway:zabbix-java-gateway -p 10051:10051 --restart unless-stopped -d zabbix/zabbix-server-mysql
docker run -d -p 10050:10050 --name zabbix-agent --link mysql-server:mysql --link zabbix-server:zabbix-server -e ZBX_HOSTNAME="Zabbix server" -e ZBX_SERVER_HOST="zabbix-server" -d zabbix/zabbix-agent
docker run --name zabbix-web-nginx-mysql -t -e DB_SERVER_HOST="mysql-server" -e MYSQL_DATABASE="zabbix" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="zabbix" -e MYSQL_ROOT_PASSWORD="zabbix" --link mysql-server:mysql -p 80:8080 --restart unless-stopped -d zabbix/zabbix-web-nginx-mysql

echo "Docker has been successfully installed and configured. Grafana, MySQL and Zabbix containers were also launched."
