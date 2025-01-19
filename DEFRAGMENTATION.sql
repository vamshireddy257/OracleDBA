select table_name,avg_row_len,round(((blocks*16/1024)),2)||'MB' "TOTAL_SIZE",
round((num_rows*avg_row_len/1024/1024),2)||'Mb' "ACTUAL_SIZE",
round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2) ||'MB' "FRAGMENTED_SPACE",
(round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*16/1024)),2))*100 "percentage"
from all_tables WHERE table_name='&TABLE_NAME';

EXEC dbms_stats.gather_table_stats(ownname => 'TABLE_OWNER', tabname => 'TABLE_NAME', method_opt=> 'for all indexed columns size skewonly', granularity => 'ALL', degree => 8 ,cascade => true,estimate_percent => 15);



CREATE TABLE STUDENT
       (STUDENTNO NUMBER(4),
	ENAME VARCHAR2(10),
	JOB VARCHAR2(9),
	MGR NUMBER(4),
	HIREDATE DATE,
	SAL NUMBER(7,2),
	COMM NUMBER(7,2),
	CLASSNO NUMBER(2));
INSERT INTO CLASS VALUES
	(10,'ACCOUNTING','NEW YORK');
INSERT INTO CLASS VALUES (20,'RESEARCH','DALLAS');
INSERT INTO CLASS VALUES
	(30,'SALES','CHICAGO');
INSERT INTO CLASS VALUES
	(40,'OPERATIONS','BOSTON');
INSERT INTO STUDENT VALUES
(7369,'SMITH','CLERK',7902,to_date('17-12-1980','dd-mm-yyyy'),800,NULL,20);
INSERT INTO STUDENT VALUES
(7499,'ALLEN','SALESMAN',7698,to_date('20-2-1981','dd-mm-yyyy'),1600,300,30);
INSERT INTO STUDENT VALUES
(7521,'WARD','SALESMAN',7698,to_date('22-2-1981','dd-mm-yyyy'),1250,500,30);
INSERT INTO STUDENT VALUES
(7566,'JONES','MANAGER',7839,to_date('2-4-1981','dd-mm-yyyy'),2975,NULL,20);
INSERT INTO STUDENT VALUES
(7654,'MARTIN','SALESMAN',7698,to_date('28-9-1981','dd-mm-yyyy'),1250,1400,30);
INSERT INTO STUDENT VALUES
(7698,'BLAKE','MANAGER',7839,to_date('1-5-1981','dd-mm-yyyy'),2850,NULL,30);
INSERT INTO STUDENT VALUES
(7782,'CLARK','MANAGER',7839,to_date('9-6-1981','dd-mm-yyyy'),2450,NULL,10);
INSERT INTO STUDENT VALUES
(7788,'SCOTT','ANALYST',7566,to_date('13-JUL-87')-85,3000,NULL,20);
INSERT INTO STUDENT VALUES
(7839,'KING','PRESIDENT',NULL,to_date('17-11-1981','dd-mm-yyyy'),5000,NULL,10);
INSERT INTO STUDENT VALUES
(7844,'TURNER','SALESMAN',7698,to_date('8-9-1981','dd-mm-yyyy'),1500,0,30);
INSERT INTO STUDENT VALUES
(7876,'ADAMS','CLERK',7788,to_date('13-JUL-87')-51,1100,NULL,20);
INSERT INTO STUDENT VALUES
(7900,'JAMES','CLERK',7698,to_date('3-12-1981','dd-mm-yyyy'),950,NULL,30);
INSERT INTO STUDENT VALUES
(7902,'FORD','ANALYST',7566,to_date('3-12-1981','dd-mm-yyyy'),3000,NULL,20);
INSERT INTO STUDENT VALUES
(7934,'MILLER','CLERK',7782,to_date('23-1-1982','dd-mm-yyyy'),1300,NULL,10);

BEGIN
FOR I IN 1..20
LOOP
INSERT INTO STUDENT SELECT * FROM STUDENT;
COMMIT;
END LOOP;
END;


create table STUDENT1 as select * from STUDENT;

select table_name,avg_row_len,round(((blocks*16/1024)),2)||'MB' "TOTAL_SIZE",
round((num_rows*avg_row_len/1024/1024),2)||'Mb' "ACTUAL_SIZE",
round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2) ||'MB' "FRAGMENTED_SPACE",
(round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*16/1024)),2))*100 "percentage"
from all_tables WHERE table_name='STUDENT';

delete from STUDENT where CLASSNO=20;
commit;

analyze table STUDENT compute statistics;

select table_name,avg_row_len,round(((blocks*16/1024)),2)||'MB' "TOTAL_SIZE",
round((num_rows*avg_row_len/1024/1024),2)||'Mb' "ACTUAL_SIZE",
round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2) ||'MB' "FRAGMENTED_SPACE",
(round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*16/1024)),2))*100 "percentage"
from all_tables WHERE table_name='STUDENT';


alter table STUDENT1 enable row movement;

alter table STUDENT move ;

alter table STUDENT move tablespace <tablespacename> ;


analyze table STUDENT compute statistics;

select table_name,avg_row_len,round(((blocks*16/1024)),2)||'MB' "TOTAL_SIZE",
round((num_rows*avg_row_len/1024/1024),2)||'Mb' "ACTUAL_SIZE",
round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2) ||'MB' "FRAGMENTED_SPACE",
(round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*16/1024)),2))*100 "percentage"
from all_tables WHERE table_name='STUDENT1';


alter table STUDENT1 shrink;
alter table STUDENT1 shrink compact;
alter table STUDENT1 shrick cascade;

alter table STUDENT1 shrink SPACE COMPACT;

expdp directory=datapump dumpfile=soe_student_030923.dmp logfile=soe_student_030923.log tables=soe.student 

impdp  directory=datapump dumpfile=soe_student_030923.dmp logfile=soe_student_030923_imp.log table_exists_action=truncate









for your practice:
create table emp2 as select * from emp;
run atleast 15 times.
insert into emp2 as select * from emp2;
fragmentation query ? -- no fragmentation
delete from emp2 where deptno = 20;
fragmentation query ? you will see fragmentation..
alter table emp2 move;
fragmentation query ? -- no fragmentation
delete from emp2 where deptno = 30;
fragmentation query ? you will see fragmentation..
alter table tablename shrink ;
fragmentation query ? -- no fragmentation
