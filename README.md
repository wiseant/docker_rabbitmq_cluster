# RabbitMQ Docker 集群
> 从jrlangford的[docker_rabbitmq_cluster](https://github.com/jrlangford/docker_rabbitmq_cluster)克隆而来,并做了简单修改.

### 说明
使用DNS的原因是: Docker无法识别RabbitMQ节点,直接修改hosts文件可行但维护麻烦.

### 修改
1. 添加并引用ERLANG_COOKIE变量,从基础镜像rabbitmq中创建相同Cookie的节点.省去单独编译一个镜像作为集群的基础镜像,jrlangford/rabbitmq. 
2. 创建RabbitMQ节点时增加"p $AMQP_PORT:5672 \",用于将amqp协议端口绑定至宿主机,否则无法访问.
3. 将DNS域名提为变量,便于更改为主机喜欢的名称.