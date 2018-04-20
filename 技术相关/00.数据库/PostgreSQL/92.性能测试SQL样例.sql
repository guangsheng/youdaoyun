\timing
set synchronous_commit=off;
create table userinfo (userid int,info jsonb);
insert into userinfo select generate_series(1,2000000);
create table session (userid int,last_login timestamp);
insert into session select generate_series(1,2000000);
create table login_log (userid int,db_user name,client_addr inet,
                       client_port int,server_addr inet,server_port int,login_time timestamp);
set maintenance_work_mem='1GB';
alter table userinfo add constraint pk_userinfo primary key (userid);
alter table session add constraint pk_session primary key (userid);

postgres=> \dt+
                        List of relations
 Schema |      Name       | Type  | Owner  |  Size  | Description 
--------+-----------------+-------+--------+--------+-------------
 public | ha_health_check | table | aurora | 40 kB  | 
 public | login_log       | table | digoal | 141 MB | 
 public | session         | table | digoal | 75 MB  | 
 public | userinfo        | table | digoal | 69 MB  | 
(4 rows)

postgres=> \di+
                                   List of relations
 Schema |         Name         | Type  | Owner  |      Table      | Size  | Description 
--------+----------------------+-------+--------+-----------------+-------+-------------
 public | ha_health_check_pkey | index | aurora | ha_health_check | 16 kB | 
 public | login_log_pkey       | index | digoal | login_log       | 22 MB | 
 public | pk_session           | index | digoal | session         | 43 MB | 
 public | pk_userinfo          | index | digoal | userinfo        | 43 MB | 
(4 rows)

将数据加载到内存：
create extension pg_prewarm;
select pg_prewarm('userinfo');
select pg_prewarm('pk_userinfo');
select pg_prewarm('session');
select pg_prewarm('pk_session');

创建测试函数，包含3个操作：
1. 基于PK执行查询用户表，
2. 基于PK更新会话表，
3. 插入日志
共三个操作的事务，使用异步提交。
create or replace function f_test(i_id int) returns void as 
$$

declare
  v_t timestamp := now();
begin
  set synchronous_commit = off;
  perform 1 from userinfo where userid=i_id;
  update session set last_login=v_t where userid=i_id;
  insert into login_log (userid,db_user,client_addr,client_port,server_addr,server_port,login_time)
                        values (i_id,current_user,inet_client_addr(),inet_client_port(),inet_server_addr(),inet_server_port(),v_t);
  return;
end;

$$
 language plpgsql strict;

验证：
postgres=> select f_test(1);
 f_test 
--------
 
(1 row)
postgres=> select now(),* from session where userid=1;
              now              | userid |        last_login         
-------------------------------+--------+---------------------------
 2015-06-10 11:44:01.820262+08 |      1 | 2015-06-10 11:44:01.22805
(1 row)

测试机是阿里云的ECS（1核的ECS，也是较烂的性能了），与数据库在北京的不同机房（因为没找到同机房的ECS），测试：
vi test.sql
\setrandom id 1 2000000
select f_test(:id);
测试5分钟，每5秒输出一次tps统计，测试结果：
pgbench -M prepared -n -r -f ./test.sql -c 16 -j 16 -P 5 -h xxxx -p 3433 -U digoal -T 300 postgres
progress: 5.0 s, 2903.1 tps, lat 5.482 ms stddev 7.189
progress: 10.0 s, 3101.8 tps, lat 5.162 ms stddev 6.366
....
progress: 300.0 s, 3071.6 tps, lat 5.216 ms stddev 6.439
transaction type: Custom query
scaling factor: 1
query mode: prepared
number of clients: 16
number of threads: 16
duration: 300 s
number of transactions actually processed: 720287
latency average: 6.663 ms
latency stddev: 72.356 ms
tps = 2400.926759 (including connections establishing)
tps = 2401.013184 (excluding connections establishing)
statement latencies in milliseconds:
        0.002118        \setrandom id 1 2000000
        6.659889        select f_test(:id);
性能抖动分析，虽然拿不到数据库的日志，但是基本上判断和检查点有关，检查点时会产生刷脏数据的IO，因此更新会变慢，同时又开启了FPW，所以接下来的脏块写WAL BUFFER开销会变大，所以性能抖动严重，这个是需要优化的，但是IOPS是无法优化的硬伤。

再看看不带更新, 只有查询和插入的测试吧：
create or replace function f_test(i_id int) returns void as 
$$

declare
  v_t timestamp := now();
begin
  set synchronous_commit = off;
  perform 1 from userinfo where userid=i_id;
  -- update session set last_login=v_t where userid=i_id;
  insert into login_log (userid,db_user,client_addr,client_port,server_addr,server_port,login_time)
                        values (i_id,current_user,inet_client_addr(),inet_client_port(),inet_server_addr(),inet_server_port(),v_t);
  return;
end;

$$
 language plpgsql strict;

测试结果，性能相当平稳：
pgbench -M prepared -n -r -f ./test.sql -c 16 -j 16 -P 5 -h xxxx -p 3433 -U digoal -T 300 postgres
progress: 5.0 s, 3571.7 tps, lat 4.466 ms stddev 4.847
progress: 10.0 s, 3653.7 tps, lat 4.379 ms stddev 4.484
...
progress: 300.0 s, 3743.8 tps, lat 4.273 ms stddev 4.223
transaction type: Custom query
scaling factor: 1
query mode: prepared
number of clients: 16
number of threads: 16
duration: 300 s
number of transactions actually processed: 1101227
latency average: 4.357 ms
latency stddev: 4.453 ms
tps = 3670.717757 (including connections establishing)
tps = 3670.852824 (excluding connections establishing)
statement latencies in milliseconds:
        0.002000        \setrandom id 1 2000000
        4.354966        select f_test(:id);

cgroup