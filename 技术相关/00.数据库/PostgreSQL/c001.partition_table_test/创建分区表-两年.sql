------创建主表和索引
CREATE TABLE t_sgs_bike_point_data (
  guid varchar(36) NOT NULL,
  point_time timestamp NOT NULL,
  data_type varchar(16) NOT NULL,
  point_type varchar(16) not null,
  lng double precision not null,
  lat double precision not null,
  point_num int2 NOT NULL,
  geo_hash varchar(16) null,
  point_count bigint, 
  CONSTRAINT pk_t_sgs_bike_point_data PRIMARY KEY (guid)
);

CREATE INDEX idx_sgs_bike_point_data_geohash  ON t_sgs_bike_point_data (geo_hash, point_time, point_type);
CREATE INDEX idx_sgs_bike_point_data_type ON t_sgs_bike_point_data(data_type, point_type, point_time);
CREATE INDEX idx_sgs_point_data_point_time ON t_sgs_bike_point_data using brin (point_time) WITH (pages_per_range='16');

------创建触发器
CREATE OR REPLACE FUNCTION insert_sgs_bikepoint_data_trigger()
RETURNS TRIGGER AS $$
DECLARE 
 partition_date TEXT;
 partition TEXT; 
BEGIN
 partition_date := to_char(NEW.point_time,'YYYYMMDD'); 
 partition := TG_TABLE_NAME || '_' || partition_date;
 EXECUTE 'INSERT INTO ' || partition || ' SELECT(' || TG_TABLE_NAME || ' ' || quote_literal(NEW) || ').*;';
 RETURN NULL;
END;$$
LANGUAGE plpgsql;                      

CREATE TRIGGER insert_sgs_bikepoint_data
BEFORE INSERT ON t_sgs_bike_point_data
FOR EACH ROW EXECUTE PROCEDURE insert_sgs_bikepoint_data_trigger();

------按天创建分区表


/**
  * INPUT：in_begin_time/in_end_time 必须是有效的日期字符串且in_end_time在软件日期意义上要小于in_begin_time
  *     in_begin_time和in_end_time跨年的场景没有测试，建议不要使用
  */
CREATE OR REPLACE FUNCTION create_partition_sgs_point_data_by_day(
	in_begin_time varchar, in_end_time varchar)
RETURNS boolean AS $$
DECLARE
  sql_str varchar;
  date_str varchar;
  next_day_str varchar;
  v_date timestamp;
  partition_table_name varchar;
  v_partition_table_name varchar;
