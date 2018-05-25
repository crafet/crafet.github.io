---
title: spark的partition概念
date: 2018-05-25
tags: [spark, partition, rdd]
categories: tech
---

经常使用spark提交任务，但是很少关注partition的概念，虽然经常设置executor的个数，executor_memory，executor-core等值，但是没有关注partition的概念，使用textFile处理文本log也是采用的默认partition设置，今天对partiton的概念稍微理一理。

<!--more-->

一般在yarn cluster mode运行模式先，如果不指定，会有一个default的partition，也就是这个参数

```scala
spark.default.parallelism
```

在不同的运行模型下，default的值不同，比如spark-shell下默认的值为1，在yarn cluster模式下，我们看CoarseGrainedSchedulerBackend.scala中对default值得定义

```scala
  override def defaultParallelism(): Int = {
    conf.getInt("spark.default.parallelism", math.max(totalCoreCount.get(), 2))
  }
```

其中totalCoreCount是接收到executor注册提交到的core的个数的累加。也就是默认的可以使用的所有cores的总和。这个也比较合理，因为每个partition都会产生一个task，task的个数与cores的个数相同，说明所有cores都可以并行所有的task。

而对partition的计算code如下

```scala
  override def getPartitions: Array[Partition] = {
    val jobConf = getJobConf()
    // add the credentials here as this can be called before SparkContext initialized
    SparkHadoopUtil.get.addCredentials(jobConf)
    val allInputSplits = getInputFormat(jobConf).getSplits(jobConf, minPartitions)
    val inputSplits = if (ignoreEmptySplits) {
      allInputSplits.filter(_.getLength > 0)
    } else {
      allInputSplits
    }
    val array = new Array[Partition](inputSplits.size)
    for (i <- 0 until inputSpliths.size) {
      array(i) = new HadoopPartition(id, i, inputSplits(i))
    }
    array
  }
```

partition的个数就是InputSplit的个数，根据InputSplit生成了同数量的partition。也就是说当通过sc.parallelize或者textFile读取数据并指定partition的个数时候，会按照指定的个数生成InputSplit，而partition的个数则是与task对应的，这些task集合会逐步的被调度到executor上进行处理。