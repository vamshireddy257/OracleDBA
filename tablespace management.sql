tablespaces:
CHECK ALL TABLE_SPACES AVAILABLE:

SET LINESIZE 200

SELECT tablespace_name,
       block_size,
       extent_management,
       segment_space_management,
       status
FROM   dba_tablespaces
ORDER BY tablespace_name;


CHECK FREE SPACE:

SET PAGESIZE 140 LINESIZE 200;
set colsep |

SELECT tablespace_name,
       size_mb,
       free_mb,
       max_size_mb,
       max_free_mb,
       TRUNC((max_free_mb/max_size_mb) * 100) AS free_pct,
       ROUND((max_size_mb-max_free_mb)/max_size_mb*10,2) AS used_pct
FROM   (
        SELECT a.tablespace_name,
               b.size_mb,
               a.free_mb,
               b.max_size_mb,
               a.free_mb + (b.max_size_mb - b.size_mb) AS max_free_mb
        FROM   (SELECT tablespace_name,
                       TRUNC(SUM(bytes)/1024/1024) AS free_mb
                FROM   dba_free_space
                GROUP BY tablespace_name) a,
               (SELECT tablespace_name,
                       TRUNC(SUM(bytes)/1024/1024) AS size_mb,
                       TRUNC(SUM(GREATEST(bytes,maxbytes))/1024/1024) AS max_size_mb
                FROM   dba_data_files
                GROUP BY tablespace_name) b
        WHERE  a.tablespace_name = b.tablespace_name
       ) 
	   --where tablespace_name = 'USERS'
ORDER BY tablespace_name;


CHECK ALL THE DATAFILE OF A TABLESPACE

COLUMN file_name FORMAT A70;
SELECT file_id,
       file_name,
       ROUND(bytes/1024/1024) AS size_mb,
       ROUND(maxbytes/1024/1024) AS max_size_mb,
       autoextensible,
       increment_by,
       status
FROM   dba_data_files
WHERE  tablespace_name = 'USERS'
ORDER BY file_id;

OMF(oaracle managed file) location:=

show parameter DB_CREATE_FILE_DEST
alter system set DB_CREATE_FILE_DEST='/u01/tablespace' scope=both;


DDL ON TABLESPACE:

--Create TABLESPACE
Create tablespace HRMS_TS datafile '/u01/app/oracle/oradata/ICICI/datafile/HRMS_001.dbf' size 5M autoextend on;

-- Add a datafile to a tablespace
Alter tablespace HRMS_TS add datafile '/u01/app/oracle/oradata/ICICI/datafile/HRMS_002.dbf'  size 5M autoextend on;

-- Resize a datafile
alter database datafile '/u01/app/oracle/oradata/ICICI/datafile/HRMS_001.dbf' resize 10M;

alter database datafile '+DATA/ORADB/DATAFILE/users.279.1102165131' resize 150M;

-- Make a datafile offline/online

Alter database datafile '/u01/app/oracle/oradata/ICICI/datafile/HRMS_002.dbf' offline;

Alter database datafile '/u01/app/oracle/oradata/ICICI/datafile/HRMS_002.dbf' online;

-- Drop a datafile:

Alter tablespace USERS drop datafile '+DATA/ORADB/DATAFILE/users.279.1102165131';

-- Drop a tablespace without removing the physical database files.

drop tablespace TESTING;
Tablespace dropped.

select file_name from dba_data_files where tablespace_name='TESTING';

no rows selected

-- Drop tablespace including the physical datafiles.

drop tablespace TESTING including contents and datafiles;
Tablespace dropped.

UNDO:
KNOW YOUR DEFAULT UNDO TABLE SPACE;
SHOW PARAMETER UNDO_TABLESPACE;
select VALUE from v$parameter where NAME='undo_tablespace';

SET UNDO_RETENTION value at any time using:
SQL> ALTER SYSTEM SET UNDO_RETENTION = 2400;

CREATING UNDO TS:
CREATE UNDO TABLESPACE undotbs_02 DATAFILE '/u01/undo02.dbf' SIZE 2M REUSE AUTOEXTEND ON RETENTION NOGUARANTEE;

CHANGE UNDO TABLESPACE
ALTER SYSTEM SET UNDO_TABLESPACE = undotbs_02;

KNOW UNDO RETENTION
show parameter undo;

Enabling and disabling undo retention guarantee
SQL> ALTER TABLESPACE undotbs_02 RETENTION GUARANTEE;
SQL> ALTER TABLESPACE undotbs_02 RETENTION NOGUARANTEE;

CHECK IF YOUR UNDO HAS GUATENTEED RETENTION
select tablespace_name ,retention from dba_tablespaces where contents = 'UNDO';

