REDOLOG MANAGEMENT

SELECTING GROUP,STATUS,MEMBER,MB FROM logfiles
select group#,STATUS ,MEMBERS,bytes/1024/1024 MB from v$log;


LOGSWITCHING MANUALLY
alter sytem switch logfile;


SELECTING GROUP,MEMBER in logfiles

set lines 300;
col member for a80;
select GROUP#, MEMBER from V$logfile order by 1;

mkdir -p /u01/duplex/

ADDING MEMBER IN LOGFILE
alter database add logfile member '/u01/duplex/redo_1_03.log' to group 1;
alter database add logfile member '/u01/duplex/redo_2_03.log' to group 2;
alter database add logfile member '/u01/duplex/redo_3_03.log' to group 3;


/u01/duplex/redo_4_03.log


ADDING GROUP with REDOLOGFILE MEMBERS in size:200mb

alter database add logfile group 4 ('/u01/duplex/redo_4_03.log','/u01/app/oracle/oradata/PRODDB/onlinelog/redo_4_02.log','/u01/app/oracle/fast_recovery_area/PRODDB/onlinelog/redo_4_01.log') size 200M;


DROPPING LOGFILE MEMBER
alter database drop logfile member '/u01/duplex/redo_1_03.log';
alter database drop logfile member '/u01/duplex/redo_2_03.log';
alter database drop logfile member '/u01/duplex/redo_3_03.log';
alter database drop logfile member '/u01/duplex/redo_4_03.log';


ALTER DATABASE DROP LOGFILE GROUP 4;

/u01/duplex/redo_4_03.log
