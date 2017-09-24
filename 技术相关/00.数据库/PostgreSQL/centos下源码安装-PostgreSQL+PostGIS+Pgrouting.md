### TODO:
1. 各软件编译编译优化的问题

### 一、各软件版本号
PostgreSQL:   9.6.2
PostGIS:   2.3.2
Pgrouting:  2.4.1

### 二、操作系统版本号：CentOS Linux release 7.3.1611 (Core)
https://mirrors.tuna.tsinghua.edu.cn/fedora/updates/24/x86_64/c/

###三、依赖的软件
#### 1. PostgreSQL  
大部分软件都已经默认安装了，下面列出的需要安装的软件都是在安装过程中碰到要求安装的
##### 安装顺序
##### gcc & g++
```bash
rpm -ivh mpfr-3.1.1-4.el7.x86_64.rpm
rpm -ivh libmpc-1.0.1-3.el7.x86_64.rpm
rpm -ivh kernel-headers-3.10.0-514.el7.x86_64.rpm
rpm -ivh glibc-headers-2.17-157.el7.x86_64.rpm
rpm -ivh glibc-devel-2.17-157.el7.x86_64.rpm 
rpm -ivh cpp-4.8.5-11.el7.x86_64.rpm
rpm -ivh gcc-4.8.5-11.el7.x86_64.rpm 
rpm -ivh libstdc++-4.8.5-11.el7.x86_64.rpm
rpm -ivh libstdc++-devel-4.8.5-11.el7.x86_64.rpm 
rpm -ivh gcc-c++-4.8.5-11.el7.x86_64.rpm
```
##### bison
```bash
rpm -ivh m4-1.4.16-10.el7.x86_64.rpm 
rpm -ivh bison-2.7-4.el7.x86_64.rpm
```
##### flex
```bash
rpm -ivh flex-2.5.37-3.el7.x86_64.rpm
``` 
##### readline
```bash
rpm -ivh readline-6.2-9.el7.x86_64.rpm 
rpm -ivh ncurses-devel-5.9-13.20130511.el7.x86_64.rpm 
rpm -ivh readline-devel-6.2-9.el7.x86_64.rpm 
```
##### zlib
```bash
rpm -ivh zlib-devel-1.2.7-17.el7.x86_64.rpm 
```
##### xml2
```bash
rpm -ivh xz-devel-5.2.2-1.el7.x86_64.rpm 
rpm -ivh libxml2-devel-2.9.1-6.el7_2.3.x86_64.rpm 
```
##### xslt
```bash
rpm -ivh libxslt-1.1.28-5.el7.x86_64.rpm 
rpm -ivh libgpg-error-devel-1.12-3.el7.x86_64.rpm
rpm -ivh libgcrypt-devel-1.5.3-12.el7_1.1.x86_64.rpm
rpm -ivh libxslt-devel-1.1.28-5.el7.x86_64.rpm 
```
##### 其他
```bash
rpm -ivh python-devel-2.7.5-48.el7.x86_64.rpm 
```
#### 2. PostGIS
proj4 : 源码安装  
geos：源码安装  
libxml2: 编译PG时已经安装  
JSON-C：源码安装  
GDAL：源码安装  

#### 3. Pgrouting
```bash
rpm -ivh boost-1.53.0-26.el7.x86_64.rpm 
rpm -ivh boost-devel-1.53.0-26.el7.x86_64.rpm 
yum whatprovides libstdc++.so.6
yum install libstdc++-4.8.5-11.el7.i686
yum install qt5-qtbase-gui-5.6.1-10.el7.i686
yum install qt5-qtsvg-5.6.1-10.el7.i686
yum install gmp-devel-6.0.0-12.el7_1.x86_64
yum install mpfr-devel-3.1.1-4.el7.x86_64
yum install perl-devel-5.16.3-291.el7.x86_64
yum install perl-Data-Dumper-2.145-3.el7.x86_64
```

### 四、编译命令
#### 1. PostgreSQL
```bash
su - postgres
cd /opt/open_source/compile_target
rm -rf postgresql
mkdir postgresql

cd /opt/open_source/postgresql-9.6.2
./configure --prefix=/opt/open_source/compile_target/postgresql --with-python --with-libxml --with-libxslt CFLAGS='-O2' LDFLAGS=-lstdc++> /opt/open_source/log/postgres_config.log
make > /opt/open_source/log/postgres_make.log
make world > /opt/open_source/log/postgres_make_world.log
make install > /opt/open_source/log/postgres_install.log
make install-world > /opt/open_source/log/postgres_install_world.log
```

