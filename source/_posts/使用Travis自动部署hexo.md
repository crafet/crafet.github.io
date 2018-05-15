---
title 使用travis自动构建blog
---

背景

在使用travis构建blog之前，对travis并没有系统的使用过，也仅仅停留在听过这个产品，听过其用途，随着总结欲望的增加，发现在跨多个机器上写blog的时候，总是需要安装hexo，这些环境通过github来作为中间者进行同步，时间长了，会逐渐忘记hexo的部署命令以及本机的部署环境，写blog的目录等，在往往在随着这些琐碎的事情的增加，而逐渐减少了写blog的欲望。

最近看到travis进行blog的自动构建，发现可以很大程度上减少对部署环境的依赖，而只要聚焦在写blog上即可。因此折腾了一个下午，将travis接入自己的blog构建，本篇文章记录了这个折腾的过程，同时也记录一些自己目前还没有解决掉的问题，期望后面会逐渐优化这个过程。

这里插入一句，一般我们使用git的时候经常会出现git对中文的处理：对0x80开头的字符进行quote，导致经常出现以下的文件展示

```shell
（使用 "git add <文件>..." 以包含要提交的内容）

        "\346\265\213\350\257\225.txt"
```

这里通过设置core.quotepath来正常显示中文

```shell
git config --global core.quotepath false
```

这样就可以正常显示文件，如：

```shell
(use "git checkout -- <file>..." to discard changes in working directory)

        modified:   使用Travis自动部署hexo.md

```



另外看到如果post的markdown文件不是utf8编码，会在blog上显示乱码，因此在使用Typora进行书写或者其他软件进行书写，需要保存为utf8格式文件。



折腾过程

在这之前，我将blog的src文件存放在github上的blogSrc上，作为一个单独的repo存在；而通过hexo g产生的blog静态文件则是放在另外一个repo，通过搜索travis的构建步骤发现，一般倾向于将src文件与产生的静态文件放在同一个repo下，分两个分支而已，因此在github.com/crafet/crafet.github.io这个repo下  建立一个分支称为hexo，将blogSrc repo的数据都迁移到这个分支下，这样就保持了统一，这里也再次熟悉下git branch的用法。

```shell
git clone xxx.git 到本地
在当前路径下
git checkout -b hexo
建立一个本地分支，命名为hexo，checkout -b name的命令形式等价于先建立branch，然后通过checkout切换到新分支，等价于
git branch hexo
git checkout hexo
接下来，git branch -r来查看远程分支信息。
通过git push origin hexo:hexo将本地分支推送到远程分支，这样在github上可以看到有了新的分支。

```

默认情况下，git branch一个新分支出来，这个新分支的内容与原来分支的内容是一样的，也就是hexo中也存放了master的内容。我这里直接删除copy过来的内容，将blogSrc中的内容提交到这个路径下

```shell
git rm * -f 删除
git commit -m"clear branch hexo"
cp ./../blogSrc/* ./
git add *
git commit -m"first add src content"
git push
```

由于我这里使用https的方式clone以及提交内容，因此每次git push都要输入用户名以及密码，为了偷懒，这里通过如下命令将用户名以及密码进行本地缓存

```shell
git config --global credential.helper store
```

这样就只要第一次push的时候需要输入用户名以及密码，后续就不用了。

通过这一步，我们就将hexo源数据以及静态文件都准备好了，通过branch -r来查看到rep上有hexo分支以及master分支。

```shell
git branch -r
  origin/HEAD -> origin/master
  origin/hexo
  origin/master

```

travisCI的部署

travisCI和github有了比较好的继承，通过github账号登陆travis就可以看到自己所有的repo，这里我们选择crafet.github.io这个repo进行自动构建。

![](/images/travis-select-repo.jpg)

在Environment中配置如下的变量

```shell

GitHubKEY = 上文生成的 GitHub Personal Access Token
GitHubEMail = 你绑定在 GitHub 上的邮箱地址
GitHubUser = 你的 GitHub 用户名
GitHubRepo = 静态页面 deploy 的目标仓库名称
```

接下来再hexo这个分支，新建.travis.yml文件，我这里的内容如下

```yaml
language: node_js
dist: trusty
node_js:
  - "7"
install:
  - npm install hexo-cli -g
  - npm install
  
script:
  - chmod +x ./deploy.sh
  - git clone https://github.com/iissnan/hexo-theme-next themes/next 
  - hexo clean
  - hexo g
  - ./deploy.sh > /dev/null

branches:
  only:
    - hexo
cache:
  directories:
    - node_modules
```

其中的branch则指定了使用hexo分支进行构建。

在script下我这里认为添加了git clone theme的命令，因为发现travis环境下通过hexo g产生的publish中总是没有theme，因此这里手动添加了clone这个theme。（这里应该是一个遗留问题）

其中的deploy.sh脚本内容如下：

```shell
cd ./public # Hexo 生成的目录默认在 public 下
git init # 初始化一个 Repo
git config --global push.default matching
git config --global user.email "${GitHubEMail}"
git config --global user.name "${GitHubUser}" # 利用在环境变量中定义的信息配置 Git
cp  ../themes/ ./ -r
git add --all .
git commit -m "Auto Builder of ${GitHubUser}'s Blog" # commit 信息

git push --quiet -f https://${GitHubKEY}@github.com/${GitHubUser}/${GitHubRepo}.git master # 将生成的静态整站部署到指定 Repo 的 master 分支。
```

这里有几点要分别说明

> 1. 其中使用的GitHubUser、GitHubKey这些变量是在travis中设置的。会作为环境变量被export出来。
> 2. 其中在git add --all.之前手动做了一个cp ../themes/ ./ -r的动作，也是一个遗留问题，目的是为了将theme能够在publish中生效。
> 3. 最后使用的git push --quiet -force，这里使用了force选项，是直接将最新的内容完全覆盖掉master上的数据，这里主要考虑不用关注之前master版本，直接进行覆盖，这里也许不是一个好方法。

然后将.travis.yml以及deploy.sh文件一并提交到github。后续在_post路径下增加任何一个新的文件， travis都会自动构建并完成blog的部署。



End.