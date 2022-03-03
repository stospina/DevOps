#!/usr/bin/bash

# Folders Postgresql
# mkdir ~/postgresql && mkdir ~/postgresql_data

# Config for sonarqube
sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072
ulimit -n 131072
ulimit -u 8192

# Docker volumes postgres
docker volume create postgresql
docker volume create postgresql_data
# Jenkins volume
docker volume create jenkins_home
# Sonarqube volumes
docker volume create sonarqube_data
docker volume create sonarqube_extensions
docker volume create sonarqube_logs

# Network
docker network create atnet

# Docker jenkins
docker run -d --name myjenkins \
--network atnet -p 8080:8080 -p 50000:50000 \
-v jenkins_home:/var/jenkins_home \
jenkins/jenkins:lts

#docker postgres
docker run -d --name sonardb \
--network atnet --restart always \
-e POSTGRES_USER=sonar -e POSTGRES_PASSWORD=sonaradmin \
-v postgresql:/var/lib/postgresql \
-v postgresql_data:/var/lib/postgresql_data \
postgres:12.1-alpine

# Docker Sonarqube
docker run -d --name atsonarqube \
--network atnet -p 9000:9000 \
-e SONARQUBE_JDBC_URL=jdbc:postgresql://sonardb/sonar \
-e SONAR_JDBC_USERNAME=sonar \
-e SONAR_JDBC_PASSWORD=sonaradmin \
-v sonarqube_data:/opt/sonarqube/data \
-v sonarqube_extensions:/opt/sonarqube/extensions \
-v sonarqube_logs:/opt/sonarqube/logs \
sonarqube:8.9.0-community

