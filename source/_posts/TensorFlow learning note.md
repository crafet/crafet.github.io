---
title: tensorflow tutorial-1
date: 2018-05-17
tags: tech
categories: [tensorflow, tutorial, machine learning]
---

背景

在搜索tensorflow(TF)相关的资料时候，发现在github上有比较多的example，其实在学习其他新内容，总是会有类似effectiveC++，efftiveGo，effectiveScala等类似总结，尝试搜了下effectiveTensorflow，发现这里还是有一个可以参考

[tf的effective](https://github.com/crafet/EffectiveTensorflow)

同时还有一个star较高的examples作为学习的tutorial，地址在这里

[Tensorflow Examples](https://github.com/aymericdamien/TensorFlow-Examples)

本文打算从example这里开始，打算以此作为基础，先将tf相关的所有api尽可能熟悉，然后基于effective系列来了解常规的code style，最后再深入tf的基础架构、设计原理去深层次的了解。

<!--more-->

开始之前，先看下两种编程模式的对比：符号编程以及命令式编程，即symbol style以及imperative style。符号式编程一般是将变量定义在一个计算图上，这个计算图指定了输入到输出的闭路，在计算图上指定变量之间的关系，此时对计算图进行编译输出的话，是没有任何输出的，仅仅当**需要运算的输入**放入后，才会在模型中形成数据流，形成输出。

```python
import tensorflow as tf
d = tf.add(1,2)
print d
## show this content
#Tensor("Add:0", shape=(), dtype=int32)
```

这里可以看到的d还是一个Tensor，并不会输出最终的结果。

```python
a = tf.constant(1, name="input1")
b = tf.constant(2, name= "input2")
f = tf.add(a, b)
```

这里的tf.constant是一个Operation，简称Op，每个Op都以tensor作为参数，这里会将标量1,2转成tensor作为constant的输入。

这个时候通过print tf.get_default_graph().as_graph_def()查看计算图，可以看到

```protobuf

node {
  name: "Const"
  op: "Const"
  attr {
    key: "dtype"
    value {
      type: DT_INT32
    }
  }
  attr {
    key: "value"
    value {
      tensor {
        dtype: DT_INT32
        tensor_shape {
        }
        int_val: 1
      }
    }
  }
}
node {
  name: "Const_1"
  op: "Const"
  attr {
    key: "dtype"
    value {
      type: DT_INT32
    }
  }
  attr {
    key: "value"
    value {
      tensor {
        dtype: DT_INT32
        tensor_shape {
        }
        int_val: 2
      }
    }
  }
}
node {
  name: "Add"
  op: "Add"
  input: "Const"
  input: "Const_1"
  attr {
    key: "T"
    value {
      type: DT_INT32
    }
  }
}
versions {
  producer: 24
}
```

这里可以看到打印出来pb形式的计算图，显示了3个node，都是Op，计算图内部做了名称表达，如Const，Const_1，Add类似的名字；其中Const两个Op，还有attr属性，定义了了具体value的属性，如Key:"Value"表示Op接收的参数是tensor，类型是DT_UINT32，tensor_shape为空，应该默认是1维的，说明tf.constant将标量1,2转变成了tensor；最后看下Add这个op，从图的pb来看，没有value相关的attr，但是有多个input字段，都是Add这个Op的输入。

接下来，当我们定义一个Variable，再次show出graph，会看到如下内容

```protobuf
node {
  name: "var1/initial_value"
  op: "Const"
  attr {
    key: "dtype"
    value {
      type: DT_INT32
    }
  }
  attr {
    key: "value"
    value {
      tensor {
        dtype: DT_INT32
        tensor_shape {
        }
        int_val: 1
      }
    }
  }
}
node {
  name: "var1"
  op: "VariableV2"
  attr {
    key: "container"
    value {
      s: ""
    }
  }
  attr {
    key: "dtype"
    value {
      type: DT_INT32
    }
  }
  attr {
    key: "shape"
    value {
      shape {
      }
    }
  }
  attr {
    key: "shared_name"
    value {
      s: ""
    }
  }
}
node {
  name: "var1/Assign"
  op: "Assign"
  input: "var1"
  input: "var1/initial_value"
  attr {
    key: "T"
    value {
      type: DT_INT32
    }
  }
  attr {
    key: "_class"
    value {
      list {
        s: "loc:@var1"
      }
    }
  }
  attr {
    key: "use_locking"
    value {
      b: true
    }
  }
  attr {
    key: "validate_shape"
    value {
      b: true
    }
  }
}
node {
  name: "var1/read"
  op: "Identity"
  input: "var1"
  attr {
    key: "T"
    value {
      type: DT_INT32
    }
  }
  attr {
    key: "_class"
    value {
      list {
        s: "loc:@var1"
      }
    }
  }
}
versions {
  producer: 24
}
```

可以看到，仅仅增加一个Variable，就增加了很多Op，包括Assign、Identity，VariableV2等Op node。这里面的原理目前还不可知，等待后续对原理深究再说，这里先不表。

tf提供一种eager lib，基于此可以实现impreative style的编程形式。相对于eager style，可以明显感受，构建计算图最终通过session来run的形式比较简单，在run之前只需要关注计算图本身的构建过程。

tf.reduce_sum(a，axis) ，如果不指定按照axis，那么就是全部相加起来得到一个值得tensor。axis则是指定按照哪个维度进行reduce，如果axis=0，那么按列来reduce；如果axis=1则按照行来reduce 如

```python
a = tf.constant([[1,1,1],[3,4,5]])
b = tf.reduce_sum(a, 0)
c = tf.reduce_sum(a,1)
d = tf.reduce_sum(a, -1)
e = tf.reduce_sum(a)
```

此时的b为[4,5,6],c和d是一样的，都是按照行来reduce，得到[3,12]，可以看到维度降低到2了。reduce实现了降维。而e则是[15]，不指定axis的话，则将所有元素按照sum进行reduce，得到一个值得tensor。

复现mnist的例子

```python
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data

mnist = input_data.read_data_sets("./data", one_hot = True)
print "example count:", mnist.train.num_examples
learning_rate = .1
training_epochs = 30
batch_size = 100
display_step = 1

x = tf.placeholder(tf.float32, [None, 784])
y = tf.placeholder(tf.float32, [None, 10])

W = tf.Variable(tf.zeros([784,10]))
b = tf.Variable(tf.zeros([10]))

pred = tf.n.softmax(tf.matmul(x, W) + b)
## cost 定义，按照行来reduce计算一个instance的loss，然后全部聚合
cost = tf.reduce_mean(-tf.reduce_sum(y *tf.log(pred), 1))

optimizer = tf.reduce_mean(-tf.reduce_sum(y*tf.log(pref), 1))

init = tf.global_variables_initializer()
print "init:", init

with tf.Session() as sess:
        sess.run(init)
        for epoch in xrange(training_epochs):
                avg_cost = 0.0
                total_batch = int(mnist.train.num_examples/batch_size)
                for i in range(total_batch):
                        batch_x, batch_y = mnist.train.next_batch(batch_size)
                        #print "batch_x", sess.run(tf.reduce_sum(batch_x)), "batch_y",batch_y
                        _, c = sess.run([optimizer, cost], feed_dict= {x:batch_x, y:batch_y})
                        #print "c:", c
                        avg_cost += c/total_batch

                        ##sys.exit(1)
                if epoch % display_step == 0:
                        print "epoch:" '%04d'%(epoch), "cost=", "%.9f"%(avg_cost)
        print "optimization done"

        ### argmax return the max value index by axis=1
        corrent_equal = tf.equal(tf.argmax(pred, 1), tf.argmax(y, 1))

        ### reduce_mean not config axis ,means reduce all elements of matrix
        accuracy = tf.reduce_mean(tf.cast(corrent_equal, tf.float32))
        print "Accuracy:", accuracy.eval({x: mnist.test.images[:3000], y: mnist.test.labels[:3000]})


```

在sess run之前都是在构建计算图，这里重点解释几点

1 首先使用tf.nn模块中softmax来进行多分类；cost的计算方式是batch的loss进行相加并取平均

一个image的loss计算方式是

```python
one_loss = tf_reduce_sum(-y*tf.log(pred),1), y与pred都是tensor，所以需要设置axis=1，表示在行上进行reduce，也就是一个image的所有列上的计算结果汇聚成一个tensor:[loss1, loss2, loss3],然后将结果再进行一次reduce_mean，就获取本次batch上的所有image的loss的均值了。
 
不得不说，tf的计算图形式虽然抽象，然后开发起来简单的多了，但是，同时我们对数据的理解从数值迁移到tensor上了，这也就说明一个reduce函数，总是要说明在哪个维度进行reduce，其他api也是如此。
   
```

函数tf.argmax与tf.arg_max用法相同，建议用前者，后者即将deprecated。同理，tf.argmin与tf.arg_min是一样的道理。