TEMP

CHECK:

SET LINESIZE 255

COLUMN tablespace_name FORMAT A20
COLUMN file_name FORMAT A40

SELECT tf.tablespace_name,
       tf.file_name,
       tf.size_mb,
       f.free_mb,
       tf.max_size_mb,
       f.free_mb + (tf.max_size_mb - tf.size_mb) AS max_free_mb,
       RPAD(' '|| RPAD('X',ROUND((tf.max_size_mb-(f.free_mb + (tf.max_size_mb - tf.size_mb)))/max_size_mb*10,0), 'X'),11,'-') AS used_pct
FROM   (SELECT file_id,
               file_name,
               tablespace_name,
               TRUNC(bytes/1024/1024) AS size_mb,
               TRUNC(GREATEST(bytes,maxbytes)/1024/1024) AS max_size_mb
        FROM   dba_temp_files) tf,
       (SELECT TRUNC(SUM(bytes)/1024/1024) AS free_mb,
               file_id
        FROM dba_free_space
        GROUP BY file_id) f
WHERE  tf.file_id = f.file_id (+)
ORDER BY tf.tablespace_name,
         tf.file_name;

CHECK TEMPFILE DETAILS:
	 
SET LINESIZE 200
COLUMN file_name FORMAT A70

SELECT TABLESPACE_NAME,
		file_id,
       file_name,
       ROUND(bytes/1024/1024/1024) AS size_gb,
       ROUND(maxbytes/1024/1024/1024) AS max_size_gb,
       autoextensible,
       increment_by,
       status
FROM   dba_temp_files
ORDER BY file_name;

CREATE TEMP TABLESPACE

CREATE TEMPORARY TABLESPACE TEMP_NEW TEMPFILE '/database/PRODDB/datafile/temp__new_01.dbf' SIZE 10m autoextend on maxsize unlimited;

ALTER DATABASE DEFAULT TEMPORARY TABLESPACE TEMP_NEW;

select property_name,property_value from database_properties where property_name like '%DEFAULT%';

ALTER TABLESPACE TEMP ADD TEMPFILE '+DATAC1' SIZE 10G AUTOEXTEND ON NEXT 1G MAXSIZE 32767M;

who are using old temporary tablespace ( i.e. TEMP ) and kill them.

SELECT b.tablespace,b.segfile#,b.segblk#,b.blocks,a.sid,a.serial#,
a.username,a.osuser, a.status
FROM v$session a,v$sort_usage b
WHERE a.saddr = b.session_addr;



TEMP % Utilization

Query to check percentage (%) utilization of temp tablespace

select (s.tot_used_blocks/f.total_blocks)*100 as "percent used"
from (select sum(used_blocks) tot_used_blocks
from v$sort_segment where tablespace_name='TEMP') s,
(select sum(blocks) total_blocks
from dba_temp_files where tablespace_name='TEMP') f;


Top 10 queries using temp tablespace.

select * from (
select s.sid,
s.status,
s.sql_hash_value sesshash,
u.SQLHASH sorthash,
s.username,
u.tablespace,
sum(u.blocks*p.value/1024/1024) mbused ,
sum(u.extents) noexts,
nvl(s.module,s.program) proginfo,
floor(last_call_et/3600)||':'||
floor(mod(last_call_et,3600)/60)||':'||
mod(mod(last_call_et,3600),60) lastcallet
from v$sort_usage u,
v$session s,
v$parameter p
where u.session_addr = s.saddr
and p.name = 'db_block_size'
group by s.sid,s.status,s.sql_hash_value,u.sqlhash,s.username,u.tablespace,
nvl(s.module,s.program),
floor(last_call_et/3600)||':'||
floor(mod(last_call_et,3600)/60)||':'||
mod(mod(last_call_et,3600),60)
order by 7 desc,3)
where rownum < 11;

current sessions using temp.

SELECT sysdate,a.username, a.sid, a.serial#, a.osuser, 
(b.blocks*d.block_size)/1048576 MB_used, c.sql_text
FROM v$session a, v$tempseg_usage b, v$sqlarea c,
     (select block_size from dba_tablespaces where tablespace_name='TEMP') d
    WHERE b.tablespace = 'TEMP'
    and a.saddr = b.session_addr
    AND c.address= a.sql_address
    AND c.hash_value = a.sql_hash_value
    AND (b.blocks*d.block_size)/1048576 > 1024
    ORDER BY b.tablespace, 6 desc;


get DDL of tablespace

set heading off;
set echo off;
Set pages 999;
set long 90000;
spool ddl_tablespace.sql
select dbms_metadata.get_ddl('TABLE','EMPLOYEE','SCOTT') from DUAL; 
spool off
