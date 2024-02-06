LOG MINERS

alter database add supplemental log data (ALL)columns;

select group#,STATUS ,MEMBERS,bytes/1024/1024 MB from v$log;
select member from v$logfile;

/u01/app/oracle/oradata/PRODDB/onlinelog/o1_mf_3_lrn5lkwn_.log
/u01/app/oracle/oradata/PRODDB/onlinelog/o1_mf_2_lrn5lkwd_.log
/u01/app/oracle/oradata/PRODDB/onlinelog/o1_mf_1_lrn5lkw2_.log

begin
dbms_logmnr.add_logfile(options => DBMS_LOGMNR.new,logfilename => '/u01/app/oracle/oradata/PRODDB/onlinelog/o1_mf_1_lrn5lkw2_.log');
end;
/

begin
dbms_logmnr.add_logfile(options => DBMS_LOGMNR.ADDFILE,logfilename => '/u01/app/oracle/oradata/PRODDB/onlinelog/o1_mf_2_lrn5lkwd_.log');
end;
/

begin
dbms_logmnr.add_logfile(options => DBMS_LOGMNR.ADDFILE,logfilename => '/u01/app/oracle/oradata/PRODDB/onlinelog/o1_mf_3_lrn5lkwn_.log');
end;
/


EXECUTE DBMS_LOGMNR.START_LOGMNR(OPTIONS => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG);

create table EMPLOYEES (sno number, name varchar2(20));


insert into EMPLOYEES values(1,'VAMSHI');

Commit complete.

col username for a30;
col SQL_REDO for a50
col SQL_UNDO for a50;

SELECT username, SQL_REDO, SQL_UNDO FROM V$LOGMNR_CONTENTS WHERE  seg_name = 'STUDENT';


EXECUTE DBMS_LOGMNR.END_LOGMNR
