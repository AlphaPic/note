### 创建过程
当kafka启动时，创建临时节点，并将其注册到zk的/broker/ids的目录下面，组件可以通过监听这个目录来查看当前kafka集群的broker的上下线信息
关闭的broker会依然存在于topic的副本之中，当新的相同id的broker启动之后，这个broker会立刻加入kafka集群
控制器是负责topic的分区选举的特殊broker，一般来说是集群中第一个启动的节点，当这个节点失去连接时，那么其它的broker会竞争创建一个新的broker目录，第一个创建的会成为新的控制器
控制器使用epoch来避免脑裂(不理解)
首领的任务：1、为了保证数据的一致性，所有的消费者和生产者都必须经过这个节点 2、搞清楚哪个跟随者和自己的状态保持一致
首选首领和当前首领的区别
ack为0、1和all的区别，0-消息发送出去即可，不需要保证到达(最多一次)，1-消息需要leader的确认，all-消息需要分区的所有副本都确认，在确认之前会放在一个叫炼狱的缓冲区里面
kafka避免数据不一致，需要等
kafka的组用户的消费偏移量被存放在特定的主题上，原先是放在zookeeper上的
为什么支持日志压缩和长时间保存数据这两个特性之间有因果关系，除了压缩回导致日志所占的空间变小之外，我找不到有什么关联
压缩过后的消息可以批量发送而不是一条一条的发送，那这个和设置消息大小的参数有什么关系呢

对于分区的追随者而言，当其满足下面几个条件的时候会被认为是和首领是同步的
1、在最近的6s内和zk发生过心跳行为
2、在最近10s内和从首领那里获取到消息
3、在最近的10s内从首领那里获取过最新的消息，并且几乎是零延迟的

可用性和一致性不能同时满足
unclean.leader.election.enable-允许进行不完全的选举，这个的意思是当首领节点不可用时，我们这边允许其它可用的跟随节点在消息没有完全接收的情况下进行节点选举，一般会在流分析系统里面会采用这个参数
kafaka对可靠性的保证的定义：消息必须被分区的所有的节点确认
min.insync.replicas=2(最小同步副本，当副本的个数为2时，才允许往分区中写入消息，但是这时候消息依然是可以读取的)
同一个group.id的消费者只能看到整个消息的子集，如果要看到topic的所有消息，那么需要给这个消费者设置一个特殊的group
auto.offset.reset指定了没有偏移量可以提交时或者请求的偏移量不在请求的broker上时，consumer会做些什么，当这个值是earlist时，会从当前的broker的开始时开始读取，当这个值是latest时，会从消息的末尾开始读取
enable.auto.commit允许消费自动提交消息
auto.commit.interval.ms自动提交的频度，单位是毫秒

kafka的connector连接的是数据源和kafka的集群吗?是的，是将数据文件从文件系统搬移到kafka(使用FileStreamSource)，或者将文件从kafka搬移到文件系统(使用FileStreamSink)

FileStreamSource的使用
```
echo '{"name":"load-kafka-config-1","config":{"connector.class":"FileStreamSource","file":"config/server-1.properties","topic":"kafka-config-topic"}}' | curl -X POST -d @- http://localhost:8083/connectors --header "content-Type:application/json"
```
FileStreamSink的使用
```
echo '{"name":"dump-kafka-config","config":{"connector.class":"FileStreamSink","file":"copy-of-server-1-properties","topics":"kafka-config-topic"}}' | curl -X POST -d @- http://localhost:8083/connectors --header "content-Type:application/json"
```

connect原理
连接器和任务
连接器
 1、决定运行多少任务
 2、按照任务来拆分数据复制
 3、从worker获取任务配置并传递下去
任务
 1、负责将数据移入或者移除kafka
worker进程
 1、负责REST API、配置管理、可靠性、高可用性、伸缩性和负载均衡
转换器和connect的数据模型
转换器将源数据封装成由Schema构成的Struct，然后将这些数据发送到kafka上，到目标系统的操作正好相反
偏移量管理
worker还可以进行偏移量管理
