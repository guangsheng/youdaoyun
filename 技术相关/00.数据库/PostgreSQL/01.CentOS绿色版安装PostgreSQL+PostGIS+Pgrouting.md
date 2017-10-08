### PostgreSQL+PostGIS+Pgrouting
#### 目录规划
目录名称|说明|路径
--------|----|----
program|数据库程序目录|$PGHOME/program
user_lib|数据库程序用客户化lib|$PGHOME/program/user_lib
data|数据库集群目录|$PGHOME/data
pg_tool|自定义程序|$PGHOME/program/pg_tool
db_log|数据库日志目录|$PGHOME/db_log
test|数据库测试程序脚本目录|$PGHOME/test

#### 操作系统配置
##### 用户
```bash
useradd postgres -d /home/postgres/ -u 1001
passwd postgres
mkdir /opt/postgres
cd /opt/postgres
mkdir data
mkdir db_log
mkdir test
mkdir program
mkdir program/pg_tool
mkdir program/user_lib
cd /opt
chmod -R 700 postgres
chown -R postgres: postgres
su - postgres

```
##### 数据库操作系统用户的 .bashrc
```
export PGHOME=/opt/postgres
export PGDIR=$PGHOME/program
export PGBIN=$PGDIR/bin
export PGLIB=$PGDIR/lib
export PGTOOL=$PGDIR/pg_tool
export PGUSERLIB=$PGDIR/user_lib

export PGDATA=$PGHOME/data

PATH=$PGBIN:$PGTOOL:$PATH
export PATH
```

##### /etc/ld.so.conf  root用户下修改
```BASH
cd /etc/ld.so.conf.d/
touch userlocal-postgresql.conf
chmod 644 userlocal-postgresql.conf
PGHOME=/opt/postgres
PGDIR=$PGHOME/program
PGUSERLIB=$PGDIR/user_lib
echo "$PGUSERLIB/geos/lib" >> userlocal-postgresql.conf 
echo "$PGUSERLIB/gdal/lib" >> userlocal-postgresql.conf 
echo "$PGUSERLIB/jsonc/lib" >> userlocal-postgresql.conf 
echo "$PGUSERLIB/proj/lib" >> userlocal-postgresql.conf
echo "$PGUSERLIB/pgrouting" >> userlocal-postgresql.conf
echo "$PGUSERLIB/CGAL/lib" >> userlocal-postgresql.conf
```

##### 遗留问题说明： 数据库操作系统用户的 .bashrc
下面的配置后正常应该生效，但是还是报错，找不到动态库（ldd已经可以看到了），最终解决时还是将其放到了/etc/ld.so.conf文件中
```
LD_LIBRARY_PATH=$PGLIB:$PGUSERLIB/geos/lib:$PGUSERLIB/proj/lib:$PGUSERLIB/gdal/lib:$PGUSERLIB/jsonc/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH
```

##### 绿色安装
1. 把程序拷贝到program目录下
2. 在root用户下执行 `ldconfig` 命令使共享库加载到cache中
2. initdb安装
initdb -D $PGDATA

```
[root@localhost program]# ll
total 16
drwx------. 2 postgres postgres 4096 Apr 17 10:47 bin
drwx------. 6 postgres postgres 4096 Apr 16 00:02 include
drwx------. 4 postgres postgres 4096 Apr 18 10:32 lib
drwx------. 2 postgres postgres    6 Apr 21 21:34 pg_tool
drwx------. 9 postgres postgres 4096 Apr 17 10:47 share
drwxrwxr-x. 8 postgres postgres   84 Apr 21 22:26 user_lib
[root@localhost program]# ll user_lib/
total 0
drwx------. 3 postgres postgres 17 Apr 21 22:09 CGAL
drwx------. 6 postgres postgres 56 Apr 17 09:47 gdal
drwx------. 5 postgres postgres 43 Apr 17 08:42 geos
drwx------. 4 postgres postgres 32 Apr 17 08:42 jsonc
drwx------. 2 postgres postgres  6 Apr 21 22:26 pgrouting
drwx------. 6 postgres postgres 56 Apr 17 08:37 proj
[root@localhost program]# 
```

#### 基本参数配置
```
logging_collector = on
log_directory = '/opt/postgres/db_log/'
log_min_messages = notice
log_min_duration_statement = 6000
log_checkpoints = on
log_connections = on
log_disconnections = on
log_duration = on
log_error_verbosity = verbose
log_line_prefix = '%t [%p]: [%l-1] <%d %u %h>'

unix_socket_permissions = 0600

listen_addresses = 'localhost,192.168.59.191'

```

#### 启动和基本测试
##### PostgreSQL
`pg_ctl start`

```
[postgres@localhost data]$ psql postgres postgres -c "\l"
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(3 rows)

[postgres@localhost data]$ psql postgres postgres -c "\dx"
                 List of installed extensions
  Name   | Version |   Schema   |         Description          
---------+---------+------------+------------------------------
 plpgsql | 1.0     | pg_catalog | PL/pgSQL procedural language
(1 row)

[postgres@localhost data]$ 

```
##### PostGIS
```
psql postgres postgres -c "create database gis_test";
psql postgres postgres -c "create user gistest password 'gis_test' LOGIN";
psql postgres postgres -c "GRANT ALL ON DATABASE gis_test TO gistest"

psql -d gis_test -U postgres
create extension postgis;
create extension postgis_topology;
\q

psql -d gis_test -U gistest
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

\q
```

##### Pgrouting
```
psql -d gis_test -U postgres
create extension pgrouting;
\dx
\q
```

### TODO:需要准备的测试套，做较全面的测试