#### 2. PostGIS
```bash
su - postgres
mkdir /opt/postgresql/program/pg_tool
mkdir /opt/postgresql/program/pg_tool/proj
mkdir /opt/postgresql/program/pg_tool/geos
mkdir /opt/postgresql/program/pg_tool/jsonc
mkdir /opt/postgresql/program/pg_tool/gdal

#1）编译proj可以指定--prefix（例如把这些都安装到PG程序目录下，单独建一个pg_tool的目录）
./configure --prefix=/opt/postgresql/program/pg_tool/proj
make -s -j
make install
#2）编译geos
./configure --prefix=/opt/postgresql/program/pg_tool/geos
make -s -j
make install

#3)JSON-C
./configure --prefix=/opt/postgresql/program/pg_tool/jsonc
make -s -j
make install
#4)GDAL
./configure --prefix=/opt/postgresql/program/pg_tool/gdal
make
make install
#5)PostGIS
#a.  .bashrc 新增以下环境变量
export PROJ_HOME=/opt/postgresql/program/pg_tool/proj
export GEOS_HOME=/opt/postgresql/program/pg_tool/geos
export GDAL_HOME=/opt/postgresql/program/pg_tool/gdal
export JSON_HOME=/opt/postgresql/program/pg_tool/jsonc
export LD_LIBRARY_PATH=$GDAL_HOME/lib:$JSON_HOME/lib:$PROJ_HOME/lib:$GEOS_HOME/lib

#用source命令使其生效
#b. 设置GDAL
#root用户下执行
echo '/opt/postgresql/program/pg_tool/gdal/lib/' >> /etc/ld.so.conf
echo '/opt/postgresql/program/lib' >> /etc/ld.so.conf
echo '/opt/postgresql/program/pg_tool/jsonc/lib' >> /etc/ld.so.conf
echo '/opt/postgresql/program/pg_tool/proj/lib' >> /etc/ld.so.conf
echo '/opt/postgresql/program/pg_tool/geos/lib' >> /etc/ld.so.conf
echo '/usr/local/lib/' >> /etc/ld.so.conf
ldconfig
ldconfig -p |grep gdal
#c.
./configure --prefix=/opt/open_source/compile_target/postgis/ --with-pgconfig=/opt/postgresql/program/bin/pg_config --with-projdir=/opt/postgresql/program/pg_tool/proj  --with-geosconfig=/opt/postgresql/program/pg_tool/geos/bin/geos-config --with-gdalconfig=/opt/postgresql/program/pg_tool/gdal/bin/gdal-config --with-jsondir=/opt/postgresql/program/pg_tool/jsonc
make
make check
make install 
```
#### 3. Pgrouting
1)编译CGAL  
```
cmake .
make
make install
```
2)
```
mkdir build
cd build
cmake ..
make
make install
```

### 五、PostgreSQL安装
####安装程序
```bash
adduser postgres
passwd postgres
chmod 777 /opt
su - postgres
cd /opt/
mkdir postgresql
cd postgresql
mkdir program
mkdir data
chmod 700 *
exit
# 将相关程序文件拷贝到program目录下
cp -af /opt/open_source/compile_target/postgresql/* /opt/postgresql/program/
chown -R postgres: /opt/postgresql/
su - postgres
cd /home/postgres/
echo "export PGDATA=/opt/postgresql/data" >> .bashrc
echo "export PATH=$PATH:/opt/postgresql/program/bin" >> .bashrc
echo "export PGDIR=/opt/postgresql/program/bin" >> .bashrc
echo "export PGHOME=/opt/postgresql/program/" >> .bashrc
source .bashrc

##初始化数据库
initdb -D /opt/postgresql/data/

##基本参数调整
mkdir /opt/postgresql/db_log
log_destination = 'stderr'
logging_collector = on
log_directory = '/opt/postgresql/db_log'
```

### 六、PostGIS测试
```bash
\dx 
create extension postgis;
create extension postgis_topology;
SELECT srid,auth_name,proj4text FROM spatial_ref_sys LIMIT 10;
CREATE TABLE cities ( id int4, name varchar(50) );
SELECT AddGeometryColumn ('cities', 'the_geom', 4326, 'POINT', 2);
INSERT INTO cities (id, the_geom, name) VALUES (1,ST_GeomFromText('POINT(-0.1257 51.508)',4326),'London, England');
INSERT INTO cities (id, the_geom, name) VALUES (2,ST_GeomFromText('POINT(-81.233 42.983)',4326),'London, Ontario');
INSERT INTO cities (id, the_geom, name) VALUES (3,ST_GeomFromText('POINT(27.91162491 -33.01529)',4326),'East London,SA');
SELECT * FROM cities;
SELECT id, ST_AsText(the_geom), ST_AsEwkt(the_geom), ST_X(the_geom), ST_Y(the_geom) FROM cities;
SELECT p1.name,p2.name,ST_Distance_Sphere(p1.the_geom,p2.the_geom) FROM cities AS p1, cities AS p2 WHERE p1.id > p2.id;
SELECT p1.name,p2.name,ST_Distance_Spheroid(
	p1.the_geom,p2.the_geom, 'SPHEROID["GRS_1980",6378137,298.257222]'
	)
  FROM cities AS p1, cities AS p2 WHERE p1.id > p2.id;
```
测试套：在编译后的regress目录下（全部文件），有个脚本run_test.pl
```
./run_test.pl --extension --expect --topology --verbose <sql脚本名字>
./run_test.pl --clean test_gis <sql脚本名字>
```
进入regress目录后```make test```

### 七、Pgrouting安装
```
postgres=# create extension pgrouting;
CREATE EXTENSION
postgres=# \dx
                                         List of installed extensions
       Name       | Version |   Schema   |                             Description                             
------------------+---------+------------+---------------------------------------------------------------------
 pgrouting        | 2.4.1   | public     | pgRouting Extension
 plpgsql          | 1.0     | pg_catalog | PL/pgSQL procedural language
 postgis          | 2.3.2   | public     | PostGIS geometry, geography, and raster spatial types and functions
 postgis_topology | 2.3.2   | topology   | PostGIS topology spatial types and functions
(4 rows)

postgres=# 
```