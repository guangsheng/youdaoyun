#### 1. 如何登陆mysql数据库
```mysql -uroot -p```

#### 2. 如何查看有哪些数据库
```show databases```

#### 3. 如何进入需要处理的数据库
```use database_name```

#### 4. 如何快速定位慢查询（打开慢查询开关）
```
----方式一
show variables like 'slow_query%';
show variables like 'long_query_time';

set global slow_query_log='ON'; 
set global slow_query_log_file='/usr/local/mysql/data/slow.log';
set global long_query_time=1;

--观察慢查询情况

set global slow_query_log='OFF'; 

----方式二  使用如下方式查询执行时间较长的SQL
mysql -uroot -pXXXX -e"show processlist" |grep -v Sleep

```

#### 5. 如何定位某一条SQL慢的原因
```
--1 查看执行计划
explain execute_sql;
explain partitions execute_sql;

--2
set profiling = 1;
--执行对应SQL
show profiles; --查看对应SQL的Query_ID
show profile for query {Query_ID};  --查看具体耗时阶段
set profiling = 0;
```

#### show profile和show processlist中的status和Command的含义
- Sending Data


### 最终如何解决的
1. 观察到是慢在 Sending Data阶段
2. 慢查询的查询时间范围都很大（7天），数据结果集在9000以上
3. 将分区表修改为只保留3天，并将之前的分区表都删除
4. 重启所有的zabbix agent后问题回复

### 用户的SQL
#### 查询数据库中指定函数的定义
```
show create procedure proc_name;
show create function func_name;
```
