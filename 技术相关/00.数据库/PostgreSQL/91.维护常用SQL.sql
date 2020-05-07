egrep "autovacuum_vacuum_scale_factor|autovacuum_analyze_scale_factor|wal_keep_segments|checkpoint_segments|checkpoint_timeout|log_autovacuum_min_duration|autovacuum_vacuum_cost_delay|track_activity_query_size|log_temp_files|vacuum_freeze_table_age|autovacuum_freeze_max_age|autovacuum_naptime|autovacuum_max_workers"


/**
   1. 修改表的autovacuum参数
   2. 重建主键索引
   3. 查询指定进程当前执行的sql
   4. 查询某个表的更新次数、活动记录、死记录和大小等信息
   5. 获取当前xlog位置
   6. 查询当前还在执行的执行时间最长的SQL
   7. 查询索引膨胀情况
   8. 查询表膨胀情况
   9. 查询checkpoint信息
   10. 查询当前某个配置参数的实际配置情况
   11. 查看数据库信息
   12. 获取数据库启动时间
   13. 显示那些当前准备好进行两阶段提交的事务的信息
   14. 显示所有当前会话中可用的预备语句
   15. 查询表空间信息
   16. 获取各表空间占用磁盘大小
   17. 获取各模式占用磁盘大小
   18. 查看指定表IO信息
   19. PostgreSQL去重
   20. 导出指定表的表结构
   21. 查看分区表约束信息
   22. 时间转换
   23. GB,MB等转数字
   24. 查询各应用使用的连接数
   25. copy命令使用
   26. 授权相关
   27. 查询结果分隔符修改
   28. 列定义
   29. 日志配置
   30. 查看表名称（不包含分区表的子表）
   31. 行转列
   32. 列转行
   33. 修改系统参数
   34. 查看权限
   35. bike_order plproxy使用说明
   36. 恢复user searchpath
   37. 按表总大小排序
   38. 查询当前登录用户
   39. 找出某个用户没有权限的表
   40. 继承关系修改
   41. 设置索引为 invalid 和 valid 必须是超级管理员
   42. 查看主从差异
   43. 导出表结构
**/



---1. 修改表的autovacuum参数
alter table t_bike_alert_live SET (autovacuum_vacuum_cost_delay=10, autovacuum_vacuum_cost_limit=10000, autovacuum_vacuum_scale_factor=0.02, autovacuum_analyze_scale_factor=0.02, 
toast.autovacuum_vacuum_cost_delay=10, toast.autovacuum_vacuum_scale_factor=0.05);
--确认修改情况
select relname, reloptions from pg_class where relname in ('t_bike_alert_20171020', 't_bike_alert_live');

---2. 重建主键索引
CREATE INDEX CONCURRENTLY t_bike_alert_live_pkey_new ON t_bike_alert_live(guid);
CREATE UNIQUE INDEX CONCURRENTLY t_bike_alert_live_pkey_new ON t_bike_alert_live(guid);
ALTER TABLE t_bike_alert_live DROP CONSTRAINT t_bike_alert_live_pkey;
ALTER TABLE t_bike_alert_live ADD CONSTRAINT t_bike_alert_live_pkey_new PRIMARY KEY USING INDEX t_bike_alert_live_pkey_new;
alter index t_bike_alert_live_pkey_new RENAME to t_bike_alert_live_pkey;

---3. 查询指定进程当前执行的sql
select query , query_start, now() from pg_stat_activity where pid = 1931;

---4. 查询某个表的更新次数、活动记录、死记录和大小等信息
select now(), relname, n_tup_ins, n_tup_upd, n_tup_del, n_live_tup, n_dead_tup from pg_stat_all_tables where relname = 't_bike_alert_live';
select now(), relname, relpages, reltuples, relpages/128 as size from pg_class 
 where relname in ('t_bike_alert_live','t_bike_alert_live_pkey','idx_bal_bike_no','idx_bike_alert_live_cityid');

---5. 获取当前xlog位置
select now(), pg_current_xlog_location();

---6. 查询当前还在执行的执行时间最长的SQL
SELECT now(), query, query_start,
       EXTRACT(EPOCH FROM NOW()) - EXTRACT(EPOCH FROM query_start) AS duration 
  FROM pg_stat_activity 
 WHERE state = 'active' 
   AND pid != pg_backend_pid()
   --and EXTRACT(EPOCH FROM NOW()) - EXTRACT(EPOCH FROM query_start)  > 5
 ORDER BY duration DESC 
 LIMIT 1;

