#!/bin/bash

apt-get update
apt-get install -y awscli
apt install -y jq
export AWS_DEFAULT_REGION=${default_region}

mkdir -p /home/ubuntu/apps/
cd /home/ubuntu/apps/
aws s3 cp s3://mesos-development/splunk/splunk-8.0.2.1-f002026bad55-Linux-x86_64.tgz .

tar -zxf  splunk-8.0.2.1-f002026bad55-Linux-x86_64.tgz
cd splunk
rm -rf etc
aws s3 cp s3://mesos-development/splunk/splunkbak.tgz .
tar xf splunkbak.tgz

chown -R ubuntu:ubuntu /home/ubuntu/apps/

runuser -l ubuntu -c "/home/ubuntu/apps/splunk/bin/splunk start --accept-license --no-prompt --answer-yes"