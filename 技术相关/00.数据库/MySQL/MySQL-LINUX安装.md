##### 采用安装包方式安装

##### 安装版本下载路径
http://dev.mysql.com/downloads/mysql/5.7.html#downloads

需要用oracle账户下载

注册邮箱
enzesheng@foxmail.com  密码同 shiguangsheng@huawei.com

##### 安装过程
dpkg -i mysql-common_8.0.0-dmr-1ubuntu16.04_i386.deb
dpkg -i libmysqlclient21_8.0.0-dmr-1ubuntu16.04_i386.deb
dpkg -i libmysqlclient-dev_8.0.0-dmr-1ubuntu16.04_i386.deb
dpkg -i libmysqld-dev_8.0.0-dmr-1ubuntu16.04_i386.deb
dpkg -i mysql-client_8.0.0-dmr-1ubuntu16.04_i386.deb
dpkg -i mysql-community-client_8.0.0-dmr-1ubuntu16.04_i386.deb
apt-get install libaio1
apt-get install libmecab2
dpkg -i mysql-community-server_8.0.0-dmr-1ubuntu16.04_i386.deb
dpkg -i mysql-server_8.0.0-dmr-1ubuntu16.04_i386.deb

###### 下面这几个包没有安装
mysql-community-source_8.0.0-dmr-1ubuntu16.04_i386.deb
mysql-community-test_8.0.0-dmr-1ubuntu16.04_i386.deb
mysql-testsuite_8.0.0-dmr-1ubuntu16.04_i386.deb


##### 初始化数据库
参数查看 mysqld --version --help
数据目录默认位置 /var/lib/mysql

##### 安装后用户密码等信息
root huawei

##### mysql交互式客户端登陆方式
mysql -uroot -p
mysql -uroot -p -Dtest

查看当前状态 status


##### 数据库级别相关操作
创建数据库  create database test;

查看当前数据库  select database();

连接到某一数据库 connect test


##### mysql客户的直接查询后返回
mysql -uroot -phuawei -e"show databases"

##### mysql关闭停止  root用户下执行
/etc/init.d/mysql start
/etc/init.d/mysql stop

/etc/init.d/mysql 是个脚本，拉起的mysql进程是运行在mysql用户下的