---7. 查询索引膨胀情况
SELECT tblname, idxname, bs*(relpages)::bigint AS real_size,
  bs*(relpages-est_pages)::bigint AS extra_size,
  100 * (relpages-est_pages)::float / relpages AS extra_ratio,
  fillfactor, bs*(relpages-est_pages_ff) AS bloat_size,
  100 * (relpages-est_pages_ff)::float / relpages AS bloat_ratio,
  is_na
  -- , 100-(sub.pst).avg_leaf_density, est_pages, index_tuple_hdr_bm, maxalign, pagehdr, nulldatawidth, nulldatahdrwidth, sub.reltuples, sub.relpages -- (DEBUG INFO)
FROM (
  SELECT coalesce(1 +
       ceil(reltuples/floor((bs-pageopqdata-pagehdr)/(4+nulldatahdrwidth)::float)), 0 -- ItemIdData size + computed avg size of a tuple (nulldatahdrwidth)
    ) AS est_pages,
    coalesce(1 +
       ceil(reltuples/floor((bs-pageopqdata-pagehdr)*fillfactor/(100*(4+nulldatahdrwidth)::float))), 0
    ) AS est_pages_ff,
    bs, nspname, table_oid, tblname, idxname, relpages, fillfactor, is_na
    -- , stattuple.pgstatindex(quote_ident(nspname)||'.'||quote_ident(idxname)) AS pst, index_tuple_hdr_bm, maxalign, pagehdr, nulldatawidth, nulldatahdrwidth, reltuples -- (DEBUG INFO)
  FROM (
    SELECT maxalign, bs, nspname, tblname, idxname, reltuples, relpages, relam, table_oid, fillfactor,
      ( index_tuple_hdr_bm +
          maxalign - CASE -- Add padding to the index tuple header to align on MAXALIGN
            WHEN index_tuple_hdr_bm%maxalign = 0 THEN maxalign
            ELSE index_tuple_hdr_bm%maxalign
          END
        + nulldatawidth + maxalign - CASE -- Add padding to the data to align on MAXALIGN
            WHEN nulldatawidth = 0 THEN 0
            WHEN nulldatawidth::integer%maxalign = 0 THEN maxalign
            ELSE nulldatawidth::integer%maxalign
          END
      )::numeric AS nulldatahdrwidth, pagehdr, pageopqdata, is_na
      -- , index_tuple_hdr_bm, nulldatawidth -- (DEBUG INFO)
    FROM (
      SELECT
        i.nspname, i.tblname, i.idxname, i.reltuples, i.relpages, i.relam, a.attrelid AS table_oid,
        current_setting('block_size')::numeric AS bs, fillfactor,
        CASE -- MAXALIGN: 4 on 32bits, 8 on 64bits (and mingw32 ?)
          WHEN version() ~ 'mingw32' OR version() ~ '64-bit|x86_64|ppc64|ia64|amd64' THEN 8
          ELSE 4
        END AS maxalign,
        /* per page header, fixed size: 20 for 7.X, 24 for others */
        24 AS pagehdr,
        /* per page btree opaque data */
        16 AS pageopqdata,
        /* per tuple header: add IndexAttributeBitMapData if some cols are null-able */
        CASE WHEN max(coalesce(s.null_frac,0)) = 0
          THEN 2 -- IndexTupleData size
          ELSE 2 + (( 32 + 8 - 1 ) / 8) -- IndexTupleData size + IndexAttributeBitMapData size ( max num filed per index + 8 - 1 /8)
        END AS index_tuple_hdr_bm,
        /* data len: we remove null values save space using it fractionnal part from stats */
        sum( (1-coalesce(s.null_frac, 0)) * coalesce(s.avg_width, 1024)) AS nulldatawidth,
        max( CASE WHEN a.atttypid = 'pg_catalog.name'::regtype THEN 1 ELSE 0 END ) > 0 AS is_na
      FROM pg_attribute AS a
        JOIN (
          SELECT nspname, tbl.relname AS tblname, idx.relname AS idxname, idx.reltuples, idx.relpages, idx.relam,
            indrelid, indexrelid, indkey::smallint[] AS attnum,
            coalesce(substring(
              array_to_string(idx.reloptions, ' ')
               from 'fillfactor=([0-9]+)')::smallint, 90) AS fillfactor
          FROM pg_index
            JOIN pg_class idx ON idx.oid=pg_index.indexrelid
            JOIN pg_class tbl ON tbl.oid=pg_index.indrelid
            JOIN pg_namespace ON pg_namespace.oid = idx.relnamespace
          WHERE pg_index.indisvalid AND tbl.relkind = 'r' AND idx.relpages > 0
        ) AS i ON a.attrelid = i.indexrelid
        JOIN pg_stats AS s ON s.schemaname = i.nspname
          AND ((s.tablename = i.tblname AND s.attname = pg_catalog.pg_get_indexdef(a.attrelid, a.attnum, TRUE)) -- stats from tbl
          OR   (s.tablename = i.idxname AND s.attname = a.attname))-- stats from functionnal cols
        JOIN pg_type AS t ON a.atttypid = t.oid
      WHERE a.attnum > 0
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
    ) AS s1
  ) AS s2
    JOIN pg_am am ON s2.relam = am.oid --WHERE am.amname = 'btree'
) AS sub
WHERE 100 * (relpages-est_pages_ff)::float / relpages > 60
  --and (tblname like 't_bike_info' or tblname like 't_month_card' or tblname like 't_clients' or tblname like 't_bike_user\_%')
  and bs*(relpages)::bigint/1024/1024 > 100
