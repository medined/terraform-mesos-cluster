FROM ubuntu:14.04


## DEPENDENCIES ##
RUN echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesosphere.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN apt-get -y update \
 && apt-get -y upgrade \
 && apt-get install --assume-yes mesos software-properties-common python-software-properties curl wget

RUN add-apt-repository -y ppa:openjdk-r/ppa \
 && apt-get update \
 && apt-get install -y openjdk-8-jdk \
 && update-java-alternatives -s /usr/lib/jvm/java-1.8.0-openjdk-amd64

## MARATHON ##
ADD https://downloads.mesosphere.io/marathon/builds/1.8.222-86475ddac/marathon-1.8.222-86475ddac.tgz /tmp/marathon.tgz
RUN mkdir -p /opt/marathon && tar xzf /tmp/marathon.tgz -C /opt/marathon --strip=1 && rm -f /tmp/marathon.tgz

EXPOSE 8080
WORKDIR /opt/marathon

ENTRYPOINT ["/opt/marathon/bin/marathon"]
CMD ["--help"]
