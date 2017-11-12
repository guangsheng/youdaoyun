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
22. 查询分区表信息
**/

--1. 修改表的autovacuum参数
alter table t_bike_alert_live SET (autovacuum_vacuum_cost_delay=10, autovacuum_vacuum_cost_limit=10000, autovacuum_vacuum_scale_factor=0.02, autovacuum_analyze_scale_factor=0.02, 
toast.autovacuum_vacuum_cost_delay=10, toast.autovacuum_vacuum_scale_factor=0.05);
--确认修改情况
select relname, reloptions from pg_class where relname in ('t_bike_alert_20171020', 't_bike_alert_live');

--2. 重建主键索引
CREATE UNIQUE INDEX CONCURRENTLY t_bike_alert_live_pkey_new ON t_bike_alert_live(guid);
ALTER TABLE t_bike_alert_live DROP CONSTRAINT t_bike_alert_live_pkey;
ALTER TABLE t_bike_alert_live ADD CONSTRAINT t_bike_alert_live_pkey_new PRIMARY KEY USING INDEX t_bike_alert_live_pkey_new;
alter index t_bike_alert_live_pkey_new RENAME to t_bike_alert_live_pkey;

--3. 查询指定进程当前执行的sql
select query , query_start, now() from pg_stat_activity where pid = 1931;

--4. 查询某个表的更新次数、活动记录、死记录和大小等信息
select now(), relname, n_tup_ins, n_tup_upd, n_tup_del, n_live_tup, n_dead_tup from pg_stat_all_tables where relname = 't_bike_alert_live';
select now(), relname, relpages, reltuples, relpages/128 as size from pg_class 
 where relname in ('t_bike_alert_live','t_bike_alert_live_pkey','idx_bal_bike_no','idx_bike_alert_live_cityid');

--5. 获取当前xlog位置
select now(), pg_current_xlog_location();

--6. 查询当前还在执行的执行时间最长的SQL
  SELECT now(), query, query_start,
         EXTRACT(EPOCH FROM NOW()) - EXTRACT(EPOCH FROM query_start) AS duration 
    FROM pg_stat_activity 
   WHERE state = 'active' 
     AND pid != pg_backend_pid()
     --and EXTRACT(EPOCH FROM NOW()) - EXTRACT(EPOCH FROM query_start)  > 5
   ORDER BY duration DESC 
   LIMIT 1;

--7. 查询索引膨胀情况
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
    JOIN pg_am am ON s2.relam = am.oid WHERE am.amname = 'btree'
) AS sub
WHERE NOT is_na and tblname like 't_%' and (100 * (relpages-est_pages_ff)::float / relpages)> 40
ORDER BY 2,3,4 ;

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
 WHERE NOT is_na and schemaname='bikeoss'
 ORDER BY bloat_ratio DESC;
 
--9. 查询checkpoint信息
select * from pg_stat_bgwriter;
SELECT EXTRACT(EPOCH FROM NOW() - stats_reset) from pg_stat_bgwriter;

--10. 查询当前某个配置参数的实际配置情况
select current_setting('max_connections');

--11. 查看数据库信息
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

--12. 获取数据库启动时间
SELECT pg_postmaster_start_time();


--13. 显示那些当前准备好进行两阶段提交的事务的信息
select * from pg_prepared_xacts;
--14. 显示所有当前会话中可用的预备语句
select * from pg_prepared_statements;

--15. 查询表空间信息
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

--16. 获取各表空间占用磁盘大小
SELECT 
  SUM(pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename))::bigint)/1024/1024 as size, tablespace
  FROM pg_tables 
 GROUP by tablespace;

--17. 获取各模式占用磁盘大小
SELECT 
  SUM(pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename))::bigint)/1024/1024 as size, schemaname
  FROM pg_tables 
 GROUP by schemaname;
 
--18. 查看指定表IO信息
select * from pg_statio_all_tables where relname = 'men';

--19. PostgreSQL去重
select ctid, * from emp where ctid in (select min(ctid) from emp group by id); 
delete from emp where ctid not in (select min(ctid) from emp group by id); 

--20. 导出指定表的表结构
```pg_dump bikeoss -p 3434 --schema-only --encoding='UTF8' --table='bikeoss.t_bike_alert*' > t_bike_alert.sql ```
--21. 查看分区表约束信息
select relname "child table", consrc "check"
  from pg_inherits i
       join pg_class c on c.oid = inhrelid
       join pg_constraint on c.oid = conrelid
 where contype = 'c'
   and inhparent = 't_ride_info'::regclass
 order by relname asc;

--22. 查询分区表信息
select relname "child table", consrc "check"
  from pg_inherits i
       join pg_class c on c.oid = inhrelid
       join pg_constraint on c.oid = conrelid
 where contype = 'c'
   and inhparent = 't_bike_point_data'::regclass
 order by relname asc;


------
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