ORDER BY bloat_size desc,bloat_ratio desc;

---8. 查询表膨胀情况
SELECT current_database(), schemaname, tblname, bs*tblpages AS real_size,
  (tblpages-est_tblpages)*bs AS extra_size,
  CASE WHEN tblpages - est_tblpages > 0
    THEN 100 * (tblpages - est_tblpages)/tblpages::float
    ELSE 0
  END AS extra_ratio, fillfactor, (tblpages-est_tblpages_ff)*bs AS bloat_size,
  CASE WHEN tblpages - est_tblpages_ff > 0
    THEN 100 * (tblpages - est_tblpages_ff)/tblpages::float
    ELSE 0
  END AS bloat_ratio, is_na
  -- , (pst).free_percent + (pst).dead_tuple_percent AS real_frag
FROM (
  SELECT ceil( reltuples / ( (bs-page_hdr)/tpl_size ) ) + ceil( toasttuples / 4 ) AS est_tblpages,
    ceil( reltuples / ( (bs-page_hdr)*fillfactor/(tpl_size*100) ) ) + ceil( toasttuples / 4 ) AS est_tblpages_ff,
    tblpages, fillfactor, bs, tblid, schemaname, tblname, heappages, toastpages, is_na
    -- , stattuple.pgstattuple(tblid) AS pst
  FROM (
    SELECT
      ( 4 + tpl_hdr_size + tpl_data_size + (2*ma)
        - CASE WHEN tpl_hdr_size%ma = 0 THEN ma ELSE tpl_hdr_size%ma END
        - CASE WHEN ceil(tpl_data_size)::int%ma = 0 THEN ma ELSE ceil(tpl_data_size)::int%ma END
      ) AS tpl_size, bs - page_hdr AS size_per_block, (heappages + toastpages) AS tblpages, heappages,
      toastpages, reltuples, toasttuples, bs, page_hdr, tblid, schemaname, tblname, fillfactor, is_na
    FROM (
      SELECT
        tbl.oid AS tblid, ns.nspname AS schemaname, tbl.relname AS tblname, tbl.reltuples,
        tbl.relpages AS heappages, coalesce(toast.relpages, 0) AS toastpages,
        coalesce(toast.reltuples, 0) AS toasttuples,
        coalesce(substring(
          array_to_string(tbl.reloptions, ' ')
          FROM '%fillfactor=#"__#"%' FOR '#')::smallint, 100) AS fillfactor,
        current_setting('block_size')::numeric AS bs,
        CASE WHEN version()~'mingw32' OR version()~'64-bit|x86_64|ppc64|ia64|amd64' THEN 8 ELSE 4 END AS ma,
        24 AS page_hdr,
        23 + CASE WHEN MAX(coalesce(null_frac,0)) > 0 THEN ( 7 + count(*) ) / 8 ELSE 0::int END
          + CASE WHEN tbl.relhasoids THEN 4 ELSE 0 END AS tpl_hdr_size,
        sum( (1-coalesce(s.null_frac, 0)) * coalesce(s.avg_width, 1024) ) AS tpl_data_size,
        bool_or(att.atttypid = 'pg_catalog.name'::regtype) AS is_na
      FROM pg_attribute AS att
        JOIN pg_class AS tbl ON att.attrelid = tbl.oid
        JOIN pg_namespace AS ns ON ns.oid = tbl.relnamespace
        JOIN pg_stats AS s ON s.schemaname=ns.nspname
          AND s.tablename = tbl.relname AND s.inherited=false AND s.attname=att.attname
        LEFT JOIN pg_class AS toast ON tbl.reltoastrelid = toast.oid
      WHERE att.attnum > 0 AND NOT att.attisdropped
        AND tbl.relkind = 'r'
      GROUP BY 1,2,3,4,5,6,7,8,9,10, tbl.relhasoids
      ORDER BY 2,3
    ) AS s
  ) AS s2
) AS s3
 WHERE tblname not like 'pg\_%'
 ORDER BY bloat_ratio DESC
 limit 10;
 
