CREATE TABLE products(name varchar(40),prod_id integer,supplier_id integer)DISTRIBUTED BY (prod_id);

CREATE TABLE foo (a int, b text) WITH (appendonly=true, compresstype=zlib, compresslevel=5) DISTRIBUTED BY (a);
insert into foo select generate_series(1,100000), 'test';
select * from get_ao_distribution('foo');
select * from get_ao_compression_ratio('foo');

CREATE TABLE test_1(
c1 int ENCODING (compresstype=zlib),
c2 varchar(10) ENCODING (compresstype=quicklz, blocksize=65536),
c3 varchar(10),
COLUMN c3 ENCODING (compresstype=RLE_TYPE)
) WITH (appendonly=true, orientation=column) DISTRIBUTED BY (c1);
insert into test_1 select generate_series(1,100000), 'c2', 'c3';
select get_ao_distribution('test_1');
select get_ao_compression_ratio('test_1');


CREATE TABLE test_2 (id int, amt decimal(10,2), create_date date) 
DISTRIBUTED BY (id)
PARTITION BY RANGE (create_date) ( START (date '2018-01-01') INCLUSIVE END (date '2019-01-01') EXCLUSIVE EVERY (INTERVAL '1 month') );
create sequence seq_sgs_test_1;
insert into test_2 select nextval('seq_sgs_test_1'), 1.01, generate_series('2018-01-01 01:00:01'::timestamp, '2018-12-31 23:59:59'::timestamp, '1 day');
explain select count(*) from test_2 where create_date >= '2018-02-01' and create_date <= '2018-02-28';
explain select * from test_2 where id = 101;
create index idx_test_2_id on test_2(id);
insert into test_2 select nextval('seq_sgs_test_1'), 1.01, generate_series('2018-01-01 01:00:01'::timestamp, '2018-12-31 23:59:59'::timestamp, '1 sec');
explain select * from test_2 where id = 1000;
explain select * from test_2_1_prt_7 where id = 1000;
analyze test_2;
explain select * from test_2 where id = 1000;
explain select * from test_2_1_prt_7 where id = 1000;

--------------FROM GREENPLUM BOOK BEGIN---------------------------
create table public.member_fatdt0(
  member_id varchar(64),
  phoneno varchar(20),
  dw_beg_date date,
  dw_end_date date,
  dtype char(1),
  dw_status char(1),
  dw_ins_date date
)
WITH (appendonly=true, compresstype=zlib, compresslevel=5)
DISTRIBUTED by (member_id)
PARTITION BY RANGE (dw_end_date)
(
PARTITION p20111201 START (date '2011-12-01') INCLUSIVE,
PARTITION p20111202 START (date '2011-12-02') INCLUSIVE,
PARTITION p20111203 START (date '2011-12-03') INCLUSIVE,
PARTITION p20111204 START (date '2011-12-04') INCLUSIVE,
PARTITION p20111205 START (date '2011-12-05') INCLUSIVE,
PARTITION p20111206 START (date '2011-12-06') INCLUSIVE,
PARTITION p20111207 START (date '2011-12-07') INCLUSIVE,
PARTITION p30000101 START (date '3000-12-31') INCLUSIVE
END (date '3001-01-01') EXCLUSIVE
);

create table public.member_delta(
  member_id varchar(64),
  phoneno varchar(20),
  action char(1),
  dw_ins_date date
)
WITH (appendonly=true, compresstype=zlib, compresslevel=5)
DISTRIBUTED by (member_id);

create table public.member_tmp0(
  member_id varchar(64),
  phoneno varchar(20),
  dw_beg_date date,
  dw_end_date date,
  dtype char(1),
  dw_status char(1),
  dw_ins_date date
)
WITH (appendonly=true, compresstype=zlib, compresslevel=5)
DISTRIBUTED by (member_id)
PARTITION BY LIST (dtype)
(
PARTITION PHIS VALUES('H'),
PARTITION PCUR VALUES('C'),
DEFAULT PARTITION other
);

create table public.member_tmp1(
  member_id varchar(64),
  phoneno varchar(20),
  dw_beg_date date,
  dw_end_date date,
  dtype char(1),
  dw_status char(1),
  dw_ins_date date
)
WITH (appendonly=true, compresstype=zlib, compresslevel=5)
DISTRIBUTED by (member_id);

1.dat
mem006,13100000006,I,2011-12-03
mem002,13100000002,D,2011-12-03
mem003,13100000003,U,2011-12-03
\copy member_delta from '/Users/shiguangsheng/Downloads/to_delete/1.dat' with delimiter ',';

2.dat
mem001,13100000001,2011-12-01,3000-12-31,C,I,2011-12-01
mem002,13100000002,2011-12-01,3000-12-31,C,I,2011-12-01
mem003,13100000003,2011-12-01,3000-12-31,C,I,2011-12-01
mem004,13100000004,2011-12-01,3000-12-31,C,I,2011-12-01
mem005,13100000005,2011-12-01,3000-12-31,C,I,2011-12-01
\copy member_fatdt0_1_prt_p30000101 from '/Users/shiguangsheng/Downloads/to_delete/2.dat' with delimiter ',';


insert into public.member_tmp0
select a.member_id, a.phoneno, a.dw_beg_date, 
       case when b.member_id is null then a.dw_end_date else date '2011-12-02' end as dw_end_date,
       case when b.member_id is null then 'C' else 'H' END AS DTYPE,
       case when b.member_id is null then a.dw_status else b.action END AS dw_status,
       date'2011-12-03'
  from public.member_fatdt0 a left join public.member_delta b on a.member_id = b.member_id
   and b.action in ('D', 'U')
   and a.dw_beg_date <= cast('2011-12-02' as date) -1 
   and a.dw_end_date > cast('2011-12-02' as date) -1 ;

insert into public.member_tmp0
select member_id, phoneno, '2011-12-02'::date, '3000-12-31'::date, 'C', action, '2011-12-03'::date
  from public.member_delta
 where action in ('I','U');


truncate table public.member_tmp1;
alter table public.member_tmp0 exchange partition for ('H') WITH table public.member_tmp1;
alter table public.member_fatdt0 exchange partition for ('2011-12-02') WITH table public.member_tmp1;

--------------FROM GREENPLUM BOOK END---------------------------