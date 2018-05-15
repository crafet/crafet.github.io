---
title: 使用travis自动构建hexo blog
---

本文介绍使用travis CI来自动化构建hexo blog的过程。

在使用travis之前，我在笔记本和PC上等多台机器上都安装了hexo，并将blog的内容、theme等都会clone多处，当换个新个工作环境的时候，总是要update下最新的文章，然后再通过hexo generate以及hexo depoly来部署文章。当发现很多blog介绍了travisCI之后，这才发现可以自动化构建自己的blog，而且即使在多台设备上也不用安装hexo的环境，甚至git都不需要，书写好markdown后，直接提交到_post下，让travis来帮忙自动构建blog并部署，本文介绍下挖坑的过程。