---9. 查询checkpoint信息
select * from pg_stat_bgwriter;
SELECT EXTRACT(EPOCH FROM NOW() - stats_reset) from pg_stat_bgwriter;

---10. 查询当前某个配置参数的实际配置情况
select current_setting('max_connections');

---11. 查看数据库信息
SELECT 
    d.oid as oid, 
    d.datname as path, 
    d.datname as database, 
    pg_catalog.pg_encoding_to_char(d.encoding) as encoding, 
    d.datcollate as lc_collate, 
    d.datctype as lc_ctype, 
    pg_catalog.pg_get_userbyid(d.datdba) as owner, 
    t.spcname as tablespace, 
    pg_catalog.pg_database_size(d.datname)/1024/1024 as size,
    AGE(datfrozenxid) as age, --age用于测量从上次冻结的XID到当前事务XID的数目
    pg_catalog.shobj_description(d.oid, 'pg_database') as description 
FROM pg_catalog.pg_database d 
    JOIN pg_catalog.pg_tablespace t on d.dattablespace = t.oid 
WHERE 
    d.datallowconn = 't' 
    AND d.datistemplate = 'n' 
ORDER BY 1;

---12. 获取数据库启动时间
SELECT pg_postmaster_start_time();


---13. 显示那些当前准备好进行两阶段提交的事务的信息
select * from pg_prepared_xacts;
---14. 显示所有当前会话中可用的预备语句
select * from pg_prepared_statements;

---15. 查询表空间信息
SELECT  
  n.oid AS oid, 
  current_database() || '.' || n.nspname AS path, 
  n.nspname AS schema, 
  n.nspname AS namespace, 
  current_database() AS database, 
  pg_catalog.pg_get_userbyid(n.nspowner) AS owner, 
  pg_catalog.obj_description(n.oid, 'pg_namespace') AS description 
FROM pg_catalog.pg_namespace n 
WHERE  
  n.nspname !~ '^pg_'  
  AND n.nspname <> 'information_schema' 
ORDER BY namespace;

---16. 获取各表空间占用磁盘大小
SELECT 
  SUM(pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename))::bigint)/1024/1024 as size, tablespace
  FROM pg_tables 
 GROUP by tablespace;

---17. 获取各模式占用磁盘大小
SELECT 
  SUM(pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename))::bigint)/1024/1024 as size, schemaname
  FROM pg_tables 
 GROUP by schemaname;
 
---18. 查看指定表IO信息
select * from pg_statio_all_tables where relname = 'men';

---19. PostgreSQL去重
select ctid, * from emp where ctid in (select min(ctid) from emp group by id); 
delete from emp where ctid not in (select min(ctid) from emp group by id); 

---20. 导出指定表的表结构
```pg_dump bikeoss -p 3434 --schema-only --encoding='UTF8' --table='bikeoss.t_bike_alert*' > t_bike_alert.sql ```

---21. 查看分区表约束信息
select relname "child table", consrc "check"
  from pg_inherits i
       join pg_class c on c.oid = inhrelid
       join pg_constraint on c.oid = conrelid
 where contype = 'c'
   and inhparent = 't_operate_order_inventory_list'::regclass
 order by relname asc;

