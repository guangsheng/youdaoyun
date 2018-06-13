- 时序数据库，每条数据上都有时间戳。
- 分布式
- HTTP原生访问支持，REST API
- go语言编写
- 无结构，可以是任意数量的列
- 自带管理工具
	- port 8083：管理页面端口，访问localhost:8083可以进入你本机的influxdb管理页面
	- port 8086：http连接influxdb client端口，一般使用该端口往本机的influxdb读写数据

### MAC安装与启动
```
brew update
brew install influxdb
```

### 基本概念
#### influxdb相关名词
- database：数据库；
- measurement：数据库中的表；
- points：表里面的一行数据。 Point由时间戳（time）、数据（field）和标签（tags）组成。
	- time：每条数据记录的时间，也是数据库自动生成的主索引；
	- fields：各种记录的值；
	- tags：各种有索引的属性,常用作查询字段，分区字段等
	- 不论是tag还是field都有key:value的概念，其实就是column_name:column_value
- tag set：tag在InfluxDB中会按照字典序排序，不管是tag-key还是tag-value，只要不一致就分别属于两个tag set，例如hostname=server01,device=/data和hostname=server02,device=/data就是两个不同的tag set。
- Series：相当于是InfluxDB中一些数据的集合，在同一个database中，retention policy、measurement、tag sets完全相同的数据同属于一个series，同一个series的数据在物理上会按照时间顺序排列存储在一起。
- Retention policy：存储策略，用于设置数据保留的时间，InfluxDB会定期清除过期的数据。
- Shard：和Retention policy相关联。每一个存储策略下会存在许多shard，每一个shard存储一个指定时间段内的数据，并且不重复，例如7点-8点的数据落入shard0中，8点-9点的数据则落入shard1中。每一个shard都对应一个底层的tsm存储引擎，有独立的 cache、wal、tsm file。


### 官方参考文档
https://docs.influxdata.com/influxdb/v1.3/
https://docs.influxdata.com/influxdb/v1.3/query_language/schema_exploration/

### 小技巧
```
-登录后时间戳按 YYYY-MM-DD HH24:MI:SS方式显示
influx -precision rfc3339
```

### 用户管理
```
show users  
create user "username" with password 'password'
create user "username" with password 'password' with all privileges  
drop user "username"
```

### 数据库与表操作
```
create database "db_name"  
show databases  
drop database "db_name"  
  
# 使用数据库;
use db_name  
# 显示该数据库中所有的表;
show measurements  
# 创建表,直接在插入数据的时候指定表名(key-value);
insert disk,hostname=server02,device=/data free=90,used=110,used_percent=98.33,count=1
# 删除表;
drop measurement "measurement_name"
```

### 简单查询
```
-- sql示例   支持limit x offset y
select column_one  from foo  where time > now() – 1h limit 1000;
select reqtime, url from web9999.httpd where reqtime > 2.5;
select reqtime, url from web9999.httpd where time > now() – 1h limit 1000;

-- 表名可以正则; 对所有表做查询，都返回一条记录
select * from /.*/ limit 1
-- 约等于  匹配  支持正则表达式
select line from log_lines where line =~ /paul@influx.com/
-- 按照30m分钟进行聚合，时间范围是大于昨天的主机名是server1的;
select mean(value) from cpu_idle group by time(30m) where time > now() – 1d and hostName = 'server1'
-- url搜索里面含有login的字眼，还以login开头;
select reqtime, url from web9999.httpd where url =~ /^\/login\//;
```

#### 说明
- 如果查询的field不存在，并不会报错，只是不返回任何记录
- SLIMIT : series limit
- 几乎任何地方都支持正则表达式，表名，函数的参数等

#### 操作符
```
=   equal to
<> not equal to
!= not equal to
=~ matches against    支持正则表达式
!~ doesn’t match against
```

#### 输出Json格式 
```influx -database 'test' -execute 'select * from disk' -format 'json' -pretty```

### 连续查询
连续查询是在数据库中自动定时启动的一组语句，语句中必须包含SELECT关键词和GROUP BY time()关键词。 查询结果放在指定的数据表中。 

#### 目的
使用连续查询是最优的降低采样率的方式，连续查询和存储策略搭配使用将会大大降低InfluxDB的系统占用量。而且使用连续查询后，数据会存放到指定的数据表中，这样就为以后统计不同精度的数据提供了方便。

#### 语法  
```
CREATE CONTINUOUS QUERY <cq_name> ON <database_name>
[RESAMPLE [EVERY <interval>] [FOR <interval>]]
BEGIN SELECT <function>(<stuff>)[,<function>(<stuff>)] INTO <different_measurement>
FROM <current_measurement> [WHERE <stuff>] GROUP BY time(<interval>)[,<stuff>]
END

SHOW CONTINUOUS QUERIES
DROP CONTINUOUS QUERY <cq_name> ON <database_name>
```

