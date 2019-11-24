由于`kafka`的运行需要借助zookeeper，因此这里需要进行先启动zookeeper
```shell
#!/bin/bash
# 0.配置
# zk目录
ZK_DIR=/Users/alan/work/soft/zookeeper/zookeeper-3.4.13
# kafka启动的目录
KAFKA_DIR=
# broker数量
KAFKA_BROKER_NUM=1
#1.启动zookeeper
case $0:
  while
```
