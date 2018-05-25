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

这里定义了两个隐含层，因此完整的网络结构定义如下

```pytho
X = tf.placeholder([None,num_input])
Y = tf.placehoder([num_classes])
def whole_network(x):
	layer1 = tf.matmul(x, weights["h1"] + baises["h1"]
	layer2 = tf.matmul(layer1, weights["h2"]) +b aises["h2"
	out = tf.matmul(layer2, weights["out"]) + baises["out"]
	return out
```

这里定义的layer1，layer2都是隐含层，out为最后的输出层。这里我们直接将matmul

的结果（是一个tensor） + 另外一个tensor；目前来看，也可以用tf.add(tensor1, tensor2)来完成相加，两者的结果应该是一样。函数whole_network以x为输入，从x开始构建隐含层，构建输出层。

接下来定义pred以及loss

```python

logits = whole_network(X)
pred = tf.nn.softmax(logits)
loss_op = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(logits=logtis, labels=Y))

optimizer = tf.train.AdamOptimizer(learning_rate=learing_rate)
train_op = optimizer.minimize(loss_op)
```

logits代表整个network，而pred则是对logits取softmax，这种情况下loss函数与上一篇中提及的loss方式有些不同，这里使用了softmax_cross_entropy_with_logits(logits,labels)，上篇中使用的loss计算方式是

```python
loss = tf.reduce_sum(-tf.reduce_sum(y * tf.log(pred), 1))
```

其实两者的计算结果是一样的，实验如下

```python
logits = tf.constant([[1.0, 2.0, 3.0], [1.0,2.0, 3.0],[1.0, 2.0, 3.0]])
## logtis是一个3*3的matrix, softmax后y也是[3,3]
y = tf.nn.softmax(logits)
y_ = tf.constant([[0.0, 0.0, 1.0],[0.0, 0.0, 1.0],[0.0, 0.0, 1.0]])
## y_ 是实际的label，[3,3],cross_entropy dim: [3,1]
cross_entropy = -tf.reduce_sum(y_ * tf.log(y), 1)

## 上面的1指定按照每行来聚合, pre_cross dim:(3,)
pre_cross = tf.nn.softmax_cross_entropy_with_logits(logits=logits, labels=y_)
## 目前为止pre_cross和cross_entropy是一样的tensor，也就是softmax_cross_entropy_with_logits
## 降维了，从3*3到3*1，而cross_entropy则是需要自己来reduce在axis=1的维度上进行降维。
cross_entropy2 = tf.reduce_sum(pre_cross)
with tf.Session() as sess:
    softmax = sess.run(y)
    c_e = sess.run(cross_entropy)
    c_e2 = sess.run(cross_entropy2)
    print c_e, c_e2
```



注意的是，tf.nn.softmax_cross_entropy_with_logits(labels, logits)这个函数返回一个向量，即dim=1的tensor，首先计算softmax，保持shape不变，然后计算交叉熵，这一步\sigma(y_*log(pred))，降维到向量。

相当于tf.reduce_sum(tensor，1)，对每个instance进行聚合了。