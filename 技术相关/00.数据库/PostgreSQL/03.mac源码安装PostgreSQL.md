```
mkdir -p /Users/shiguangsheng/user_program/postgresql

./configure --prefix=/Users/shiguangsheng/user_program/postgresql --enable-debug --without-readline > ../sgs_config.log
make > ../sgs_make.log
make install > ../sgs_make_install.log

cd /Users/shiguangsheng/user_program/postgresql
mkdir data
cd /Users/shiguangsheng/user_program/postgresql/bin
 
 
cd ~/
echo "export PGDATA=/Users/shiguangsheng/user_program/postgresql/data" >> .bash_profile
echo "export PATH=$PATH:/Users/shiguangsheng/user_program/postgresql/bin" >> .bash_profile
echo "export PGDIR=/Users/shiguangsheng/user_program/postgresql/bin" >> .bash_profile
initdb -D /Users/shiguangsheng/user_program/postgresql/data
```

修改配置项后启动数据库