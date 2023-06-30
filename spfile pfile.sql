check the parameter 
show parameter parameter name;
show parameter open_cursors;
CREATE PFILE FROM SPFILE;
CREATE PFILE FROM SPFILE;

CREATE SPFILE FROM PFILE='Location of the PFILE';

Alter system set db_recovery_file_dest_size=20g scope = memory;

alter system set db_recovery_file_dest_size=10g scope = spfile;
Alter system set db_recovery_file_dest_size=8256M scope = both;
alter system set db_recovery_file_dest_size=10g scope = memory;
STARTUP PFILE=singleline_init.ora
ALTER SYSTEM RESET OPEN_CURSORS SID='*' SCOPE='SPFILE';0
ALTER SYSTEM SET OPEN_CURSORS=500 SID='SID1' SCOPE='SPFILE'; 
SQL> select name, value from v$parameter where name = 'control_files';

SQL> startup nomount pfile='/scratch/u01/app/oracle/product/12.1.0/dbhome_1/dbs/inittdps.ora';

CREATE SPFILE='/u01/oracle/dbs/spfile.ora' FROM PFILE='/u01/oracle/dbs/init.ora';

check if parameter is modifiable:
SELECT  name,issys_modifiable m_INSTANCE, isses_modifiable m_SESSION  FROM V$parameter WHERE name = 'shared_pool_size';


---
SELECT  name,
case when issys_modifiable = 'FALSE' then 'STATIC'
when issys_modifiable =  'IMMEDIATE' then 'DYNAMIC' end m_INSTANCE, 
case when isses_modifiable = 'FALSE' then 'STATIC'
when isses_modifiable = 'TRUE' then 'DYNAMIC' end  m_SESSION  FROM V$parameter order by 1;
---

/u01/app/oracle/oradata/PRODDB/controlfile/o1_mf_k25kxfxt_.ctl, /u01/app/oracle/fast_recovery_area/PRODDB/controlfile/o1_mf_k25kxfy9_.ctl,/
