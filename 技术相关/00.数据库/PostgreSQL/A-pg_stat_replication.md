```
postgres=# \d pg_stat_replication
          View "pg_catalog.pg_stat_replication"
      Column      |           Type           | Modifiers
------------------+--------------------------+-----------
 pid              | integer                  |   --WAL发送进程的ID
 usesysid         | oid                      |   --登陆到这个WAL发送进程的用户OID
 usename          | name                     |   --登陆到WAL发送进程的用户名
 application_name | text                     |   --连接到这个WAL发送端的应用名
 client_addr      | inet                     |   --客户端连接到这个WAL发送端的IP地址，如果这个字段为null，它表明通过 服务器上Unix套接字连接客户端。
 client_hostname  | text                     |   --连接客户端的主机名，通过client_addr的反向DNS查找报告。 并且当启用log_hostname时，这个字段对于IP连接是非空的。
 client_port      | integer                  |   --客户端正在使用与WAL发送端连接的TCP端口号，或者如果使用Unix套接字则为-1。
 backend_start    | timestamp with time zone |   --这个进程开始时的时间，比如当客户端连接到这个WAL发送端时。
 backend_xmin     | xid                      |   --hot_standby_feedback 报告的这个备用的xmin范围。
 state            | text                     |   --当前WAL发送端状态
 sent_location    | pg_lsn                   |   --在这次连接上发送的上次事务日志位置
 write_location   | pg_lsn                   |   --通过备用服务器写入到磁盘的上次事务日志位置。
 flush_location   | pg_lsn                   |   --通过备用服务器刷新到磁盘的上次事务日志位置。
 replay_location  | pg_lsn                   |   --备用服务器上重放到数据库的上次事务日志位置。
 sync_priority    | integer                  |   --这个备用服务器被选为同步备用的优先级。
 sync_state       | text                     |   --该备用服务器的同步状态

postgres=#
```