##### ���ð�װ����ʽ��װ

##### ��װ�汾����·��
http://dev.mysql.com/downloads/mysql/5.7.html#downloads

��Ҫ��oracle�˻�����

ע������
enzesheng@foxmail.com  ����ͬ shiguangsheng@huawei.com

##### ��װ����
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

###### �����⼸����û�а�װ
mysql-community-source_8.0.0-dmr-1ubuntu16.04_i386.deb
mysql-community-test_8.0.0-dmr-1ubuntu16.04_i386.deb
mysql-testsuite_8.0.0-dmr-1ubuntu16.04_i386.deb


##### ��ʼ�����ݿ�
�����鿴 mysqld --version --help
����Ŀ¼Ĭ��λ�� /var/lib/mysql

##### ��װ���û��������Ϣ
root huawei

##### mysql����ʽ�ͻ��˵�½��ʽ
mysql -uroot -p
mysql -uroot -p -Dtest

�鿴��ǰ״̬ status


##### ���ݿ⼶����ز���
�������ݿ�  create database test;

�鿴��ǰ���ݿ�  select database();

���ӵ�ĳһ���ݿ� connect test


##### mysql�ͻ���ֱ�Ӳ�ѯ�󷵻�
mysql -uroot -phuawei -e"show databases"

##### mysql�ر�ֹͣ  root�û���ִ��
/etc/init.d/mysql start
/etc/init.d/mysql stop

/etc/init.d/mysql �Ǹ��ű��������mysql������������mysql�û��µ