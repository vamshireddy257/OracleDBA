check your connection;

select instance_name, con_id, version from v$instance;

col name for a30
select dbid, con_id, name from v$pdbs;

select name, con_id, db_unique_name from v$database;

select dbid, con_id, name from V$PDBS;

alter session set container = hrms;

alter session set container = CDB$ROOT;

select dbid, con_id, name from v$pdbs;

col CON_NAME for a32;
col DB_NAME for a32;
col CON_ID for a32;
select sys_context('USERENV','CON_NAME') CON_NAME,
            sys_context('USERENV','CON_ID') CON_ID,
            sys_context('USERENV','DB_NAME') DB_NAME from DUAL;

			
alter system set sga_target=300M scope=both;

set linesize 120
column pdb_name format a10
column name format a30
column value$ format a30

select ps.db_uniq_name,
       ps.pdb_uid,
       p.name as pdb_name,
       ps.name,
       ps.value$
from   pdb_spfile$ ps
       join v$pdbs p on ps.pdb_uid = p.con_uid
order by 1, 2, 3;

ALTER system SET open_cursors= 150 sid='*' scope=spfile;


alter pluggable database HRMS close immediate;
alter pluggable database HRMS open;
alter pluggable database all except loans open;
alter pluggable database all except savings close;

alter pluggable database HRMS unplug into '/u01/app/oracle/oradata/HRMS.xml';

drop pluggable database HRMS;

create pluggable database hrms using '/u01/app/oracle/oradata/HRMS.xml'
NOCOPY
TEMPFILE REUSE;

alter pluggable database PROD_HRMS unplug into '/u01/pdb2.xml';


ALTER PLUGGABLE DATABASE pdb5 CLOSE;
ALTER PLUGGABLE DATABASE PROD_HRMS UNPLUG INTO '/u01/pdb5.xml';

alter pluggable database HRMS save state;
alter pluggable database PDB3 save state;
alter pluggable database PDB4 save state;
alter pluggable database PDB5 save state;
alter pluggable database PDB6 save state;




select CON_NAME ,STATE from dba_pdb_saved_states;
alter pluggable database savings save state;
CREATE PLUGGABLE DATABASE hrms ADMIN USER pdb_adm IDENTIFIED BY Password1;

CREATE PLUGGABLE DATABASE pdb2 ADMIN USER pdb_adm IDENTIFIED BY Password1;

drop pluggable database pdb2 including datafiles;
CREATE PLUGGABLE DATABASE CURRENT_A ADMIN USER pdb_adm IDENTIFIED BY Password1;
CREATE PLUGGABLE DATABASE loans ADMIN USER pdb_adm IDENTIFIED BY Password1;
CREATE PLUGGABLE DATABASE demats ADMIN USER pdb_adm IDENTIFIED BY Password1;
CREATE PLUGGABLE DATABASE pdb6 ADMIN USER pdb_adm IDENTIFIED BY Password1;


CREATE PLUGGABLE DATABASE imps ADMIN USER pdb_adm IDENTIFIED BY Password1;


select username,  con_id from cdb_users ORDER BY 2;
select name , con_id from v$tablespace order by 2;
select TABLESPACE_NAME,con_id from cdb_tablespaces ORDER BY 2;


select username,  con_id from cdb_users  WHERE USERNAME = 'SCOTT' ORDER BY 2;

ALTER PLUGGABLE DATABASE loans UNPLUG INTO '/u01/loans.xml';

create pluggable database loans using '/u01/loans.xml'

alter pluggable database fd close;
alter pluggable database fd open read only;


!mkdir -p /home/oracle/oradata/FD_DUP

CREATE PLUGGABLE DATABASE fd_dup FROM fd;
--FILE_NAME_CONVERT=('/home/oracle/oradata/PDB1','/home/oracle/oradata/PDB2/');
