#!/usr/bin/env bash



# The first step of the set up is about setting up 
# the necessary libraries and packages.




#install git
sudo apt-get update
sudo apt-get install git-all -y

#install rabbitmq and erlang dependency
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get install esl-erlang=1:19.3.6 -y
echo "deb https://dl.bintray.com/rabbitmq/debian xenial main" | sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list
wget -O- https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc |
     sudo apt-key add -
rm erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get install rabbitmq-server -y

#install fake-s3
sudo apt-get install ruby -y
sudo gem install fakes3

#install miscellaneous
sudo apt-get install default-jre -y
sudo apt-get install default-jdk -y
sudo apt-get install -y python python3 tmux curl libmagic1 libmagic-dev python-pip
export LC_ALL=C
pip install -U pip
sudo pip install --upgrade pip
sudo pip install tornado
sudo pip install pika

#install cassandra
echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add - 
sudo apt-get update 
sudo apt-key adv --keyserver pool.sks-keyservers.net --recv-key A278B781FE4B2BDA 
sudo apt-get install cassandra -y

#install sbt
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
sudo apt-get update
sudo apt-get install sbt -y

#install docker-ce and docker-compose
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce -y

sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#install and set up go
sudo add-apt-repository ppa:gophers/archive -y
sudo apt-get update
sudo apt-get install golang-1.9-go -y
sudo apt-get update

