##### GitHub是在网络上提供Git仓库的一项服务。

##### 设置SSH KEY
ssh-keygen -t rsa -C "enzesheng@foxmai.com"


##### GIT
工作区-暂存区-本地仓库-远程仓库  对应五种状态  未修改-已修改-已暂存-已提交-已推送
git add .  把所有文件放入暂存区  
git commit 从暂存区推到本地仓库  
git push   从本地仓库推到远程仓库  

git diff 查看已修改但未暂存的文件  
git diff --cached 查看已暂存但还没有提交的文件  
git diff master origin/master 查看已提交但还没有推送的文件  

git reset --hard 撤销已修改状态或已暂存状态的文件  
git reset --hard origin/master 撤销已提交但还没有推送的文件  
git reset --hard HEAD^; git push -f  危险动作，撤销已经推送的文件

