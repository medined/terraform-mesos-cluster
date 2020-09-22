# Marathon In Docker

## References 

* https://www.jasonacox.com/wordpress/archives/243 (2016)

## Run Marathon In Docker

* Create alias to stop all docker containers. Good while experimenting.

```bash
alias dstop="docker ps -a -q | xargs docker stop | xargs docker rm"
```

* Define a docker network name.

```bash
DOCKER_NETWORK=mesos
```

```bash
docker network create --subnet=10.18.0.0/16 $DOCKER_NETWORK
```

* Set environment variable to hold host IP addresses.

```
MESOS_HOST=10.18.0.10
ZK_HOST=10.18.0.11
MARATHON_HOST=10.18.0.12
AGENT1_HOST=10.18.0.13
```

* Build and start Zookeeper

```bash
cd zookeeper

docker build -t zookeeper .

docker run \
  --name zookeeper \
  --net $DOCKER_NETWORK \
  --ip $ZK_HOST \
  -p 2181:2181 \
  -p 2888:2888 \
  -p 3888:3888 \
  -d \
  zookeeper

cd ..
```

* Start Mesos controller

```bash
cd mesos-controller

docker build -t mesos-controller .

export ZK_HOST=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' zookeeper)

docker run \
  --name mesos-controller \
  --net $DOCKER_NETWORK \
  --ip $MESOS_HOST \
  -p 5050:5050 \
  -e "MESOS_HOSTNAME=$MESOS_HOST" \
  -e "MESOS_IP=$MESOS_HOST" \
  -e "MESOS_ZK=zk://$ZK_HOST:2181/mesos" \
  -e "MESOS_PORT=5050" \
  -e "MESOS_LOG_DIR=/var/log/mesos" \
  -e "MESOS_QUORUM=1" \
  -e "MESOS_REGISTRY=in_memory" \
  -e "MESOS_WORK_DIR=/var/lib/mesos" \
  -d \
  mesos-controller

cd ..
```

* Start Marathon

```bash
cd marathon

docker build -t marathon .

docker run \
  --name marathon \
  --net $DOCKER_NETWORK \
  --ip $MARATHON_HOST \
  -p 8080:8080 \
  -d \
  marathon \
    --master zk://${ZK_HOST}:2181/mesos \
    --zk zk://${ZK_HOST}:2181/marathon

cd ..
```

* Start Mesos agent

```bash
cd mesos-agent

docker build -t mesos-agent .

mesos-agent \
  --master=$MESOS_ZK \
  --port=5051 \
  --work_dir=/var/lib/mesos

docker run \
  --name="mesos-agent-1" \
  --net $DOCKER_NETWORK \
  --ip $AGENT1_HOST \
  -it --rm \
  --entrypoint="mesos-agent" \
  -e "MESOS_HOSTNAME=$MESOS_HOST" \
  -e "MESOS_IP=$MESOS_HOST" \
  -e "MESOS_LOG_DIR=/var/log/mesos" \
  -e "MESOS_LOGGING_LEVEL=INFO" \
  -e "MESOS_MASTER=zk://${ZK_HOST}:2181/mesos" \
  -e "MESOS_WORK_DIR=/var/lib/mesos" \
  -e "MESOS_ZK=zk://$ZK_HOST:2181/mesos" \
  mesos-controller  --master=$MESOS_ZK
```

* Visit Mesos home page.

```
xo http://$HOST_IP:5050
```

* Visit Marathon home page.

```
xo http://$HOST_IP:8080
```
