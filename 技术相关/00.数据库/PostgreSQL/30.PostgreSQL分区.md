1. 创建主表
2. 创建子表（继承自主表，要指定约束和重新创建索引、主键等） 说明：继承不会继承索引、约束
3. 创建主表的增删改触发器，将相应的数据改为处理对应子表

```sql
--创建表和约束  
create table person(id int primary key, name varchar(50), age int, sex int);
create table men ( check(sex = 1)) inherits (person);
create table women (check(sex = 0)) inherits (person);
create unique index men_pk on men (id);
create unique index women_pk on women (id);

--以INSERT为例说明创建触发器方式  
CREATE OR REPLACE FUNCTION person_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.sex = 1 THEN
        INSERT INTO men VALUES (NEW.*);
    ELSE
        INSERT INTO women VALUES (NEW.*);
    END IF;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER person_insert_trigger
BEFORE INSERT ON person
FOR EACH ROW EXECUTE PROCEDURE person_insert_trigger();

---测试
insert into person values(1,'limin',12,1);
insert into person values(2,'hanmeimei',14,0);
insert into person values(3,'zhuhuayin',15,1);
insert into person values(4,'zhouzheng',16,1);
insert into person values(5,'zhuhuahua',17,0);

test_db=# select * from person;
 id |   name    | age | sex
----+-----------+-----+-----
  1 | limin     |  12 |   1
  3 | zhuhuayin |  15 |   1
  4 | zhouzheng |  16 |   1
  5 | zhuhuahua |  17 |   0
  2 | hanmeimei |  14 |   0
(5 rows)

test_db=# select * from only person;
 id | name | age | sex
----+------+-----+-----
(0 rows)

test_db=# select * from men;
 id |   name    | age | sex
----+-----------+-----+-----
  1 | limin     |  12 |   1
  3 | zhuhuayin |  15 |   1
  4 | zhouzheng |  16 |   1
(3 rows)

test_db=# select * from women;
 id |   name    | age | sex
----+-----------+-----+-----
  5 | zhuhuahua |  17 |   0
  2 | hanmeimei |  14 |   0
(2 rows)
```