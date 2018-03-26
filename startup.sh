#!/usr/bin/env bash

#set up Go environment
mkdir /home/vagrant/HolmesProcessing/
mkdir /home/vagrant/HolmesProcessing/go/
cd /home/vagrant/HolmesProcessing/go/
mkdir src pkg bin
export GOROOT=/usr/lib/go-1.9
export GOPATH=/home/vagrant/HolmesProcessing/go
export PATH=/usr/lib/go-1.9/bin/:$PATH
#echo "GOROOT=/usr/lib/go-1.9" >> .bashrc
#echo "PATH=/usr/lib/go-1.9/bin/:$PATH" >> .bashrc
#echo "GOPATH=/home/vagrant/HolmesProcessing/go" >> .bashrc

#load Go projects: Storage, Gateway, Totem-Dynamic, Toolbox
cd /home/vagrant/HolmesProcessing/go/
go get github.com/HolmesProcessing/Holmes-Storage
go get github.com/HolmesProcessing/Holmes-Gateway
go get github.com/HolmesProcessing/Holmes-Totem-Dynamic
go get github.com/HolmesProcessing/Holmes-Toolbox

#load Holmes-Totem
cd /home/vagrant/HolmesProcessing/
git clone https://github.com/HolmesProcessing/Holmes-Totem.git

#build Totem, Storage, Gateway, Totem-Dynamic
cd /home/vagrant/HolmesProcessing/Holmes-Totem/
sbt assembly
cd /home/vagrant/HolmesProcessing/go/src/github.com/HolmesProcessing/Holmes-Storage/
go build
cd /home/vagrant/HolmesProcessing/go/src/github.com/HolmesProcessing/Holmes-Gateway/
go build
cd /home/vagrant/HolmesProcessing/go/src/github.com/HolmesProcessing/Holmes-Totem-Dynamic/
go build

#upload configurations for Totem, Storage, Gateway, Totem-Dynamic
cp /home/vagrant/Setup/default-configurations/Totem/totem.conf /home/vagrant/HolmesProcessing/Holmes-Totem/config/totem.conf
cp /home/vagrant/Setup/default-configurations/Totem/docker-compose.yml /home/vagrant/HolmesProcessing/Holmes-Totem/config/docker-compose.yml
cp /home/vagrant/Setup/default-configurations/Storage/storage.conf /home/vagrant/HolmesProcessing/go/src/github.com/HolmesProcessing/Holmes-Storage/config/storage.conf
cp /home/vagrant/Setup/default-configurations/Gateway/gateway.conf /home/vagrant/HolmesProcessing/go/src/github.com/HolmesProcessing/Holmes-Gateway/config/gateway.conf
cp /home/vagrant/Setup/default-configurations/Totem-Dynamic/totem-dynamic.conf /home/vagrant/HolmesProcessing/go/src/github.com/HolmesProcessing/Holmes-Totem-Dynamic/config/totem-dynamic.conf

#install Minio and its Client
sudo docker pull minio/minio
sudo docker run -d -p 9000:9000 --name minio1 -e "MINIO_ACCESS_KEY=admin" -e "MINIO_SECRET_KEY=allyours3arebelongtous" -v /mnt/data:/data -v /mnt/config:/root/.minio minio/minio server /data
cd /home/vagrant/
wget https://dl.minio.io/client/mc/release/linux-amd64/mc
chmod +x mc

#set conf files for services 
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/yara/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/yara/service.conf
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/asnmeta/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/asnmeta/service.conf
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/dnsmeta/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/dnsmeta/service.conf
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/gogadget/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/gogadget/service.conf
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/objdump/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/objdump/service.conf
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/passivetotal/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/passivetotal/service.conf
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/pdfparse/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/pdfparse/service.conf
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/peid/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/peid/service.conf
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/peinfo/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/peinfo/service.conf
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/pemeta/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/pemeta/service.conf
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/richheader/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/richheader/service.conf
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/shodan/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/shodan/service.conf
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/virustotal/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/virustotal/service.conf
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/zipmeta/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/zipmeta/service.conf
cp /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/cfgangr/service.conf.example /home/vagrant/HolmesProcessing/Holmes-Totem/src/main/scala/org/holmesprocessing/totem/services/cfgangr/service.conf

#make Holmes Applications run through systemd
cd /home/vagrant/Setup/systemd_services/
sudo cp documentStorage.service /etc/systemd/system/documentStorage.service
sudo cp fakes3.service /etc/systemd/system/fakes3.service
sudo cp objectStorage.service /etc/systemd/system/objectStorage.service
sudo cp totem-planner.service /etc/systemd/system/totem-planner.service
sudo cp gateway-planner.service /etc/systemd/system/gateway-planner.service
sudo cp storage-planner.service /etc/systemd/system/storage-planner.service
sudo systemctl daemon-reload


#run starter services
sudo service rabbitmq-server start
sudo service cassandra start
#sudo service fakes3 start
#sudo service documentStorage start
#sudo service objectStorage start
#sudo service gateway-planner start
#sudo service totem-planner start
#sudo service storage-planner start