--查看分区表主表
SELECT
    parent.relname      AS parent,
    max(child.relname)       AS child
FROM pg_inherits
    JOIN pg_class parent            ON pg_inherits.inhparent = parent.oid
    JOIN pg_class child             ON pg_inherits.inhrelid   = child.oid
--WHERE parent.relname like 't_%'
group by parent.relname
order by parent.relname;

select parent, max(child) as child, pg_size_pretty(sum(child_size)) as total_size
from (
SELECT
    parent.relname      AS parent,
    child.relname       AS child,
    pg_total_relation_size(child.relname::regclass) as child_size
FROM pg_inherits
    JOIN pg_class parent            ON pg_inherits.inhparent = parent.oid
    JOIN pg_class child             ON pg_inherits.inhrelid   = child.oid
) as b
group by 1 order by 1;

--查看业务表（排除分区表子表）
select relname from pg_class where relkind = 'r' and relname like 't\_%' and not exists(select 'x' from pg_inherits where pg_inherits.inhrelid = pg_class.oid) and relname not like '%201%' order by 1;

---22. 时间转换
select to_char(snap_ts,'YYYY-MM-DD HH24:MI:SS')

---23. GB,MB等转数字
select snap_ts, size, (size - lead(size) over(order by snap_ts desc)) as difference
  from 
    (
      select snap_ts, sum(size) as size
        from (
      select snap_id, snap_ts, datname, pg_size_pretty,
               case when pg_size_pretty ilike '%GB%' then to_number(pg_size_pretty, '9999999')*1024
                  when pg_size_pretty ilike '%MB%' then to_number(pg_size_pretty, '9999999')
                  when pg_size_pretty ilike '%KB%' then round(to_number(pg_size_pretty, '9999999')/1024)
                  else 0
               end as size
        from snap_pg_db_size) a
       group by snap_ts
       order by snap_ts desc
    ) t;

---24. 查询各应用使用的连接数
select now(),application_name, count(*) from pg_stat_activity where pid <> pg_backend_pid() group by 1,2 order by 2;
select application_name, datname, count(*) from pg_stat_activity where pid <> pg_backend_pid() group by application_name, datname order by 2;
select application_name, client_addr, count(*) from pg_stat_activity where pid <> pg_backend_pid() group by application_name, client_addr order by 1;
select application_name, datname, client_addr, count(*) from pg_stat_activity where pid <> pg_backend_pid() group by application_name, datname, client_addr order by 1,2;

---25. copy命令使用
COPY ( 
select bike_no,produce_time, bom_guid,bom_name 
  from t_bike_info t
 where exists (select 'x' from test_bike_no where bike_no = t.bike_no)
 )
 to '/var/tmp/sgs/bike_info.csv' with csv;

---26. 授权相关
grant select on all tables in schema  hello_moment to viewflowadmin  WITH GRANT OPTION;
grant select on all tables in schema  bike_order to viewflowadmin  WITH GRANT OPTION;
grant select on all tables in schema  power_bike to viewflowadmin  WITH GRANT OPTION;
grant select on all tables in schema  cms to viewflowadmin  WITH GRANT OPTION;
grant select on all tables in schema  bike_pay to viewflowadmin  WITH GRANT OPTION;
grant select on all tables in schema  bike to viewflowadmin  WITH GRANT OPTION;

GRANT SELECT, UPDATE, INSERT, DELETE ON all tables in schema bike TO bike_ext_user;


GRANT ALL ON TABLE t_coupon_group TO bike_market;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE t_coupon_group TO bike_market_rw;
GRANT SELECT ON TABLE t_coupon_group TO bike_market_ro;

ALTER DEFAULT PRIVILEGES IN SCHEMA hello_moment GRANT SELECT ON TABLES TO viewflowadmin WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA bike_order GRANT SELECT ON TABLES TO viewflowadmin WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA power_bike GRANT SELECT ON TABLES TO viewflowadmin WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA css GRANT SELECT ON TABLES TO viewflowadmin WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA bike_pay GRANT SELECT ON TABLES TO viewflowadmin WITH GRANT OPTION;

