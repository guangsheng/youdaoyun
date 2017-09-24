1. ��������
2. �����ӱ��̳�������Ҫָ��Լ�������´��������������ȣ� ˵�����̳в���̳�������Լ��
3. �����������ɾ�Ĵ�����������Ӧ�����ݸ�Ϊ�����Ӧ�ӱ�

```sql
--�������Լ��  
create table person(id int primary key, name varchar(50), age int, sex int);
create table men ( check(sex = 1)) inherits (person);
create table women (check(sex = 0)) inherits (person);
create unique index men_pk on men (id);
create unique index women_pk on women (id);

--��INSERTΪ��˵��������������ʽ  
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

---����
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