轻量级PostgreSQL连接池  

## CentOS    VECS00062
配置文件位置: /etc/pgbouncer/pgbouncer.ini  
启动程序位置: /etc/init.d/pgbouncer

## 几个问题
- 通过域名访问数据库，长连接，如果域名对应的IP变了，如何做到不影响业务的重新连接。
    返回连接时先判断连接是否有效，如果无效重新获取。   这个策略是比较重要的。


## EXAMPLE  https://my.oschina.net/Kenyon/blog/73935
### 配置
```
[deploy@VECS00062 tmp]$ tree pgbouncer_test/
pgbouncer_test/
├── pgbouncer.ini
├── pgbouncer.log
├── pgbouncer.pid
└── user.txt

0 directories, 4 files
[deploy@VECS00062 tmp]$ cat pgbouncer_test/pgbouncer.ini 
[databases]
p_master = host=127.0.0.1 port=5900 dbname=master user=master password=pwd
p_work0 = host=127.0.0.1 port=5900 dbname=work0 user=worker password=pwd
p_work1 = host=127.0.0.1 port=5900 dbname=work1 user=worker password=pwd

[pgbouncer]
listen_port = 6432 
listen_addr = *
auth_type = md5
auth_file = /dbdir/tmp/pgbouncer_test/user.txt
logfile = /dbdir/tmp/pgbouncer_test/pgbouncer.log
pidfile = /dbdir/tmp/pgbouncer_test/pgbouncer.pid
admin_users = pgbouncer_admin
pool_mode = transaction
[deploy@VECS00062 tmp]$ cat pgbouncer_test/user.txt 
"pgbouncer_admin" "pwd"
[deploy@VECS00062 tmp]$
```

### 使用
```
# 启动
pgbouncer -d pgbouncer.ini 
# 登录工作数据库
jumpD:~$ psql -h 10.111.50.227 -p 6432 -U pgbouncer_admin p_master
Password for user pgbouncer_admin: 
psql (9.4.5, server 10.1)
p_master=> \dt
                 List of relations
 Schema |         Name          | Type  |  Owner   
--------+-----------------------+-------+----------
 worker | pathman_config        | table | postgres
 worker | pathman_config_params | table | postgres
 worker | t_test_ride_info      | table | master
(3 rows)

# 登录pgbouncer自己的数据库
[deploy@VECS00062 ~]$ psql -h 127.0.0.1 -p 6432 -U pgbouncer_admin pgbouncer
Password for user pgbouncer_admin: 
psql (10.1, server 1.8.1/bouncer)
Type "help" for help.

pgbouncer=# show help
pgbouncer-# ;
NOTICE:  Console usage
DETAIL:  
        SHOW HELP|CONFIG|DATABASES|POOLS|CLIENTS|SERVERS|VERSION
        SHOW FDS|SOCKETS|ACTIVE_SOCKETS|LISTS|MEM
        SHOW DNS_HOSTS|DNS_ZONES
        SHOW STATS|STATS_TOTALS|STATS_AVERAGES
        SET key = arg
        RELOAD
        PAUSE [<db>]
        RESUME [<db>]
        DISABLE <db>
        ENABLE <db>
        KILL <db>
        SUSPEND
        SHUTDOWN
SHOW
pgbouncer=# show config;
            key            |                         value                          | changeable 
---------------------------+--------------------------------------------------------+------------
 job_name                  | pgbouncer                                              | no
 conffile                  | pgbouncer.ini                                          | yes
 logfile                   | /dbdir/tmp/pgbouncer_test/pgbouncer.log                | yes
 pidfile                   | /dbdir/tmp/pgbouncer_test/pgbouncer.pid                | no
 listen_addr               | *                                                      | no
 listen_port               | 6432                                                   | no
 listen_backlog            | 128                                                    | no
 unix_socket_dir           | /tmp                                                   | no
 unix_socket_mode          | 511                                                    | no
 unix_socket_group         |                                                        | no
 auth_type                 | md5                                                    | yes
 auth_file                 | /dbdir/tmp/pgbouncer_test/user.txt                     | yes
 auth_hba_file             |                                                        | yes
 auth_user                 |                                                        | yes
 auth_query                | SELECT usename, passwd FROM pg_shadow WHERE usename=$1 | yes
 pool_mode                 | session                                                | yes
 max_client_conn           | 100                                                    | yes
 default_pool_size         | 20                                                     | yes
 min_pool_size             | 0                                                      | yes
 reserve_pool_size         | 0                                                      | yes
 reserve_pool_timeout      | 5                                                      | yes
 max_db_connections        | 0                                                      | yes
 max_user_connections      | 0                                                      | yes
 syslog                    | 0                                                      | yes
 syslog_facility           | daemon                                                 | yes
 syslog_ident              | pgbouncer                                              | yes
 user                      |                                                        | no
 autodb_idle_timeout       | 3600                                                   | yes
 server_reset_query        | DISCARD ALL                                            | yes
 server_reset_query_always | 0                                                      | yes
 server_check_query        | select 1                                               | yes
 server_check_delay        | 30                                                     | yes
 query_timeout             | 0                                                      | yes
 query_wait_timeout        | 120                                                    | yes
 client_idle_timeout       | 0                                                      | yes
pgbouncer=#
pgbouncer=# show clients; 
 type |      user       | database  | state  |     addr     | port  |  local_addr   | local_port |    connect_time     |    request_time     | wait | wait_us |    ptr    |   link    | remote_pid | tls 
------+-----------------+-----------+--------+--------------+-------+---------------+------------+---------------------+---------------------+------+---------+-----------+-----------+------------+-----
 C    | pgbouncer_admin | p_master  | active | 10.51.35.112 | 56659 | 10.111.50.227 |       6432 | 2018-01-09 15:31:31 | 2018-01-09 15:32:02 |    0 |       0 | 0x148ff00 | 0x1494ed0 |          0 | 
 C    | pgbouncer_admin | p_work0   | active | 10.51.35.112 | 56700 | 10.111.50.227 |       6432 | 2018-01-09 15:35:25 | 2018-01-09 15:35:30 |    0 |       0 | 0x1490230 | 0x1495068 |          0 | 
 C    | pgbouncer_admin | pgbouncer | active | 127.0.0.1    | 51194 | 127.0.0.1     |       6432 | 2018-01-09 15:34:15 | 2018-01-09 15:36:48 |  137 |  595933 | 0x1490098 |           |          0 | 
(3 rows)

pgbouncer=# show fds;
 fd |  task  |      user       | database |     addr     | port  |        cancel        | link | client_encoding | std_strings | datestyle | timezone | password 
----+--------+-----------------+----------+--------------+-------+----------------------+------+-----------------+-------------+-----------+----------+----------
  7 | pooler |                 |          | 0.0.0.0      |  6432 |                    0 |    0 |                 |             |           |          | 
  8 | pooler |                 |          | unix         |  6432 |                    0 |    0 |                 |             |           |          | 
  9 | client | pgbouncer_admin | p_master | 10.51.35.112 | 56659 |  2187857837526049323 |   10 | UTF8            | on          | ISO, MDY  | PRC      | 
 10 | server | master          | p_master | 127.0.0.1    |  5900 |       15374983477501 |    9 | UTF8            | on          | ISO, MDY  | PRC      | 
 12 | client | pgbouncer_admin | p_work0  | 10.51.35.112 | 56700 | 13392670463784956641 |   13 | UTF8            | on          | ISO, MDY  | PRC      | 
 13 | server | worker          | p_work0  | 127.0.0.1    |  5900 |       17014410148794 |   12 | UTF8            | on          | ISO, MDY  | PRC      | 
(6 rows)

```