CREATE ROLE viewflowadmin LOGIN  ENCRYPTED PASSWORD 'xxxxx' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
GRANT CONNECT ON DATABASE sms to viewflowadmin;
GRANT USAGE ON SCHEMA sms TO viewflowadmin;
GRANT SELECT ON ALL TABLES IN SCHEMA  sms TO viewflowadmin with GRANT OPTION;
ALTER DEFAULT PRIVILEGES IN SCHEMA sms GRANT SELECT ON TABLES TO viewflowadmin WITH GRANT OPTION;


create user hellobike_ro encrypted password 'xxxx';
GRANT USAGE ON SCHEMA hello_pivot_bbs TO  hellobike_ro;
GRANT CONNECT ON DATABASE hello_pivot_bbs to hellobike_ro;
ALTER user  hellobike_ro set statement_timeout='30s';
ALTER user  hellobike_ro CONNECTION LIMIT 20;
GRANT SELECT ON ALL TABLES IN SCHEMA  hello_pivot_bbs TO hellobike_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA hello_pivot_bbs GRANT SELECT ON TABLES TO hellobike_ro;

GRANT USAGE ON SCHEMA powerbike_bos TO  hellobike_rw;
GRANT CONNECT ON DATABASE powerbike_bos to  hellobike_rw;
ALTER user  hellobike_rw set statement_timeout='100ms';
ALTER user  hellobike_rw CONNECTION LIMIT 3;
GRANT SELECT,update,insert,delete ON ALL TABLES IN SCHEMA powerbike_bos TO hellobike_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA powerbike_bos GRANT SELECT,update,insert,delete ON TABLES TO hellobike_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA power_ride_card GRANT SELECT,update,insert,delete ON TABLES TO hellobike_rw;
GRANT SELECT,update,insert,delete ON ALL TABLES IN SCHEMA power_ride_card TO hellobike_rw;


create user db_alphapay_account_meta_bi encrypted password 'XXXX';
ALTER user  db_alphapay_account_meta_bi set statement_timeout='180s';
GRANT USAGE ON SCHEMA db_alphapay_account_meta TO  db_alphapay_account_meta_bi;
GRANT CONNECT ON DATABASE db_alphapay_account_meta to db_alphapay_account_meta_bi;
GRANT SELECT ON ALL TABLES IN SCHEMA  db_alphapay_account_meta TO db_alphapay_account_meta_bi;
ALTER DEFAULT PRIVILEGES IN SCHEMA db_alphapay_account_meta GRANT SELECT ON TABLES TO db_alphapay_account_meta_bi;

---27. 查询结果分隔符修改
\a
\f ,
\o /home/shiguangsheng/t_city_level_info.csv
select * from t_city_level_info;
\q

---28. 列定义
select pg_catalog.format_type(a.atttypid, a.atttypmod) from pg_attribute as a where attname = 'city_code';

---29. 日志配置
log_line_prefix = '< %m %a %u %d %r %h >'  #打印时间，数据库名，用户名，应用程序名称等

---30. 查看表名称（不包含分区表的子表）
select relname
  from pg_class pc
 where relkind = 'r'
   and not exists (select 'x' from pg_inherits where inhrelid = pc.oid)
   and relname like 't\_%'
 order by 1;

---31. 行转列
select string_agg(pid::text, ',') from pg_stat_activity where pid <> pg_backend_pid();

---32. 列转行
select regexp_split_to_table(name, ',') from (
select row_to_json(b.*)::text as name from pg_stat_activity as b limit 1
) as a;

---33. 修改系统参数
alter system set autovacuum_max_workers=10

---34. 查看权限
select * from  information_schema.table_privileges;

---35. bike_order plproxy使用说明
psql -d bike_order -U bike_order -p 3433 -h 10.111.50.183
\timing

1224686170
select * from query_t_ride_info($$where guid = '15233998473271224686170' and user_new_id = '1224686170' and create_time = '2018-04-11 06:37:27.327' limit 1$$) limit 1;
select * from query_t_ride_info($$where user_new_id = '1038911872' and create_time >= '2018-07-21' limit 10$$) limit 10;

select *
  from query_t_ride_info($$where bike_no = '7910691591' and create_time >= '2018-08-08' and create_time < '2018-08-09'$$);

select sum(i)
 from dynamic_query($$select count(*) from v_t_ride_info where create_time >= '2018-07-16 00:00:00' and create_time < '2018-07-16 19:00:00'$$)
    as t(i bigint);

