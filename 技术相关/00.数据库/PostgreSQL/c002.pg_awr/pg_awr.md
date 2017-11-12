#### 参考
https://yq.aliyun.com/articles/64873
https://yq.aliyun.com/articles/72846

#### 手动安装
1. 安装 ```pg_stat_statements```
2. 在要监控的数据库上执行 ```pg_awr/init.sql```

#### 使用库监控
假设库名为```_databasename```, 用户名为```_usernamme```,端口号为```_port```, IP为``` _host```
##### 1.定时任务定时打快照
```
--to database
psql -d _databasename -U _usernamme -h _host -p _port -c "select __rds_pg_stats__.snap_database(false);"
--to_global
psql -d _databasename -U _usernamme -h _host -p _port -c "select __rds_pg_stats__.snap_global(false);"
```
##### 2. 查看快照信息
```
psql -d _databasename -U _usernamme -h _host -p _port -c "select * from __rds_pg_stats__.snap_list where snap_level = 'database' order by id;"
```
##### 3. 选择要查看的时间段生成awr报告（md模式）
```
psql -d _databasename -U _usernamme -h _host -p _port --pset=pager=off -c "select * from __rds_pg_stats__.snap_report_database(39,40)" > database.md  
```

##### 4.按ID清理快照
```
select __rds_pg_stats__.snap_delete(4::int8);  -- 删除指定SNAP ID以前的快照
select __rds_pg_stats__.snap_delete(5::int4);  -- 保留最近的5个快照，其他删除。  
select __rds_pg_stats__.snap_delete('2017-10-26 10:47:36'::timestamp);  -- 删除指定时间前的快照。
```