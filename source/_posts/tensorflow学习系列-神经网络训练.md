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
num_input = 
n_hidden_1 = 256
n_hidden_2 = 256
h1 = tf.Variable(tf.random_normal([num_input, n_hidden_1]))
```

<!--more-->