#### 样例
在test库中新建一个名为redis_30m的连续查询，每三十分钟取一个connected_clients字段的平均值、中位值、最大值、最小值redis_clients_30m表中。使用的数据保留策略都是default。  

```
CREATE CONTINUOUS QUERY redis_30m ON test BEGIN 
SELECT mean(connected_clients), MEDIAN(connected_clients), MAX(connected_clients), MIN(connected_clients) 
INTO redis_clients_30m FROM redis_clients GROUP BY ip,port,time(30m) END
```  

### 管理
#### 数据保存策略
InfluxDB是没有提供直接删除数据记录的方法，但是提供数据保存策略，主要用于指定数据保留时间，超过指定时间，就删除这部分数据。 

```
show retention policies on "db_name"
create retention policy "rp_name" on "db_name" duration 3w replication 1 default
alter retention policy "rp_name" on "db_name" duration 30d default
drop retention policy "rp_name"
```

### SQL Function
https://docs.influxdata.com/influxdb/v1.3/query_language/functions/

支持哪些哪些函数，实现了什么功能？  

#### 聚合类函数有：  
- COUNT, DISTINCT, SUM
- 算数平均数值MEAN
- 中位值MEDIAN
- 出现次数最多的值MODE
- 最大最小值得差值SPREAD
- 标准差（the standard deviation）STDDEV
- 积分运算

#### 选择类函数有：  
- MAX, MIN
- 返回指定key最小的N个值：BOTTOM
- 返回指定key最大的N个值：TOP
- 返回第一条记录：FISRT和返回最后一条记录：LAST  (按timestamp算FIST和LAST）
- 返回排名第N%的值：PERCENTILE  指定百分比0-100（可以代替MAX,MIN和一定程度上代替MEDIAN)
- 随机取数据：SAMPLE

#### 变换类函数有（类似PG的窗口函数）：
**下面说的本行和上一行的值指的原始的值，并不是函数计算后的值**

- 本行+上上面所有行的值：CUMULATIVE_SUM
- 本行与上一行值得变化情况：DERIVATIVE  计算方法：(本行-上一行)/time_interval
- 本行-上一行值：DIFFERENCE
- 本行与下面几行的平均值（一个时间窗口内的平均值）：MOVING_AVERAGE
- 返回本行与上一行的时间戳的差值，也就是间隔，默认单位是纳秒，可以指定：ELAPSED
- NON_NEGATIVE_DERIVATIVE/NON_NEGATIVE_DIFFERENCE : 不返回负数行

#### 需要注意的
- COUNT : 计算非空值个数
- MEDIAN() is nearly equivalent to PERCENTILE(field_key, 50), except MEDIAN() returns the average of the two middle field values if the field contains an even number of values.  MEDIAN 当有偶数个value时，返回中间两个数的平均值
- MODE() returns the field value with the earliest timestamp if there’s a tie between two or more values for the maximum number of occurrences.

#### 一些例子
##### count+group by+slimit
```
--count
> select * from h2o_feet limit 2;
name: h2o_feet
time                 level description    location     water_level
----                 -----------------    --------     -----------
2015-08-18T00:00:00Z between 6 and 9 feet coyote_creek 8.12
2015-08-18T00:00:00Z below 3 feet         santa_monica 2.064
> show tag keys from h2o_feet;
name: h2o_feet
tagKey
------
location
> select count(*) from h2o_feet;
name: h2o_feet
time                 count_level description count_water_level
----                 ----------------------- -----------------
1970-01-01T00:00:00Z 15258                   15258
>

> SELECT COUNT("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* fill(200) LIMIT 7 SLIMIT 1

------注意下面加了group by, fill 和slimit 
> SELECT COUNT("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z';
name: h2o_feet
time                 count
----                 -----
2015-08-17T23:48:00Z 20

> SELECT COUNT("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m) LIMIT 7;
name: h2o_feet
time                 count
----                 -----
2015-08-17T23:48:00Z 0
2015-08-18T00:00:00Z 4
2015-08-18T00:12:00Z 4
2015-08-18T00:24:00Z 4
2015-08-18T00:36:00Z 4
2015-08-18T00:48:00Z 4

-- fill(200) : fills empty time intervals with 200 
-- COUNT() reports 0 for time intervals with no data, and fill(<fill_option>) replaces any 0 values with the fill_option.
> SELECT COUNT("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m) fill(200) LIMIT 7
name: h2o_feet
time                 count
----                 -----
2015-08-17T23:48:00Z 200
2015-08-18T00:00:00Z 4
2015-08-18T00:12:00Z 4
2015-08-18T00:24:00Z 4
2015-08-18T00:36:00Z 4
2015-08-18T00:48:00Z 4

--slimit
> SELECT COUNT("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* LIMIT 7
name: h2o_feet
tags: location=coyote_creek
time                 count
----                 -----
2015-08-17T23:48:00Z 0
2015-08-18T00:00:00Z 2
2015-08-18T00:12:00Z 2
2015-08-18T00:24:00Z 2
2015-08-18T00:36:00Z 2
2015-08-18T00:48:00Z 2

name: h2o_feet
tags: location=santa_monica
time                 count
----                 -----
2015-08-17T23:48:00Z 0
2015-08-18T00:00:00Z 2
2015-08-18T00:12:00Z 2
2015-08-18T00:24:00Z 2
2015-08-18T00:36:00Z 2
2015-08-18T00:48:00Z 2
> SELECT COUNT("water_level") FROM "h2o_feet" WHERE time >= '2015-08-17T23:48:00Z' AND time <= '2015-08-18T00:54:00Z' GROUP BY time(12m),* LIMIT 7 SLIMIT 1
name: h2o_feet
tags: location=coyote_creek
time                 count
----                 -----
2015-08-17T23:48:00Z 0
2015-08-18T00:00:00Z 2
2015-08-18T00:12:00Z 2
2015-08-18T00:24:00Z 2
2015-08-18T00:36:00Z 2
2015-08-18T00:48:00Z 2
>
```

