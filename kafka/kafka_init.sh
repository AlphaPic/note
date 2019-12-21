#!/usr/bin/env bash
#!/bin/bash
# 0.配置
#根目录
ROOT_DIR=/Users/alpha/work/soft
# zk目录
ZK_DIR=${ROOT_DIR}/zookeeper/zookeeper-3.4.13
# kafka启动的目录
KAFKA_DIR=${ROOT_DIR}/kafka/kafka_2.12-2.3.0
# broker数量
KAFKA_BROKER_NUM=$2
# kafka的日志路径
KAFKA_LOG_DIR=${KAFKA_DIR}/logs
#1.启动zookeeper
case $1 in
	start)
		#启动zookeeper
		echo -n "[init] start zk."
		$ZK_DIR/bin/zkServer.sh  start
		#启动kafka
		if [ "x$KAFKA_BROKER_NUM" == "x" ]
		then
			echo -n "尚未选择要部署的机器数量,数量范围是(1~4)"
			exit 0
		fi
		if [ $KAFKA_BROKER_NUM -gt 4 ] || [ $KAFKA_BROKER_NUM -lt 1  ]
		then
			echo -n "broker数量不能超过4台或者小于1台"
			exit 1
		fi
		for((i=1;i<=$KAFKA_BROKER_NUM;i++))
		do
			echo  "正在部署server-${i}..."
			if [ ! -f "$KAFKA_LOG_DIR/kafka-${i}.log" ] 
			then
				touch "$KAFKA_LOG_DIR/kafka-${i}.log"
			fi
			$KAFKA_DIR/bin/kafka-server-start.sh $KAFKA_DIR/config/server-${i}.properties > $KAFKA_LOG_DIR/kafka-${i}.log &
		done
		;;
	stop)
		# 先关闭kafka
		for((i=1;i<=$KAFKA_BROKER_NUM;i++))
		do
			echo "正在关闭broker-${i}..."
			$KAFKA_DIR/bin/kafka-server-stop.sh
		done	
		# 再关闭zookeeper
		$ZK_DIR/bin/zkServer.sh stop
		;;
	*)
		echo "ki -start "启动broker""
		echo "ki -stop "关闭broker""
		;;
esac
