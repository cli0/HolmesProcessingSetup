# Holmes Processing Setup

This repository provides the necessary scripts and other documentation you would need to set up the Holmes Processing system on your machine. We use Vagrant to automate virtual machine creation and provisioning. Before moving forward, if you intend to set up Holmes on a VM, you need to install [Vagrant](https://www.vagrantup.com/intro/getting-started/install.html) version 2.0.1 or newer and [VirtualBox](https://www.virtualbox.org/) version 5.2.2 or newer.

## What is Holmes Processing?

Holmes Processing was born out of the need to rapidly process and analyze large volumes data in the computer security community. At its core, Holmes Processing is a catalyst for extracting useful information and generate meaningful intelligence. Furthermore, the robust distributed architecture allows the system to scale while also providing the flexibility needed to evolve. [For more details download the overview presentation here.](https://www.holmesprocessing.com/downloads/Holmes_Processing_Overview_2017.pdf) The original repository for [this project is on github](https://github.com/HolmesProcessing).

## Start Up and Provisioning (automated)

To start up the Virtual Machine execute the following commands:
```shell
cd /HolmesProcessingSetup
vagrant up
vagrant ssh
```

This initial run is going to take a while (~15 minutes, depending on your internet connection). Vagrant will run the `bootstrap.sh` script to provision the VM with every necessary dependency. 

## Downloading, configuration and build (automated)

This repository provides a script that will set up all the folders, download sane configuration files and build the Holmes application. After you have entered your VM, run the `startup.sh` script and *most* things will be set up for you. Due to the nature of some commands, you will still have to run some things manually.

```shell
cd /home/vagrant/Setup/
./startup.sh
```

## Manual Setup Steps

At the moment you can't run the services though systemd so you will have to instantiate them manually. It is recommened to use [tmux](https://danielmiessler.com/study/tmux/#gs.zZb0q7U) to run the services in the background.

**Minio Setup**

After Storage is successfully running in the background, you need to run the following 2 commands to properly set up minio. 

```shell
cd /home/vagrant/
./mc config host add minio1 http://localhost:9000 admin allyours3arebelongtous
sudo ./mc policy download minio1/samples/
```

The first line configures our current minio instance and the second line allows for the content of our samples/ bucket to be downloaded.

**Holmes-Storage**

Due to a bug in the source code, you will need to create the keyspace for Cassandra manually in order to initiate Holmes-Storage. To do so, you need to run the following commands:

```shell
cqlsh
create keyspace "holmes" with replication = {'class': 'NetworkTopologyStrategy', 'datacenter1':1};
exit;
```

Now you can start Storage, use tmux here.

```shell
cd /home/vagrant/HolmesProcessing/go/src/github.com/HolmesProcessing/Holmes-Storage/
./Holmes-Storage --config ./config/storage.conf --setup
./Holmes-Storage --config ./config/storage.conf --objSetup
./Holmes-Storage --config ./config/storage.conf
```

**Holmes-Totem**

Holmes-TOTEM is an orchestrator and central point of reference for the feature extraction services. It allows you to upload the configuration files for the individual services to Holmes-Storage.

To run the Totem planner (use tmux):
```shell
cd /home/vagrant/HolmesProcessing/Holmes-Totem/
java -jar ./target/scala-2.11/totem-assembly-0.5.0.jar
```

Every service runs in its own docker container. To start the services run:
```shell
cd /home/vagrant/HolmesProcessing/Holmes-Totem/
sudo docker-compose -f ./config/docker-compose.yml up -d
```

**Holmes-Gateway**

To finish the configuration of Gateway, you need to generate the necessary certificates. Run:
```shell
cd /home/vagrant/HolmesProcessing/go/src/github.com/HolmesProcessing/Holmes-Gateway/config/
./mkcert.sh
```

To run the gateway planner (use tmux):
```shell
cd /home/vagrant/HolmesProcessing/go/src/github.com/HolmesProcessing/Holmes-Gateway/
./Holmes-Gateway --config config/gateway.conf
```

**Optional Setup Notes**

If you want to access the Web UI for RabbitMQ run the following command and then create the file `/etc/rabbitmq/rabbitmq.conf` with the content `loopback_users = none`:

```shell
sudo rabbitmq-plugins enable rabbitmq_management
```

## How to Store Samples using Storage

In order to upload samples to storage, the user sends an HTTPS-encrypted POST request to `/samples/` of the Holmes-Gateway. Gateway will forward every request for this URI directly to storage. If storage signals a success, Gateway will immediately issue a tasking-request for the new samples, if the configuration-option AutoTasks is not empty.

You can use Holmes-Toolbox for this purpose. Just replace the storage-URI with the URI of Gateway. Also make sure, your SSL-Certificate is accepted. You can do so either by adding it to your system's certificate store or by using the command-line option `--insecure`. The following command uploads all files from the directory `$dir` to the Gateway instance residing at 127.0.0.1:8090 using 5 threads.

```shell
cd /home/vagrant/HolmesProcessing/go/src/github.com/HolmesProcessing/Holmes-Toolbox
./Holmes-Toolbox --gateway https://localhost:8090 --user test --pw test --dir $dir --tags '["tag1","tag2"]' --src Org1 --comment something --workers 5 --insecure
```

## How to Submit Jobs

In order to request a task, a user sends an HTTPS-request (GET/POST) to Gateway
containing the following form-fields:
* **username**: The user's login-name
* **password**: The user's password
* **task**: The task which should be executed in json-form, as described below.

A task consists of the following attributes:
* **primaryURI**: The user enters only the sha256-sum here, as Gateway will
prepend this with the URI to its version of Holmes-Storage
* **secondaryURI** (optional): A secondary URI to the sample, if the primaryURI isn't found
* **filename**: The name of the sample
* **tasks**: All the tasks that should be executed, as a dict
* **tags**: A list of tags associated with this task
* **attempts**: The number of attempts. Should be zero
* **source**: The source this sample belongs to. The executing organization is chosen mainly based on this value
* **download**: A boolean specifying, whether totem has to download the file given as PrimaryURI

For this purpose any webbrowser or commandline utility can be used. The following demonstrates an exemplary evocation using CURL. The --insecure parameter is used, to disable certificate checking.

You can submit jobs:

```shell
curl --data 'username=test&password=test&task=[{"primaryURI":"9ce95883c5821c3fa7b9319f4952d67ae077cdd79d5327dd7bed63542703cb82","secondaryURI":"","filename":"myfile","tasks":{"PEINFO":[]},"tags":["test1"],"attempts":0,"source":"src1","download":true}]' --insecure https://localhost:8090/task/
```

Alternatively, it is possible to use Holmes-Toolbox for this task, as well. First a file must be prepared containing a line with the sha256-sum, the filename, and the source (separated by single spaces) for each sample.

```shell
./Holmes-Toolbox --gateway https://localhost:8090 --tasking --file sampleFile --user test --pw test --tasks '{"PEINFO":[]}' --tags '["mytag"]' --comment 'mycomment' --insecure
```

If no error occured, nothing or an empty list will be returned. Otherwise a list containing the
faulty tasks, as well as a description of the errors will be returned.


