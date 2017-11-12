create database partition_year;
create database partition_month;
create database partition_week;
create database partition_day;

--all database
------1. 创建主表和索引 t_part_test
CREATE TABLE t_part_test(
  guid varchar(36) NOT NULL,
  point_time timestamp NOT NULL,
  data_type varchar(16) NOT NULL,
  point_type varchar(16) not null,
  lng double precision not null,
  lat double precision not null,
  point_num int2 NOT NULL,
  geo_hash varchar(16) null,
  point_count bigint, 
  CONSTRAINT pk_t_part_test PRIMARY KEY (guid)
);

CREATE INDEX idx_t_part_test_geohash  ON t_part_test (geo_hash, point_time, point_type);
CREATE INDEX idx_t_part_test_type ON t_part_test(data_type, point_type, point_time);
CREATE INDEX idx_t_part_test_time ON t_part_test using brin (point_time) WITH (pages_per_range='16');

------2. 创建触发器
--for day
CREATE OR REPLACE FUNCTION insert_t_part_test_trigger()
RETURNS TRIGGER AS $$
DECLARE 
 partition_date TEXT;
 partition TEXT; 
BEGIN
 partition_date := to_char(NEW.point_time,'YYYYMMDD'); 
 partition := TG_TABLE_NAME || partition_date;
 EXECUTE 'INSERT INTO ' || partition || ' SELECT(' || TG_TABLE_NAME || ' ' || quote_literal(NEW) || ').*;';
 RETURN NULL;
END;$$
LANGUAGE plpgsql;                      

--for week
CREATE OR REPLACE FUNCTION insert_t_part_test_trigger()
RETURNS TRIGGER AS $$
DECLARE 
 partition_date TEXT;
 partition TEXT; 
BEGIN
 partition_date :=EXTRACT(ISOYEAR FROM  NEW.point_time)::varchar||'_'||EXTRACT(WEEK FROM  NEW.point_time)::varchar;
 partition := TG_TABLE_NAME || '_' || partition_date;
 EXECUTE 'INSERT INTO ' || partition || ' SELECT(' || TG_TABLE_NAME || ' ' || quote_literal(NEW) || ').*;';
 RETURN NULL;
END;$$
LANGUAGE plpgsql;  

--for month
CREATE OR REPLACE FUNCTION insert_t_part_test_trigger()
RETURNS TRIGGER AS $$
DECLARE 
 partition_date TEXT;
 partition TEXT; 
BEGIN
 partition_date := to_char(NEW.point_time,'YYYYMM'); 
 partition := TG_TABLE_NAME || '_' || partition_date;
 EXECUTE 'INSERT INTO ' || partition || ' SELECT(' || TG_TABLE_NAME || ' ' || quote_literal(NEW) || ').*;';
 RETURN NULL;
END;$$
LANGUAGE plpgsql;  

--for day/week/month
CREATE TRIGGER insert_t_part_test
BEFORE INSERT ON t_part_test
FOR EACH ROW EXECUTE PROCEDURE insert_t_part_test_trigger();

