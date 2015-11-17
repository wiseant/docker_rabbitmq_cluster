#!/bin/bash
NODE1=rabbitmq1
NODE2=rabbitmq2
NODE3=rabbitmq3
ERLANG_COOKIE='YZSDHWMFSMKEMBDHSGGZ'
DNS_NAME=localdomain

echo "Launching dns resolver"
docker run -d --name dns -v /var/run/docker.sock:/docker.sock phensley/docker-dns --domain $DNS_NAME
sleep 3

echo "Launching nodes"
function launch_node {
	NODE=$1
	AMQP_PORT=$2
	MGMT_PORT=$3
	HOST=${NODE}-host
	docker run -d \
        	--name=$NODE \
        	-p $AMQP_PORT:5672 \
        	-p $MGMT_PORT:15672 \
        	-e RABBITMQ_NODENAME=$NODE \
			-e RABBITMQ_ERLANG_COOKIE=$ERLANG_COOKIE \
        	-h ${NODE}.$DNS_NAME \
        	--dns $(docker inspect -f '{{.NetworkSettings.IPAddress}}' dns) \
        	--dns-search $DNS_NAME \
		rabbitmq:3.5-management
}

launch_node $NODE1 5672 15672
launch_node $NODE2 5673 15673
launch_node $NODE3 5674 15674

echo "Sleeping to allow time for initialisation"
sleep 3

echo "Clustering containers"
docker exec $NODE2 bash -c \
	"rabbitmqctl stop_app && \
	rabbitmqctl join_cluster $NODE1@$NODE1 && \
	rabbitmqctl start_app" &
docker exec $NODE3 bash -c \
	"rabbitmqctl stop_app && \
	rabbitmqctl join_cluster --ram $NODE1@$NODE1 && \
	rabbitmqctl start_app" &

wait

echo "Setting cluster to High Availability"
docker exec $NODE1 rabbitmqctl set_policy HA '^(?!amq\.).*' '{"ha-mode": "all"}'

echo
echo "Finished, cluster running!!!"
echo
echo "RabbitMQ Management Console - localhost:15672"
