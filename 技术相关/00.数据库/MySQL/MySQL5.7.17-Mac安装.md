1. 获取MySQL
https://dev.mysql.com/downloads/mysql/5.7.html#downloads

2. 安装（dmg安装包，图形化安装界面）  
```
2017-03-14T03:50:55.753680Z 1 [Note] A temporary password is generated for root@localhost: wyS4&agCWp0k
If you lose this password, please consult the section How to Reset the Root Password in the MySQL reference manual.
```
3. 修改环境变量和初始化  
```
bogon:bin shiguangsheng$ cat /Users/shiguangsheng/.bash_profile
alias ll="ls -Al"
alias ..="cd .."
export PGDATA=/Users/shiguangsheng/user_program/postgresql/data
export PGDIR=/Users/shiguangsheng/user_program/postgresql/bin
export MYHOME=/Users/shiguangsheng/Desktop/MyZone
export MYKM=/Users/shiguangsheng/Desktop/MyZone/KM
export MYSQLHOME=/usr/local/mysql
export MYSQLBIN=/usr/local/mysql/bin
export MYSQLLIB=/usr/local/mysql/lib
export PATH=$PATH:/Users/shiguangsheng/user_program/postgresql/bin:$MYSQLBIN
./mysqld --initalize
```
4. 启动停止
```mysqld &```

