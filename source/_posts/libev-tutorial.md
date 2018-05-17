---
title: 基于libev的网络服务框架
date: 2017-08-18
tags: ["libev", "event"]
categories: "tech"
---



背景

​	目前参与的几个后台服务都是基于libev构建的异步网络服务框架，我们将libev进行了简单的封装形成了Reactor类，并形成了自己稳定的异步服务框架，这里 针对当前网络服务框架进行剖析，以期望未来可以轻松的使用这个框架构建任意的高并发、稳定的后台服务。

<!--more-->

​	libev通过提供几个简单的接口，可以方便设置对fd的read/write等事件进行回调。定义的loop用来循环监控事件，loop可以监听的watcher都通过 ev_TYPE定义的watcher(TYPE可以为io, signal, async, timer等事件)



```c++
// define a new io watcher

ev_io io_watcher;

```



```c++
// bind the watcher with a io callback func
// 将回调函数io_callback_func绑定到io_wathcer
// 当有事件时候，回调这个函数
ev_init(&io_watcher, io_callback_func);

// watcher到具体的某个fd的READ事件
ev_io_set(&io_watcher, fd, EV_READ);

// 将watcher绑定到全局的loop上
ev_io_start(loop, &io_watcher);

// 将loop run起来。
ev_run(loop, 0);
```

上述的ev_init以及ev_io_set可以通过一个函数来实现

```c++
// 这里的callbackfn，fd， READ事件都是用来初始化io_watcher
// 用一个init函数更合理。
ev_io_init(&io_watcher, io_callback_func, fd, EV_READ);

```

上面列出的是常见原生libev接口，我们基于这些接口封装成一个易用的Reactor类

Reactor类的形成

​	为了易用，我们用一个Reactor.h封装了所有的watcher的实现。



-- EOF --