--for day
CREATE OR REPLACE FUNCTION create_partition_sgs_point_data(
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
    v_partition_table_name := 't_part_test'||date_str;

    --check whether the table exists
    SELECT table_name into partition_table_name FROM information_schema.tables
        WHERE table_name = v_partition_table_name;
    IF partition_table_name is not null then
      RAISE NOTICE '[NOTICE]% is exist!', partition_table_name;
    ELSE
      RAISE NOTICE 'create table for %', v_partition_table_name;
      --create table
      sql_str := 'CREATE TABLE '||v_partition_table_name||'( '||
                 'CONSTRAINT ck_t_part_test_data_'||date_str||' '||
                 'CHECK(point_time >= DATE '''||date_str||''' AND point_time < DATE '''||next_day_str||''')) ' ||
                 'INHERITS (t_part_test)';
	    execute sql_str;
      
      --create index
	    execute 'CREATE INDEX idx_t_part_test_guid_'||date_str||' ON '||
	            v_partition_table_name||'(guid)';
	    execute  'CREATE INDEX idx_t_part_test_geohash'||date_str||' ON '||
	            v_partition_table_name||'(geo_hash, point_time, point_type)';
	    execute 'CREATE INDEX idx_t_part_test_type_'||date_str||' ON '||
	            v_partition_table_name||'(data_type, point_type, point_time)';
	    execute 'CREATE INDEX idx_t_part_test_time_'||date_str||' ON '||
	            v_partition_table_name||' USING brin(point_time) '||
	            'WITH (pages_per_range=''16'')';
	 END IF;
  END LOOP;
  RETURN true;
END;
$$ LANGUAGE plpgsql;

--for week
CREATE OR REPLACE FUNCTION create_partition_sgs_point_data(
  in_begin_time varchar, in_end_time varchar)
RETURNS boolean AS $$
DECLARE
  sql_str varchar;
  week_str varchar;
  weekly_date timestamp;
  partition_table_name varchar;
  v_partition_table_name varchar;
  v_week_start varchar;
  v_week_end varchar;
  weekly_date_str varchar;
  v_week_sday varchar;
  v_next_week_sday varchar;
BEGIN
  FOR weekly_date IN SELECT generate_series(in_begin_time::date, in_end_time::date, '1 week' ) 
        AS d LOOP
    week_str := EXTRACT(ISOYEAR FROM  weekly_date)::varchar||
                '_'||EXTRACT(WEEK FROM  weekly_date)::varchar;
    v_partition_table_name := 't_part_test_'||week_str;

    weekly_date_str := to_char(weekly_date, 'YYYY-MM-DD');
    v_week_sday := (EXTRACT(ISODOW FROM weekly_date)-1)::varchar||' day';
    v_next_week_sday := (8-EXTRACT(ISODOW FROM weekly_date))::varchar||' day';
    
    sql_str := 'select to_char('''||weekly_date_str||'''::timestamp - interval '''||
                                  v_week_sday||''', ''YYYY-MM-DD'')';
    execute sql_str into v_week_start;
    sql_str := 'select to_char('''||weekly_date_str||'''::timestamp + interval '''||
                                  v_next_week_sday||''', ''YYYY-MM-DD'')';
    execute sql_str into v_week_end;

    --check whether the table exists
    SELECT table_name into partition_table_name FROM information_schema.tables
        WHERE table_name = v_partition_table_name;
    IF partition_table_name is not null then
      RAISE NOTICE '[NOTICE]% is exist!', partition_table_name;
    ELSE
      RAISE NOTICE 'create table for %', v_partition_table_name;
      --create table
      sql_str := 'CREATE TABLE '||v_partition_table_name||'( '||
                 'CONSTRAINT ck_st_part_test_'||week_str||' '||
                 'CHECK(point_time >= DATE '''||v_week_start||''' AND point_time < DATE '''||v_week_end||''')) ' ||
                 'INHERITS (t_part_test)';
      execute sql_str;
      
      --create index
      execute 'CREATE INDEX idx_t_part_test_guid_'||week_str||' ON '||
              v_partition_table_name||'(guid)';
      execute  'CREATE INDEX idx_t_part_test_geohash'||week_str||' ON '||
              v_partition_table_name||'(geo_hash, point_time, point_type)';
      execute 'CREATE INDEX idx_t_part_test_type_'||week_str||' ON '||
              v_partition_table_name||'(data_type, point_type, point_time)';
      execute 'CREATE INDEX idx_t_part_test_time_'||week_str||' ON '||
              v_partition_table_name||' USING brin(point_time) '||
              'WITH (pages_per_range=''16'')';
   END IF;
  END LOOP;
  RETURN true;
END;
$$ LANGUAGE plpgsql;

--for month
CREATE OR REPLACE FUNCTION create_partition_sgs_point_data(
  in_begin_time varchar, in_end_time varchar)
RETURNS boolean AS $$
DECLARE
  sql_str varchar;
  month_str varchar;
  weekly_date timestamp;
  partition_table_name varchar;
  v_partition_table_name varchar;
  v_month_start varchar;
  v_month_end varchar;
BEGIN
  FOR weekly_date IN SELECT generate_series(in_begin_time::date, in_end_time::date, '1 month' ) 
        AS d LOOP
    month_str := to_char(weekly_date, 'YYYYMM');
    v_partition_table_name := 't_part_test_'||month_str;

    v_month_start=month_str||'01';
    sql_str := 'select to_char('''||v_month_start||'''::timestamp + interval ''1 month'', ''YYYY-MM-DD'')';
    execute sql_str into v_month_end;

    --check whether the table exists
    SELECT table_name into partition_table_name FROM information_schema.tables
        WHERE table_name = v_partition_table_name;
    IF partition_table_name is not null then
      RAISE NOTICE '[NOTICE]% is exist!', partition_table_name;
    ELSE
      RAISE NOTICE 'create table for %', v_partition_table_name;
      --create table
      sql_str := 'CREATE TABLE '||v_partition_table_name||'( '||
                 'CONSTRAINT ck_t_part_test_'||month_str||' '||
                 'CHECK(point_time >= DATE '''||v_month_start||''' AND point_time < DATE '''||v_month_end||''')) ' ||
                 'INHERITS (t_part_test)';
      execute sql_str;
      
      --create index
      execute 'CREATE INDEX idx_t_part_test_guid_'||month_str||' ON '||
              v_partition_table_name||'(guid)';
      execute  'CREATE INDEX idx_t_part_test_geohash'||month_str||' ON '||
              v_partition_table_name||'(geo_hash, point_time, point_type)';
      execute 'CREATE INDEX idx_t_part_test_type_'||month_str||' ON '||
              v_partition_table_name||'(data_type, point_type, point_time)';
      execute 'CREATE INDEX idx_t_part_test_time_'||month_str||' ON '||
              v_partition_table_name||' USING brin(point_time) '||
              'WITH (pages_per_range=''16'')';
   END IF;
  END LOOP;
  RETURN true;
END;
$$ LANGUAGE plpgsql;


--2.批量创建表
select create_partition_sgs_point_data('2017-01-01', '2018-12-31');


--3.查看批量创建的表信息
select relname "child table", consrc "check"
  from pg_inherits i
       join pg_class c on c.oid = inhrelid
       join pg_constraint on c.oid = conrelid
 where contype = 'c'
   and inhparent = 't_part_test'::regclass
 order by relname asc;



--4.基础数据1亿条
--for month 4166666.66667
--for week  961538.461538
--for day   136986.30137
--2year=730day=17520hour=1051200min=63072000sec
CREATE SEQUENCE seq_sgs_test_1 START 1;
#### 前174960行记录
insert into t_part_test(guid, point_time, data_type, point_type, lng, lat, point_num, geo_hash, point_count) 
  select nextval('seq_sgs_test_1')::varchar, 
         generate_series('2017-01-01'::timestamp, '2018-12-30 23:59:59'::timestamp, '6 min'), 
         'open_lock_data', 'M_1', 112.2237318, 30.3281193, 1, 2, 3;

#########
-- 准备基础数据 550*174960=96228000
test_partition.sql
insert into t_part_test(guid, point_time, data_type, point_type, lng, lat, point_num, geo_hash, point_count) select nextval('seq_sgs_test_1')::varchar, generate_series('2017-01-01'::timestamp, '2018-12-30 23:59:59'::timestamp, '6 min'), 'open_lock_data', 'M_1', 112.2237318, 30.3281193, 1, 2, 3;

test.sh
echo "day"
echo "`date`" >> time.log
time pgbench -n -f test_partition.sql -c 10 -t 55 -p 3434 -d  partition_day -U postgres >> partition_day.log 2>&1
echo "week"
echo "`date`" >> time.log
time pgbench -n -f test_partition.sql -c 10 -t 55 -p 3434 -d  partition_week -U postgres >> partition_week.log 2>&1
echo "month" >> time.log
echo "`date`" >> time.log
time pgbench -n -f test_partition.sql -c 10 -t 55 -p 3434 -d  partition_month -U postgres >> partition_month.log 2>&1
echo "year" >> time.log
echo "`date`" >> time.log
time pgbench -n -f test_partition.sql -c 10 -t 55 -p 3434 -d  partition_year -U postgres >> partition_year.log 2>&1
echo "`date`" >> time.log

nohup bash test.sh &

---5. 循环插入、更新、删除或查询100000条记录，实际上都是往同一张表插入
--- pgbench -n -f test.sql -c 1 -t 100000 -p 3434 -d  partition_year -U postgres
insert into t_part_test(guid, point_time, data_type, point_type, lng, lat, point_num, geo_hash, point_count) select 'abcdefg', now(), 'open_lock_data', 'M_1', 112.2237318, 30.3281193, 1, 2, 3;
select * from t_part_test where guid='abcdefg';
update t_part_test set point_time = now() where guid='abcdefg';
delete from t_part_test where guid='abcdefg';

---6. 循环插入、更新、删除或查询100000条记录，实际上都是往同一张表插入，同时限制查询时间
--- pgbench -n -f test.sql -c 1 -t 100000 -p 3434 -d  partition_year -U postgres
insert into t_part_test(guid, point_time, data_type, point_type, lng, lat, point_num, geo_hash, point_count) select 'abcdefg', now(), 'open_lock_data', 'M_1', 112.2237318, 30.3281193, 1, 2, 3;
select * from t_part_test where guid='abcdefg' and point_time >= '2017-11-01'::timestamp and point_time <= '2017-11-02'::timestamp;
update t_part_test set point_time = now() where guid='abcdefg' and point_time >= '2017-11-01'::timestamp and point_time <= '2017-11-02'::timestamp;
delete from t_part_test where guid='abcdefg' and point_time >= '2017-11-01'::timestamp and point_time <= '2017-11-02'::timestamp;
