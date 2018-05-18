---
title: tensorflow tutorial -神经网络模型
date: 2018-05-18
tags: [tensorflow, neural network, model]
categories: tech
---

从SimpleNeuralNetwork开始构建多层感知机到CNN再到LSTM，通过代码熟悉tf下DNN的模型构建方式。

构建一个包含2个隐含层hidden layers全连接网络，也即平常说的多层感知机multi layer perceptron，继续使用mnist数据集进行模型训练以及应用。

这里设置2层，每层256个神经节点neurons，输入为784dim的image，output为10 classes。

对于中间的hidden layer，需要的w为

```pytho
num_input = 784
n_hidden_1 = 256
n_hidden_2 = 256
num_classes = 10
weights = {
'h1' : tf.Variable(tf.random_normal([num_input, n_hidden_1]))
'h2' : tf.Variable(tf.random_normal([n_hidden_1, n_hidden_2]))
'out': tf.Variable(tf.random_normal([n_hidden_2, num_classes]))
}
## 同样需要设置bais变量
baises = {
    'h1': tf.Variable(tf.random_normal([n_hidden_1])),
    'h2': tf.Variable(tf.random_normal([n_hidden_2])),
    'out': tf.Variable(tf.random_normal([num_classes]))
}

```

<!--more-->

tf.random_normal(shape, mean=.0, stddev=1.0,dtype=tf.float32,seed=None, name=None)，random_normal默认返回均值为0，方差为1的标准正态分布产生的随机数，tensor的维度以shape给出。

