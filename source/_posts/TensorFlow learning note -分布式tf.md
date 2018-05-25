---
title: tensorflow tutorial -分布式tf
date: 2018-05-18
tags: [tensorflow, ditributed, model]
categories: tech
---

分布式tf

准备tf.train.ClusterSpec 用来映射task到机器。

当通过tf.train.Server.create_local_server()时候，会返回如图log信息供参考

```shell
>>> server = tf.train.Server.create_local_server() 
2018-05-21 11:06:20.414739: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:0) -> (device: 0, name: Tesla P40, pci bus id: 0000:04:00.0, compute capability: 6.1)
2018-05-21 11:06:20.414780: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1120] Creating TensorFlow device (/device:GPU:1) -> (device: 1, name: Tesla P40, pci bus id: 0000:06:00.0, compute capability: 6.1)
E0521 11:06:20.415751398   12302 ev_epoll1_linux.c:1051]     grpc epoll fd: 38
2018-05-21 11:06:20.420353: I tensorflow/core/distributed_runtime/rpc/grpc_channel.cc:215] Initialize GrpcChannelCache for job local -> {0 -> localhost:52551}
2018-05-21 11:06:20.420940: I tensorflow/core/distributed_runtime/rpc/grpc_server_lib.cc:324] Started server with target: grpc://localhost:52551
```

查看server以及对应的targe信息

```shell
>>> print server.target
grpc://localhost:52551
>>> print server
<tensorflow.python.training.server_lib.Server object at 0x69bc610>
```

data parallelism ,worker has same model with different batch size data

图内复制

in-graph replication



between-graph replication

图间复制



TensorFlowOnSpark

Yahoo!开源的TFoS，集中tf以及spark，tfos支持GPU/CPU集群上的分布式深度学习。

支持spark上的training、支持inference。通过如下步骤管理tf

a、在executor上launch tf，同时监听数据/控制流信息。

b、数据读取方式有两种：Reader和QueueRunner，QueueRunner是 tf提供数据读取接口

leverage tf的reader接口从hdfs上直接读取数据；使用feed_dict机制，将RDD发送到feed_dict上。