BEGIN
  FOR v_date IN SELECT generate_series(in_begin_time::date, in_end_time::date, '1 day' ) 
  			AS d LOOP
    date_str := to_char(v_date, 'YYYYMMDD');
    next_day_str := to_char(v_date + interval '1 day', 'YYYYMMDD');
    v_partition_table_name := 't_sgs_bike_point_data_'||date_str;

    --check whether the table exists
    SELECT table_name into partition_table_name FROM information_schema.tables
        WHERE table_name = v_partition_table_name;
    IF partition_table_name is not null then
      RAISE NOTICE '[NOTICE]% is exist!', partition_table_name;
    ELSE
      RAISE NOTICE 'create table for %', v_partition_table_name;
      --create table
      sql_str := 'CREATE TABLE '||v_partition_table_name||'( '||
                 'CONSTRAINT ck_sgs_bike_point_data_'||date_str||' '||
                 'CHECK(point_time >= DATE '''||date_str||''' AND point_time < DATE '''||next_day_str||''')) ' ||
                 'INHERITS (t_sgs_bike_point_data)';
	    execute sql_str;
      
      --create index
	    execute 'CREATE INDEX idx_sgs_bike_point_data_guid_'||date_str||' ON '||
	            v_partition_table_name||'(guid)';
	    execute  'CREATE INDEX idx_sgs_bike_point_data_geohash_'||date_str||' ON '||
	            v_partition_table_name||'(geo_hash, point_time, point_type)';
	    execute 'CREATE INDEX idx_sgs_bike_point_data_type_'||date_str||' ON '||
	            v_partition_table_name||'(data_type, point_type, point_time)';
	    execute 'CREATE INDEX idx_sgs_point_data_point_time_'||date_str||' ON '||
	            v_partition_table_name||' USING brin(point_time) '||
	            'WITH (pages_per_range=''16'')';
      
      --insert into test data
      sql_str :='insert into '|| v_partition_table_name || 
                    ' (guid, point_time,data_type,point_type,lng,lat,point_num,'||
                    '  geo_hash,point_count)'||
                    ' values '||
                    ' (1, '''||date_str||'''::timestamp, ''1'', ''1'', 1.0, 1.0, 1, ''1'',1) ';
      execute sql_str;
      --remove test data 
      execute 'truncate table '||v_partition_table_name;
	 END IF;
  END LOOP;
  RETURN true;
END;
$$ LANGUAGE plpgsql;

--2.批量创建表
select create_partition_sgs_point_data_by_day('2017-11-01', '2019-10-31');

--3.查看批量创建的表信息
select relname "child table", consrc "check"
  from pg_inherits i
       join pg_class c on c.oid = inhrelid
       join pg_constraint on c.oid = conrelid
 where contype = 'c'
   and inhparent = 't_sgs_bike_point_data'::regclass
 order by relname asc;

--4.给每张表插入一条数据
CREATE SEQUENCE seq_sgs_test_1 START 1;
insert into t_sgs_bike_point_data
       (guid, point_time, data_type, point_type, lng, lat, point_num, geo_hash, point_count)
select nextval('seq_sgs_test_1')::varchar, generate_series('2017-11-01'::timestamp, '2019-10-31'::timestamp, '1 day'), 
       'open_lock_data', 'M_1', 112.2237318, 30.3281193, 1, 2, 3;

select count(*) from t_sgs_bike_point_data;
select * from pg_stat_all_tables where relname like 't_sgs%' and n_live_tup <> 1;
select * from t_sgs_bike_point_data_20171231;
select * from t_sgs_bike_point_data_20191031;

--5.给每张表插入1440条数据 10080
insert into t_sgs_bike_point_data
       (guid, point_time, data_type, point_type, lng, lat, point_num, geo_hash, point_count)
select nextval('seq_sgs_test_1')::varchar, generate_series('2017-11-01 00:00:37'::timestamp, '2019-10-31 00:00:37'::timestamp, '1 min'), 
       'open_lock_data', 'M_1', 112.2237318, 30.3281193, 1, 2, 3;

----FAT环境，每天12240条数据
insert into t_sgs_bike_point_data
       (guid, point_time, data_type, point_type, lng, lat, point_num, geo_hash, point_count)
select nextval('seq_sgs_test_1')::varchar, generate_series('2017-11-01 00:00:37'::timestamp, '2017-12-31 23:59:59'::timestamp, '10 sec'), 
       'open_lock_data', 'M_1', 112.2237318, 30.3281193, 1, 2, 3;

insert into t_sgs_bike_point_data
       (guid, point_time, data_type, point_type, lng, lat, point_num, geo_hash, point_count)
select nextval('seq_sgs_test_1')::varchar, generate_series('2018-01-01 00:00:37'::timestamp, '2018-12-31 23:59:59'::timestamp, '1 min'), 
       'open_lock_data', 'M_1', 112.2237318, 30.3281193, 1, 2, 3;

insert into t_sgs_bike_point_data
       (guid, point_time, data_type, point_type, lng, lat, point_num, geo_hash, point_count)
select nextval('seq_sgs_test_1')::varchar, generate_series('2017-12-01 00:00:37'::timestamp, '2017-12-31 23:59:59'::timestamp, '5 sec'), 
       'open_lock_data', 'M_1', 112.2237318, 30.3281193, 1, 2, 3;

insert into t_sgs_bike_point_data
       (guid, point_time, data_type, point_type, lng, lat, point_num, geo_hash, point_count)
select nextval('seq_sgs_test_1')::varchar, generate_series('2017-12-01 00:00:00'::timestamp, '2017-12-01 23:59:59'::timestamp, '1 sec'), 
       'open_lock_data', 'M_1', 112.2237318, 30.3281193, 1, 2, 3;
--6.查询
\timing
explain analyze select count(*) from t_sgs_bike_point_data where point_time >= '2017-11-01'::timestamp and point_time < '2019-10-31'::timestamp;

explain analyze select count(*) from t_sgs_bike_point_data where point_time >= '2017-12-01'::timestamp and point_time < '2017-12-02'::timestamp;
explain analyze select count(*) from t_sgs_bike_point_data where point_time >= '2017-12-01'::timestamp and point_time < '2018-01-01'::timestamp;

explain analyze select count(*) from t_sgs_bike_point_data where point_time >= '2017-11-01'::timestamp and point_time < '2018-01-01'::timestamp;
explain analyze select count(*) from t_sgs_bike_point_data where point_time >= '2017-11-01'::timestamp and point_time < '2019-01-01'::timestamp;

