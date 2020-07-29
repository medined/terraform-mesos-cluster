#! /bin/bash

apt-get update
apt-get install -y awscli
export AWS_DEFAULT_REGION="${default_region}"

mkdir /home/ubuntu/.aws/
printf "[default]\nregion = us-east-1" >> /home/ubuntu/.aws/config

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
PUBLIC_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)

apt-get install -y tar wget git
apt-get install -y openjdk-8-jdk

mkdir -p /home/ubuntu/apps/zookeeper
cd /home/ubuntu/apps/zookeeper/
mkdir data
mkdir logs

wget http://archive.apache.org/dist/zookeeper/zookeeper-3.6.1/apache-zookeeper-3.6.1-bin.tar.gz
tar -zxf apache-zookeeper-3.6.1-bin.tar.gz

printf "tickTime=2000\ninitLimit=10\nsyncLimit=5\ndataDir=/home/ubuntu/apps/zookeeper/data\nclientPort=2181\n4lw.commands.whitelist=*" >> /home/ubuntu/apps/zookeeper/apache-zookeeper-3.6.1-bin/conf/zoo.cfg

/home/ubuntu/apps/zookeeper/apache-zookeeper-3.6.1-bin/bin/zkServer.sh start >> /home/ubuntu/apps/zookeeper/logs/zookeeper.log 2>&1 &