##### CUMULATIVE_SUM
```
> SELECT "water_level" FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'

name: h2o_feet
time                 water_level
----                 -----------
2015-08-18T00:00:00Z 2.064
2015-08-18T00:06:00Z 2.116
2015-08-18T00:12:00Z 2.028
2015-08-18T00:18:00Z 2.126
2015-08-18T00:24:00Z 2.041
2015-08-18T00:30:00Z 2.051
>
> SELECT CUMULATIVE_SUM("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica'
name: h2o_feet
time                 cumulative_sum
----                 --------------
2015-08-18T00:00:00Z 2.064
2015-08-18T00:06:00Z 4.18
2015-08-18T00:12:00Z 6.208
2015-08-18T00:18:00Z 8.334
2015-08-18T00:24:00Z 10.375
2015-08-18T00:30:00Z 12.426
>
> SELECT CUMULATIVE_SUM("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' ORDER BY time DESC LIMIT 4 OFFSET 2
name: h2o_feet
time                 cumulative_sum
----                 --------------
2015-08-18T00:18:00Z 6.218
2015-08-18T00:12:00Z 8.246
2015-08-18T00:06:00Z 10.362
2015-08-18T00:00:00Z 12.426
> select MEAN("water_level") FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)
name: h2o_feet
time                 mean
----                 ----
2015-08-18T00:00:00Z 2.09
2015-08-18T00:12:00Z 2.077
2015-08-18T00:24:00Z 2.0460000000000003
> SELECT CUMULATIVE_SUM(MEAN("water_level")) FROM "h2o_feet" WHERE time >= '2015-08-18T00:00:00Z' AND time <= '2015-08-18T00:30:00Z' AND "location" = 'santa_monica' GROUP BY time(12m)
name: h2o_feet
time                 cumulative_sum
----                 --------------
2015-08-18T00:00:00Z 2.09
2015-08-18T00:12:00Z 4.167
2015-08-18T00:24:00Z 6.213
>
```


### pgwatch2 sql
```
show tag values from stat_statements with key = "query" WHERE dbname = 'pro_rds_bike_order' and "query" !~ /.*(pg_stat_activity)|(pg_stat_replication)|(pg_stat_user_functions)|(pg_stat_user_indexes)|(pg_stat_statements)|(pg_stat_database)|(pg_database)|(information_schema)|(pg_proc)|(pg_index)|(pg_settings)|(pg_locks)|(pg_stat_user_tables)|(pg_statio_user_tables)|(pg_stat_bgwriter)|(pg_class)|(pg_namespace)|(pg_current_xlog_location).*/

SELECT non_negative_derivative(mean("total_time"), 1h) / non_negative_derivative(mean("calls"), 1h) FROM "stat_statements" WHERE "queryid" =~ /^$queryid$/ AND $timeFilter GROUP BY time($interval), "queryid" fill(null)
```

```
show tag keys from table_stats;
show field keys from table_stats;
show tag values from table_stats with key = "dbname" where dbname = 'pro_rds_bike';
show tag values from table_stats with key = "table_name" where dbname = 'pro_rds_bike';
show tag values from table_stats with key = "table_name" where dbname =~ /pro_rds_bike/;

select max(QPS)/60 from (select non_negative_derivative(mean(seq_scan), 1m) + non_negative_derivative(mean(idx_scan), 1m) AS QPS FROM table_stats where dbname = 'pro_rds_bike' and table_name = 't_month_card' and time >= '2018-05-25 00:00:00' and time < '2018-05-25 01:00:00' group by time(1m) fill(none))
```
