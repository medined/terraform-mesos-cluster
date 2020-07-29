#! /bin/bash

export AWS_DEFAULT_REGION=${default_region}

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
PUBLIC_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)


mkdir -p /home/ec2-user/apps/ && cd $_

yum -y install gcc-c++ patch readline readline-devel zlib zlib-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison sqlite-devel

runuser -l ec2-user -c "curl -sSL https://get.rvm.io | bash"
runuser -l ec2-user -c "source ~/.profile"
runuser -l ec2-user -c "rvm reload"
runuser -l ec2-user -c "rvm install 2.5"

runuser -l ec2-user -c "mkdir fluentd && cd $_"

aws s3 cp s3://mesos-development/fluentd/ruby/Gemfile /home/ec2-user/apps/fluentd/Gemfile
runuser -l ec2-user -c "bundle install"

aws s3 cp s3://mesos-development/fluentd/conf/fluent.conf /home/ec2-user/apps/fluentd/fluent.conf

echo "alias start-fluentd='fluentd -c /home/ec2-user/apps/fluentd/fluent.conf 2>&1 &'" >> /home/ec2-user/.profile


chown -R ec2-user:ec2-user /home/ec2-user/apps/

runuser -l ec2-user -c "fluentd -c /home/ec2-user/apps/fluentd/fluent.conf 2>&1 &"