select sum(i)
 from dynamic_query($$select count(*) from v_t_ride_info where create_time >= '2018-07-15 00:00:00' and create_time < '2018-07-15 19:00:00'$$)
    as t(i bigint);

select sum(i)
 from dynamic_query_dba($$select count(*) from v_t_ride_info where create_time >= '2018-05-25' and create_time < '2018-05-25 08:30:00'$$)
    as t(i bigint);

select sum(i)
 from dynamic_query_dba($$select count(*) from v_t_ride_info where create_time >= '2018-05-24' and create_time < '2018-05-25'$$)
    as t(i bigint);

select sum(i)
 from dynamic_query_dba($$select count(*) from v_t_ride_info where create_time >= '2018-08-21' and create_time < '2018-08-22'$$)
    as t(i bigint);

select sum(i)
 from dynamic_query_dba($$select count(*) from v_t_ride_info where create_time >= '2018-04-19 18:08:00' and create_time < '2018-04-19 18:15:00'$$)
    as t(i bigint);


select * 
  from query_t_ride_info($$where user_guid = '3a8fe3942f6c437bb1074c733322b511' order by create_time desc limit 10$$);


---36. 恢复user searchpath
alter user jinchuan set search_path = default;


-- 37. 按表总大小排序
select datname, pg_size_pretty(pg_database_size(oid)) from pg_database where datname not in ('postgres', 'template0','template1');

select relname, pg_total_relation_size(oid) as total_size, pg_size_pretty(pg_total_relation_size(oid)) as pretty_size 
 from pg_class 
where relkind = 'r'
order by 2 desc limit 20;

select pg_size_pretty(sum(total_size)) from
(select relname, pg_total_relation_size(oid) as total_size, pg_size_pretty(pg_total_relation_size(oid)) as pretty_size 
 from pg_class 
where relkind = 'r'
order by 2 desc limit 20) as a;

-- 38. 查询当前登录用户
select * from current_user;

-- 39. 找出某个用户没有权限的表
select relname, pg_catalog.pg_get_userbyid(relowner) as owner, pg_catalog.array_to_string(relacl, E'\n  ') as relacl
  from pg_class
 where relkind = 'r' and relname like 't\_%'
   and pg_catalog.pg_get_userbyid(relowner) <> 'bike_rw'
   and pg_catalog.array_to_string(relacl, E'\n  ') not like '%bike_rw%';

-- 40. 继承关系修改
alter table t_ride_info_201701 NO INHERIT t_ride_info;

-- 41. 设置索引为 invalid 和 valid   必须是超级管理员
----设置为invalid
update pg_index set indisvalid=false where indexrelid='i_ii'::regclass;
----设置为valid
update pg_index set indisvalid=true where indexrelid='i_ii'::regclass;

---42. 查看主从差异
select usename,client_addr,pg_current_xlog_location(),sent_location,write_location,replay_location,pg_size_pretty(pg_xlog_location_diff(pg_current_xlog_location(), replay_location)) as diff from pg_stat_replication;

select usename,client_addr,pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn),sent_lsn,write_lsn,replay_lsn,pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)) as diff, state, sync_state from pg_stat_replication where application_name <>'standby1';

select client_addr,pg_current_xlog_location(),sent_location,write_location,replay_location,pg_size_pretty(pg_xlog_location_diff(pg_current_xlog_location(), replay_location)) as diff, pg_size_pretty(pg_xlog_location_diff(pg_current_xlog_location(), sent_location)) as sent_diff from pg_stat_replication;

---43. 导出表结构
pg_dump bike -p 3430 -h 10.111.50.187 -U bike --schema-only --encoding='UTF8' --table='t_student_award_record' |grep -v "^\-\-" |grep -v "^$" |grep -v "^SET " |grep -v "^REVOKE " |grep -v "^GRANT " 

