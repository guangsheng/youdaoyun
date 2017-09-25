##### Fork 将某个特定仓库复制给自己
##### 设置全集信息
git config --global
比如：
git config --global user.email "enzesheng@foxmail.com"
##### 增加文件或文件夹
git add filename|foldername
##### 提交
git commit -m "Comments"
##### 推送到代码仓库
git push


#### Git基本操作
##### 初始化仓库 git init
进入到对应目录执行，执行完成后会生成 .git 目录，这个目录下存放了git管理相关的文件
##### git status   --查看仓库状态  
##### git add      --向暂存区中提交文件或文件夹 
##### git commit   --保存仓库的历史记录 
##### git log      --查看提交日志 
只显示提交信息第一行 git log --pretty=short

只显示指定目录、文件的日志 git log README.md

显示文件的改动 git log -p README.md

以图形方式显示日志 git log --graph

##### git reflog   --查看当前仓库执行过的所有操作
##### git diff     --查看更改前后的的差别 
查看本次提交和上次提交的差别（即修改了什么） git diff HEAD

#### Git分支相关操作
##### git branch       --显示分支一览表
##### git checkout -b  --创建并切换分支
git checkout -  切回上一个分支
git checkout name  切回指定分支
##### git merge        --合并分支
前提： 先切回到要合入的那个分支

git merge --no-ff 要合并的分支名称

##### git reset --hard    --目标hash值  回溯或推进到指定版本
##### git commit --amend  --修改提交信息
##### git branch -d name  --删除指定分支
