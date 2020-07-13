HOME=$1
USER=$2
echo $HOME
echo $USER

sudo -u $USER sh -c "$HOME/zookeeper/bin/zkServer.sh start"
sleep 2
sudo -u $USER sh -c "$HOME/mesos/build/bin/mesos-master.sh --hostname=localhost --zk=zk://localhost:2181/mesos --quorum=1  --work_dir=/var/lib/mesos >> $HOME/mesos-master.log 2>&1 &"
sleep 5
sudo -u $USER sh -c "$HOME/mesos/build/bin/mesos-agent.sh --master=zk://127.0.0.1:2181/mesos  --work_dir=/var/lib/mesos-agent --systemd_enable_support=false --containerizers=docker --resources=\"ports(*):[80-81, 8000-9000, 31000-32000]\" >> $HOME/mesos-agent.log 2>&1 &"
sleep 2
sudo -u $USER sh -c "MESOS_NATIVE_JAVA_LIBRARY=$HOME/mesos/build/src/.libs/libmesos.so $HOME/marathon/bin/marathon --http_port 8082   --master zk://localhost:2181/mesos --zk zk://localhost:2181/marathon  --hostname localhost   >> $HOME/marathon.log 2>&1 &"

