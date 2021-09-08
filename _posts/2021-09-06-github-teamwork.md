---
layout: post
title: GitHub 协同工作
tags: [git, github]
categories: [teamwork]
---

`Git`与`GitHub`基本上是现代软件开发的标准工具与模式，是每个开发者都需要掌握的，尤其是在一个较大的团队中协同工作的时候，熟练地使用好它们，能使得我们的开发工作更加高效，可控。另外，掌握它们，我们就可以更自然地参与到一些自己感兴趣开源项目，融入开源世界。

<!-- more -->
* TOC
{:toc}

## Git

`Git`是一款免费、开源的分布式版本控制系统。

### Git学习资源

关于`Git`介绍，安装，原理等，这里不做过多介绍，初学者可以结合下面的资源来了解:

- [Pro Git](https://git-scm.com/book)
- [Learn Git Branching](https://pcottle.github.io/learnGitBranching)

### Git命令备忘录

#### 1. 配置操作

```shell
# 全局配置(~.gitconfig)
# 列出当前Git的全局配置
$ git config --global -l

# 设置全局提交用户信息
$ git config --global user.name "Jin Tang Cheng"
$ git config --global user.email "jtcheng@cn.ibm.com"

# 设置全局pull rebase (git pull <==> git pull --rebase)
git config --global pull.rebase true

# 仓库级别的配置(repo/.git/config)不指定--global选项
# 给仓库git@github.com:jtcheng/bing-wallpaper.git设定特定的用户email
# ~/work/workspaces/rust/bing-wallpaper
$ git config user.email "jtcheng@cqu.edu.cn"
```

#### 2. 新建仓库操作

```shell
# 在当前目录新建一个Git仓库
$ git init

# 新建一个目录，将其初始化为Git仓库
$ git init repo-name

# 克隆一个已经存在的Git仓库
$ git clone url
```

#### 3. 分支操作

```shell
# 列出本地分支(-r: 远程分支, -a: 所有分支)
$ git branch [-r | -a]

# 新建一个分支，但依然停留在当前分支
$ git branch branch-name

# 切换到已存在的指定分支，并更新工作区
$ git checkout branch-name

# 新建一个分支，并切换到该分支
$ git checkout -b branch-name

# 建立追踪关系，在现有分支与指定的远程分支之间
$ git branch --set-upstream branch-name remote-branch-name

# 切换到上一个分支，类似cd -
$ git checkout -

# 合并指定分支到当前分支
$ git merge branch-name

# 基于指定分支rebase当前分支
$ git rebase branch-name

# 选择一个commit，合并进当前分支
$ git cherry-pick commit

# 选择一个stash，应用到进当前分支
$ git stash apply stashid

# 删除本地分支
$ git branch -d branch-name

# 删除远程分支
$ git push origin -d branch-name
```

#### 4. 文件操作

```shell
# 增加文件
# 添加当前目录下所有文件到暂存区，包括子目录
$ git add .

# 添加指定目录下所有文件到暂存区，包括子目录
$ git add dir

# 添加指定文件到暂存区
$ git add file1 [file2 ...]

# 删除文件
# 删除工作区文件，并且将这次删除效果放入暂存区
$ git rm file1 [file2 ...]

# 停止追踪指定文件，但该文件会保留在工作区
$ git rm --cached filename

# 重命名文件
# 改名文件，并且将这个改名效果放入暂存区
$ git mv src dist

# 查看文件改动
# 显示有变更的文件
$ git status

# 显示工作区和暂存区的差异(--cached: 暂存区与上一个commit的差异)
$ git diff [--cached]

# 显示commit历史(--stat: 显示每次commit发生变更的文件)
$ git log [--stat]

# 显示某次提交的元数据和内容变化(:filename: 指定查看特定文件)
$ git show commit[:filename]

# 显示指定文件是什么人在什么时间修改过
$ git blame filename
```

#### 5. 撤销与暂存操作

```shell
# 恢复暂存区的所有文件到工作区
$ git checkout -- .

# 恢复暂存区的指定文件到工作区
$ git checkout -- filename

# 重置当前分支的HEAD为指定commit，同时重置暂存区(--soft: 工作区不变，--hard: 重置工作区)
$ git reset [--soft | --hard] commit

# 新建一个commit，用来撤销指定commit
$ git revert commit

# 暂时将未提交的变化暂存，稍后再移入
$ git stash [push -m "message"]

# 列出所有的暂存
$ git stash list

# 应用一个stash到当前分支(apply: 应用stash并且保留stash, pop: 应用stash然后删除stash)
$ git stash [apply | pop] stashid

# 删除所有的暂存
$ git stash clear

# 删除指定的暂存
$ git stash drop stashid

# 最后的救命稻草
git fsck --lost-found
```

#### 6. 本地提交操作

```shell
# 提交暂存区到本地仓库区
$ git commit -m message

# 提交暂存区的指定文件到本地仓库区
$ git commit file1 [file2 ...] -m message

# 修改上一次的提交内容信息
$ git commit --amend -m message
$ git commit --amend file1 [file2 ...]
```

#### 7. 远程同步操作

```shell
# 显示所有远程仓库
$ git remote -v

# 下载远程仓库的更新
$ git fetch [remote] [branch]

# 下载远程仓库的更新，并与本地分支合并
$ git pull [remote] [branch]

# 上传本地指定分支到远程仓库(-f: 解决冲突)
$ git push [-f] [remote] [branch]
```

#### 8. 标签操作

```shell
# 列出所有tag
$ git tag -l

# 新建一个tag(commit: 指定commit, 否则就是当前commit)
$ git tag tag-name [commit]

# 提交指定tag
$ git push [remote] tag-name

# 删除本地tag
$ git tag -d tag-name

# 删除远程tag
git push -d origin tag-name
```

#### 9. 发布操作

```shell
# 列出支持的发布格式
$ git archive -l

# 打包发布main分支
git archive --output "v1.0.tar.gz" main
```

## GitHub
`Github`是用`Git`做版本控制的代码托管平台，一般协同开发都是围绕`GitHub`来进行的。

### 企业内部项目开发

企业内部的项目开发，一般都是使用私有`GitHub`站点与账号，代码仓库对于内部开发者来说一般都是有写入权限的，因此我们不需要`fork`项目到自己的账号下面。

具体的步骤如下: (举一个例子)

A. `Git`本地操作

```shell
$ git clone git@github.ibm.com:platformcomputing/paragon.git
$ cd paragon

# 创建功能开发分支
$ git checkout -b feat/feature_name

# 开发部分功能1
$ git add .
$ git commit -m "part1"

# 开发部分功能2
$ git add .
$ git commit -m "part2"

# 拉取主开发分支最新代码
$ git fetch origin main

# 基于主分支来rebase当前的功能开发分支
$ git rebase origin/main

# push功能开发分支到远程主仓库
git push origin feat/feature_name

```

B. `GitHub`站点操作: (有些操作是需要反复进行的)
  1. 发起合并请求
  2. 发起代码评审
  3. 修改代码评审意见，重新push工作分支
  4. 合并工作分支到主开发分支 (选择`squash and merge`)
  5. 删除工作分支

### 开源项目开发

参与企业外部的开源项目开发，代码仓库对于外部开发者来说一般都是没写入权限的，因此我们需要`fork`项目到自己的账号下面，账号需要事先在`GitHub`上面创建。

具体的步骤如下: (举一个例子)

A. 在[tdengine](https://github.com/taosdata/TDengine)的`GitHub`主页上面`fork`该项目到自己的账号下面

B. `Git`本地操作

```shell
$ git clone git@github.com:jtcheng/TDengine.git
$ cd TDengine

# 添加上游主分支
$ git remote add upstream git@github.com:taosdata/TDengine.git

# 由于没有写访问权限，请勿推送至上游主分支
$ git remote set-url --push upstream no_push

# 检查结果如下
$ git remote -v
# origin	git@github.com:jtcheng/TDengine.git (fetch)
# origin	git@github.com:jtcheng/TDengine.git (push)
# upstream	git@github.com:taosdata/TDengine.git (fetch)
# upstream	no_push (push)

# 设置一些开发者信息(覆盖全局设置)
$ git config user.email "jtcheng@cqu.edu.cn"

# 创建bugfix分支
$ git checkout -b bugfix/issue

# 修复部分功能1
$ git add .
$ git commit -m "part1"

# 修复部分功能2
$ git add .
$ git commit -m "part2"

# 拉取主开发分支最新代码
$ git fetch upstream develop

# 基于主分支来rebase当前的bugfix开发分支
$ git rebase upstream/develop

# push bugfix分支到自己的远程主仓库
git push origin bugfix/issue
```

C. `GitHub`站点操作: (有些操作是需要反复进行的)
  1. 发起合并请求
  2. 发起代码评审 (可能没有操作权限)
  3. 修改代码评审意见，重新push工作分支
  4. 合并工作分支到主开发分支 (选择`squash and merge`，可能没有操作权限)
  5. 删除工作分支