## 参数说明
https://pgbouncer.github.io/config.html  

### 基本配置
- listen_addr
- listen_port
- unix_socket_dir
- unix_socket_mode
- unix_socket_group

### 数据库相关
- dbname
- host
- port
- user
- password
- auth_user
- pool_size
- connect_query
- pool_mode
- max_db_connections
- client_encoding
- datestyle

### 认证相关
- auth_file: The name of the file to load user names and passwords from. 
- auth_hba_file: 
- auth_type: 
- auth_query: Query to load user’s password from database.
- auth_user: 

### 连接配置
- pool_mode: session/transaction/statement  什么是否释放连接
- max_client_conn
- default_pool_size : How many server connections to allow per user/database pair. 
- min_pool_size
- reserve_pool_size
- reserve_pool_timeout : If a client has not been serviced in this many seconds, pgbouncer enables use of additional connections from reserve pool.
- max_db_connections   : Do not allow more than this many connections per-database 
- max_user_connections : Do not allow more than this many connections per-user
- server_round_robin   : By default, pgbouncer reuses server connections in LIFO (last-in, first-out) manner, so that few connections get the most load. This gives best performance if you have a single server serving a database. But if there is TCP round-robin behind a database IP, then it is better if pgbouncer also uses connections in that manner, thus achieving uniform load.

### LOG相关
- log_connections
- log_disconnections
- log_pooler_errors
- stats_period : Period for writing aggregated stats into log.
- verbose

### 健康检查
- server_reset_query
- server_reset_query_always
- server_check_delay
- server_check_query
- server_lifetime
- server_idle_timeout
- server_connect_timeout
- server_login_retry
- client_login_timeout
- autodb_idle_timeout
- dns_max_ttl
- dns_nxdomain_ttl
- dns_zone_check_period

### 底层网络设置
- pkt_buf
- max_packet_size
- listen_backlog
- sbuf_loopcnt
- suspend_timeout
- tcp_defer_accept
- tcp_socket_buffer
- tcp_keepalive
- tcp_keepcnt
- tcp_keepidle
- tcp_keepintvl

### 通用配置
- logfile
- pidfile
- ignore_startup_parameters
- disable_pqexec  : Disable Simple Query protocol (PQexec). Unlike Extended Query protocol, Simple Query allows multiple queries in one packet, which allows some classes of SQL-injection attacks. 
- application_name_add_host