---44. 锁信息
SELECT
    waiting_stm.datname        AS db_name,
    waiting_stm.usename        AS waiting_username,
    waiting_stm.application_name AS waiting_appname,
    replace(replace(replace(replace(waiting_stm.query,'''', ''),chr(34),''),E'\n',' '),E'\t',' ') AS waiting_query,
    (select pc.relname
       from pg_locks pl, pg_class pc
      where pl.pid = waiting.pid
        and pl.relation = pc.oid
        and pl.locktype = 'tuple'
      limit 1) AS waiting_table,
    (EXTRACT(epoch FROM (now() - waiting_stm.query_start)))::int AS waiting_duration,
    waiting_stm.state          AS waiting_query_state,
    waiting.pid                AS waiting_pid,
    other_stm.usename          AS other_username,
    other_stm.application_name AS other_appname,
    replace(replace(replace(replace(other_stm.query,'''', ''),chr(34),''),E'\n',' '),E'\t',' ') AS other_query,
    other.relation::regclass   AS other_table,
    now()                      AS snap_ts
FROM pg_catalog.pg_locks AS waiting
    JOIN pg_catalog.pg_stat_activity AS waiting_stm
         ON waiting_stm.pid = waiting.pid
    JOIN pg_catalog.pg_locks AS other
         ON (
             ( waiting.database = other.database AND waiting.relation  = other.relation )
             OR waiting.transactionid = other.transactionid )
    JOIN pg_catalog.pg_stat_activity AS other_stm
         ON other_stm.pid = other.pid
WHERE NOT waiting.GRANTED
  AND waiting_stm.query_start < now() - interval '0.1 second'
  AND waiting.pid <> other.pid;

---45. psql登录指定会话参数
psql options=-csession_preload_libraries=''

---46. 停掉指定应用的所有连接
select pid from pg_stat_activity where usename is not null and pid <> pg_backend_pid() and application_name = 'AppHelloHitchMatchService' and datname = 'hello_hitch_match';
do language plpgsql $$
declare
  v_pid integer;
begin
  for v_pid in select pid from pg_stat_activity where usename is not null and pid <> pg_backend_pid() and application_name = 'AppHelloHitchMatchService' and datname = 'hello_hitch_match'
  loop
      perform pg_terminate_backend(v_pid);
  end loop; 
end;
$$;
select pid from pg_stat_activity where usename is not null and pid <> pg_backend_pid() and application_name = 'AppHelloHitchMatchService' and datname = 'hello_hitch_match';

---47. 停掉指定用户连接的应用
do language plpgsql $$
declare
  v_pid integer;
begin
  for v_pid in select pid from pg_stat_activity where pid <> pg_backend_pid() and usename = 'bike_rw'
  loop
      perform pg_terminate_backend(v_pid);
  end loop; 
end;
$$;

---48. 查看表的列个数

select * from (
  select (select relname from pg_class where oid = pg_attribute.attrelid) as table_name, count(*) as column_num
    from pg_attribute
   where attnum >= 1
   group by attrelid
) as b
where b.table_name not like '%201%' and table_name like 't_%'
order by 2 desc;

---
select t3.nspname||'.'||t2.relname from pg_class t2  join pg_namespace t3 on t2.relnamespace=t3.oid where (t2.relname like 't\_%' or t2.relname like 'snap\_%') and t2.relkind in ('t','r','p') and age(relfrozenxid)> 400000000 order by age(relfrozenxid)

---
WITH RECURSIVE views AS (
   -- get the directly depending views
   SELECT v.oid::regclass AS view,
          1 AS level
   FROM pg_depend AS d
      JOIN pg_rewrite AS r
         ON r.oid = d.objid
      JOIN pg_class AS v
         ON v.oid = r.ev_class
   WHERE v.relkind = 'v'
     AND d.classid = 'pg_rewrite'::regclass
     AND d.refclassid = 'pg_class'::regclass
     AND d.deptype = 'n'
     AND d.refobjid = 't1'::regclass
UNION ALL
   -- add the views that depend on these
   SELECT v.oid::regclass,
          views.level + 1
   FROM views
      JOIN pg_depend AS d
         ON d.refobjid = views.view
      JOIN pg_rewrite AS r  
         ON r.oid = d.objid
      JOIN pg_class AS v    
         ON v.oid = r.ev_class
   WHERE v.relkind = 'v'   
     AND d.classid = 'pg_rewrite'::regclass
     AND d.refclassid = 'pg_class'::regclass
     AND d.deptype = 'n'   
     AND v.oid <> views.view  -- avoid loop
)
SELECT format('CREATE VIEW %s AS%s',
              view,
              pg_get_viewdef(view))
FROM views
GROUP BY view
ORDER BY max(level);