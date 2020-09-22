FROM ubuntu:16.04

# Using 18.04 or 20.04 does not work. The mesos package can't be found.

# Install dependancies
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install gnupg
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN apt-get -y install curl python-setuptools python-pip python-dev python-protobuf
RUN DISTRO=ubuntu; CODENAME=xenial; echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | tee /etc/apt/sources.list.d/mesosphere.list

# Installing zookeeper.  Seems to be a dependancy to mesos
# Not going to start it on runtime though
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install zookeeperd wget apt-transport-https
RUN echo 1 | dd of=/var/lib/zookeeper/myid

# Install mesos.
RUN apt-get -y install mesos
RUN mkdir -p /etc/mesos-master
RUN echo in_memory | dd of=/etc/mesos-master/registry

RUN wget -qO- https://get.docker.io/gpg | apt-key add -
RUN sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
RUN apt-get -y update
RUN curl -sSL https://get.docker.com/ | sh

# Not exposing port b/c you have to run the master in bridge net mode
#EXPOSE 5050

ENTRYPOINT ["mesos-master"]