5. 修改为简单密码 huawei
```
bogon:~ shiguangsheng$ mysqladmin -uroot -p password
Enter password:
New password:
Confirm new password:
Warning: Since password will be sent to server in plain text, use ssl connection to ensure password safety.
```
### 初始化记录
```
bogon:bin shiguangsheng$ ./mysqld --initalize
2017-03-14T08:51:30.029777Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2017-03-14T08:51:30.029987Z 0 [Note] --secure-file-priv is set to NULL. Operations related to importing and exporting data are disabled
2017-03-14T08:51:30.030034Z 0 [Note] ./mysqld (mysqld 5.7.17) starting as process 21216 ...
2017-03-14T08:51:30.033192Z 0 [Warning] Setting lower_case_table_names=2 because file system for /usr/local/mysql-5.7.17-macos10.12-x86_64/data/ is case insensitive
2017-03-14T08:51:30.039185Z 0 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
2017-03-14T08:51:30.039219Z 0 [Note] InnoDB: Uses event mutexes
2017-03-14T08:51:30.039225Z 0 [Note] InnoDB: GCC builtin __atomic_thread_fence() is used for memory barrier
2017-03-14T08:51:30.039229Z 0 [Note] InnoDB: Compressed tables use zlib 1.2.3
2017-03-14T08:51:30.041006Z 0 [Note] InnoDB: Number of pools: 1
2017-03-14T08:51:30.043282Z 0 [Note] InnoDB: Using CPU crc32 instructions
2017-03-14T08:51:30.044934Z 0 [Note] InnoDB: Initializing buffer pool, total size = 128M, instances = 1, chunk size = 128M
2017-03-14T08:51:30.056980Z 0 [Note] InnoDB: Completed initialization of buffer pool
2017-03-14T08:51:30.080017Z 0 [Note] InnoDB: Highest supported file format is Barracuda.
2017-03-14T08:51:30.103097Z 0 [Note] InnoDB: Creating shared tablespace for temporary tables
2017-03-14T08:51:30.103262Z 0 [Note] InnoDB: Setting file './ibtmp1' size to 12 MB. Physically writing the file full; Please wait ...
2017-03-14T08:51:30.117301Z 0 [Note] InnoDB: File './ibtmp1' size is now 12 MB.
2017-03-14T08:51:30.119002Z 0 [Note] InnoDB: 96 redo rollback segment(s) found. 96 redo rollback segment(s) are active.
2017-03-14T08:51:30.119023Z 0 [Note] InnoDB: 32 non-redo rollback segment(s) are active.
2017-03-14T08:51:30.119405Z 0 [Note] InnoDB: Waiting for purge to start
2017-03-14T08:51:30.174702Z 0 [Note] InnoDB: 5.7.17 started; log sequence number 2534561
2017-03-14T08:51:30.175147Z 0 [Note] InnoDB: Loading buffer pool(s) from /usr/local/mysql-5.7.17-macos10.12-x86_64/data/ib_buffer_pool
2017-03-14T08:51:30.177385Z 0 [Note] Plugin 'FEDERATED' is disabled.
2017-03-14T08:51:30.188964Z 0 [Note] InnoDB: Buffer pool(s) load completed at 170314 16:51:30
2017-03-14T08:51:30.194414Z 0 [ERROR] unknown option '--initalize'
2017-03-14T08:51:30.194437Z 0 [ERROR] Aborting

2017-03-14T08:51:30.194456Z 0 [Note] Binlog end
2017-03-14T08:51:30.194564Z 0 [Note] Shutting down plugin 'ngram'
2017-03-14T08:51:30.194572Z 0 [Note] Shutting down plugin 'partition'
2017-03-14T08:51:30.194577Z 0 [Note] Shutting down plugin 'BLACKHOLE'
2017-03-14T08:51:30.194581Z 0 [Note] Shutting down plugin 'ARCHIVE'
2017-03-14T08:51:30.194585Z 0 [Note] Shutting down plugin 'PERFORMANCE_SCHEMA'
2017-03-14T08:51:30.194660Z 0 [Note] Shutting down plugin 'MRG_MYISAM'
2017-03-14T08:51:30.194693Z 0 [Note] Shutting down plugin 'MyISAM'
2017-03-14T08:51:30.195107Z 0 [Note] Shutting down plugin 'INNODB_SYS_VIRTUAL'
2017-03-14T08:51:30.195121Z 0 [Note] Shutting down plugin 'INNODB_SYS_DATAFILES'
2017-03-14T08:51:30.195123Z 0 [Note] Shutting down plugin 'INNODB_SYS_TABLESPACES'
2017-03-14T08:51:30.195125Z 0 [Note] Shutting down plugin 'INNODB_SYS_FOREIGN_COLS'
2017-03-14T08:51:30.195127Z 0 [Note] Shutting down plugin 'INNODB_SYS_FOREIGN'
2017-03-14T08:51:30.195129Z 0 [Note] Shutting down plugin 'INNODB_SYS_FIELDS'
2017-03-14T08:51:30.195131Z 0 [Note] Shutting down plugin 'INNODB_SYS_COLUMNS'
2017-03-14T08:51:30.195133Z 0 [Note] Shutting down plugin 'INNODB_SYS_INDEXES'
2017-03-14T08:51:30.195135Z 0 [Note] Shutting down plugin 'INNODB_SYS_TABLESTATS'
2017-03-14T08:51:30.195137Z 0 [Note] Shutting down plugin 'INNODB_SYS_TABLES'
2017-03-14T08:51:30.195138Z 0 [Note] Shutting down plugin 'INNODB_FT_INDEX_TABLE'
2017-03-14T08:51:30.195140Z 0 [Note] Shutting down plugin 'INNODB_FT_INDEX_CACHE'
2017-03-14T08:51:30.196075Z 0 [Note] Shutting down plugin 'INNODB_FT_CONFIG'
2017-03-14T08:51:30.196091Z 0 [Note] Shutting down plugin 'INNODB_FT_BEING_DELETED'
2017-03-14T08:51:30.196096Z 0 [Note] Shutting down plugin 'INNODB_FT_DELETED'
2017-03-14T08:51:30.196100Z 0 [Note] Shutting down plugin 'INNODB_FT_DEFAULT_STOPWORD'
2017-03-14T08:51:30.196103Z 0 [Note] Shutting down plugin 'INNODB_METRICS'
2017-03-14T08:51:30.196106Z 0 [Note] Shutting down plugin 'INNODB_TEMP_TABLE_INFO'
2017-03-14T08:51:30.196109Z 0 [Note] Shutting down plugin 'INNODB_BUFFER_POOL_STATS'
2017-03-14T08:51:30.196113Z 0 [Note] Shutting down plugin 'INNODB_BUFFER_PAGE_LRU'
2017-03-14T08:51:30.196116Z 0 [Note] Shutting down plugin 'INNODB_BUFFER_PAGE'
2017-03-14T08:51:30.196119Z 0 [Note] Shutting down plugin 'INNODB_CMP_PER_INDEX_RESET'
2017-03-14T08:51:30.196123Z 0 [Note] Shutting down plugin 'INNODB_CMP_PER_INDEX'
2017-03-14T08:51:30.196126Z 0 [Note] Shutting down plugin 'INNODB_CMPMEM_RESET'
2017-03-14T08:51:30.196131Z 0 [Note] Shutting down plugin 'INNODB_CMPMEM'
2017-03-14T08:51:30.196134Z 0 [Note] Shutting down plugin 'INNODB_CMP_RESET'
2017-03-14T08:51:30.196137Z 0 [Note] Shutting down plugin 'INNODB_CMP'
2017-03-14T08:51:30.196141Z 0 [Note] Shutting down plugin 'INNODB_LOCK_WAITS'
2017-03-14T08:51:30.196144Z 0 [Note] Shutting down plugin 'INNODB_LOCKS'
2017-03-14T08:51:30.196147Z 0 [Note] Shutting down plugin 'INNODB_TRX'
2017-03-14T08:51:30.196151Z 0 [Note] Shutting down plugin 'InnoDB'
2017-03-14T08:51:30.196262Z 0 [Note] InnoDB: FTS optimize thread exiting.
2017-03-14T08:51:30.196320Z 0 [Note] InnoDB: Starting shutdown...
2017-03-14T08:51:30.301705Z 0 [Note] InnoDB: Dumping buffer pool(s) to /usr/local/mysql-5.7.17-macos10.12-x86_64/data/ib_buffer_pool
2017-03-14T08:51:30.303370Z 0 [Note] InnoDB: Buffer pool(s) dump completed at 170314 16:51:30
2017-03-14T08:51:31.651896Z 0 [Note] InnoDB: Shutdown completed; log sequence number 2534580
2017-03-14T08:51:31.652966Z 0 [Note] InnoDB: Removed temporary tablespace data file: "ibtmp1"
2017-03-14T08:51:31.652988Z 0 [Note] Shutting down plugin 'MEMORY'
2017-03-14T08:51:31.652992Z 0 [Note] Shutting down plugin 'CSV'
2017-03-14T08:51:31.652996Z 0 [Note] Shutting down plugin 'sha256_password'
2017-03-14T08:51:31.652998Z 0 [Note] Shutting down plugin 'mysql_native_password'
2017-03-14T08:51:31.653167Z 0 [Note] Shutting down plugin 'binlog'
2017-03-14T08:51:31.653330Z 0 [Note] ./mysqld: Shutdown complete

bogon:bin shiguangsheng$
```