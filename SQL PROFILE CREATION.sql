drop table emp2 purge;
CREATE TABLE EMP2 AS SELECT * FROM EMP;

drop table dept2 purge;

CREATE TABLE DEPT2 AS SELECT * FROM DEPT;

BEGIN
FOR I IN 1..10
LOOP
INSERT INTO EMP2 SELECT * FROM EMP2;
COMMIT;
END LOOP;
END;
/

BEGIN
FOR I IN 1..10
LOOP
INSERT INTO DEPT2 SELECT * FROM DEPT2;
COMMIT;
END LOOP;
END;
/

select count(*) from emp2 ;
select count(*) from dept2 ;

explain plan for select  * from emp2 e,dept2 d where e.dept_no=d.dept_no order by e.dept_no;

select * from table(dbms_xplan.display(null,null,'ADVANCED'));
select * from table(dbms_xplan.display(null,null,'ADVANCED'));

select * from table(dbms_xplan.display());

------------------------
--TO CHECK PROFILES CREATED
COLUMN category FORMAT a10
COLUMN sql_text FORMAT a20
SELECT NAME,type, SQL_TEXT, CATEGORY, STATUS FROM DBA_SQL_PROFILES;

-- TO CHECK INTERNAL HINT FOR PROFILE
SELECT
a.name
,b.comp_data
FROM dba_sql_profiles a
,dbmshsxp_sql_profile_attr b
WHERE a.name = b.profile_name;
--TO DROP PROFILE
exec dbms_sqltune.drop_sql_profile('PROFILE_23yyk92xsubyq');

-----------------------------


-- run the query to generate sql_id
select  * from emp2 e,dept2 d where e.dept_no=d.dept_no order by e.dept_no;

-----
SELECT SQL_ID, SQL_TEXT
FROM V$SQL
WHERE SQL_TEXT LIKE 'select * from emp2 e,dept2 d where e.dept_no=d.dept_no order by e.dept_no'


DECLARE
  v_sql_tune_task_id  VARCHAR2(100);
BEGIN
  v_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          sql_id      => '6qtrpth9t86a7',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 10000,
                          task_name   => 'test_tuning_task5',
                          description => 'Tuning task for the SQL statement with the ID:6qtrpth9t86a7 from the cursor cache');
  DBMS_OUTPUT.put_line('v_sql_tune_task_id: ' || v_sql_tune_task_id);
END;
/

EXECUTE DBMS_SQLTUNE.execute_tuning_task(task_name => 'test_tuning_task5'); 
--approximately 2 min
set long 99999
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK( 'test_tuning_task5' ) FROM DUAL;

----
ANALYZE TABLE EMP2 COMPUTE STATISTICS;

ANALYZE TABLE DEPT2 COMPUTE STATISTICS;



---- USING MANUAL CREATION

create table TEST1(id number(10), text varchar2(100));
create table TEST2(id number(10), text2 varchar2(100));
insert into TEST1 values (10, 'First test table 1');
insert into TEST1 values (20, 'Second test table 1');
insert into TEST2 values (10, 'First test table 2');
insert into TEST2 values (20, 'Second test table 2');
commit;

explain plan for select a.id, b.text2 from TEST1 a, TEST2 b where a.id =20 and a.id=b.id;

set lines  200
set pages 100
select * from table(dbms_xplan.display(null,null,'ADVANCED'));

select a.id, b.text2 from TEST1 a, TEST2 b where a.id =20 and a.id=b.id;

explain plan for select /*+ LEADING (a b) */ a.id, b.text2 from TEST1 a, TEST2 b where a.id =20 and a.id=b.id;


SELECT SQL_ID, SQL_TEXT
FROM V$SQL
WHERE SQL_TEXT LIKE 'select a.id, b.text2 from TEST1 a, TEST2 b where a.id =20 and a.id=b.id%';

SELECT SQL_ID, SQL_TEXT
FROM V$SQL
WHERE SQL_TEXT LIKE 'select a.id, b.text2 from TEST1 a, TEST2 b where a.id =20 and a.id=b.id%';


DECLARE
  SQL_FTEXT CLOB;
BEGIN
SELECT SQL_FULLTEXT INTO SQL_FTEXT FROM V$SQLAREA WHERE SQL_ID = '23yyk92xsubyq';
 
DBMS_SQLTUNE.IMPORT_SQL_PROFILE(
  SQL_TEXT => SQL_FTEXT,
  PROFILE => SQLPROF_ATTR('LEADING(@"SEL$1" "A"@"SEL$1" "B"@"SEL$1")'),
  NAME => 'PROFILE_23yyk92xsubyq',
  REPLACE => TRUE,
  FORCE_MATCH => TRUE
);
END;
/
