ʹ��root�û���¼��������ִ�����²���
```bash
tar -xzvf postgresql-9.1.5.tar.gz
apt-get install zlib1g-dev bison flex ##ubuntuĬ�ϰ�װ�в�����������������Ҫ��װBison,Flex,zlib
cd /opt/
mkdir postgresql
cd /opt/pg_source/postgresql-9.1.5
./configure --prefix=/opt/postgresql --enable-debug --without-readline > ../sgs_config.log
make > ../sgs_make.log
make install > ../sgs_make_install.log
 
adduser postgres
cd /opt/postgresql
mkdir data
chown postgres: data
su - postgres
cd /opt/postgresql/bin/
./initdb -D /opt/postgresql/data
 
 
cd /home/postgres/
echo "export PGDATA=/opt/postgresql/data" >> .profile
echo "export PATH=$PATH:/opt/postgresql/bin" >> .profile
echo "export PGDIR=/opt/postgresql/bin" >> .profile
```