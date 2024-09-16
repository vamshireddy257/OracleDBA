1. Pre-Checks / Pre-Steps
2. Manual Upgrade using command Steps
3. Post upgrade Steps


========================
1.1: Install 19c Binary:
========================

mkdir -p /u01/app/oracle/product/19.0.0.0/dbhome_1
chmod 777 /u01
chown -R oracle:oinstall /u01

    
        
          
    

        
        Expand All
    
    @@ -17,202 +23,127 @@ chown -R oracle: /u01
  
go to software location
unzip V982063-01_19c_db.zip -d /u01/app/oracle/product/19.0.0.0/dbhome_1/
chmod -R 777 /u01
chown -R oracle: /u01
cd /u01/app/oracle/product/19.0.0.0/dbhome_1/
./runInstaller

====================================
1.2 Execute the pre-upgrade command:
====================================
mkdir -p /u01/upgradelogs

/u01/app/oracle/product/12.2.0/dbhome_1/jdk/bin/java -jar /u01/app/oracle/product/19.0.0.0/dbhome_1/rdbms/admin/preupgrade.jar FILE DIR /u01/upgradelogs


@/u01/upgradelogs/preupgrade_fixups.sql

========================================
1.3. Refresh Materialized Views if any:
========================================

declare
list_failures integer(3) :=0;
begin
DBMS_MVIEW.REFRESH_ALL_MVIEWS(list_failures,'C','', TRUE, FALSE);
end;
/ 

=================================
1.4: Manually gather statistics:
=================================

exec dbms_stats.gather_fixed_objects_stats;

exec dbms_stats.gather_schema_stats ('SYSTEM');

exec dbms_stats.gather_schema_stats ('SYS');

exec dbms_stats.gather_dictionary_stats;

==============================
1.5: Active Backup Validation:
==============================

SELECT * FROM v$recover_file;

SELECT * FROM v$backup WHERE status != 'NOT ACTIVE';

========================================
1.6: Default Tablespace for SYS & SYSTEM:
========================================

SELECT USERNAME,default_tablespace from dba_users where username in ('SYS','SYSTEM') ;

=============================
1.8: Invalid Objects compile:
=============================

select owner, count(*) from dba_objects where status <> 'VALID'group by owner;

@$ORACLE_HOME/rdbms/admin/utlrp.sql

=========================================== 
1.9: Component’s version along with status: 
===========================================

set lines 333 pages 111
col COMP_NAME form a55
select comp_name, version, status from dba_registry;

=============================== 
1.10: Empty Database Recyclebin:
===============================
purge DBA_RECYCLEBIN;

select count(*) from DBA_RECYCLEBIN;

show parameter sec_case_sensitive_logon

==============
1.11: Timezone
==============
COL PROPERTY_NAME FOR A25
COL PROPERTY_VALUE FOR A21
Select version from v$timezone_file;

select PROPERTY_NAME,PROPERTY_VALUE from database_properties where property_name ='DST_PRIMARY_TT_VERSION';

show parameter cluster_database

================ 
1.12 Create GRP:
================

COL NAME FOR A25
COL GUARANTEE_FLASHBACK_DATABASE FOR A31
select NAME,GUARANTEE_FLASHBACK_DATABASE,TIME from V$restore_point;

create restore point PRE_UPGRADE guarantee flashback database;

=====================
1.13: Database Backup:
=====================

rman target /

run
{
ALLOCATE CHANNEL D1 DEVICE TYPE DISK FORMAT '/u01/upgradelogs/FULLBACKUP_2901_%U';
ALLOCATE CHANNEL D2 DEVICE TYPE DISK FORMAT '/u01/upgradelogs/FULLBACKUP_2901_%U';
ALLOCATE CHANNEL D3 DEVICE TYPE DISK FORMAT '/u01/upgradelogs/FULLBACKUP_2901_%U';
BACKUP tag 'UPGRADE_DB' FORCE AS COMPRESSED BACKUPSET DATABASE PLUS ARCHIVELOG;
BACKUP CURRENT CONTROLFILE TAG 'UPGRADE_CTL' FORMAT '/u01/upgradelogs/proddbbeforeupgrade.ctl';
BACKUP SPFILE TAG 'UPGRADE_SPFILE' FORMAT '/u01/upgradelogs/SPFILE2901.ora';
RELEASE CHANNEL D1;
RELEASE CHANNEL D2;
RELEASE CHANNEL D3;
}

==============
1.14: Shutdown
==============
shut immediate;


=========================================
1.15: Copy Password file spfile to 19c OH
=========================================
cp spfileproddb.ora  orapwproddb /u01/app/oracle/product/19.0.0.0/dbhome_1/dbs

=====================================
1.16 Export NEW Environment Variables
=====================================

export ORACLE_HOME=/u01/app/oracle/product/19.0.0.0/dbhome_1
export PATH=$PATH:$ORACLE_HOME/bin

/u01/app/oracle/product/19.0.0.0/dbhome_1/bin/sqlplus / as sysdba

=====================================
1.17 :  Open database in upgrade mode:
=====================================
startup upgrade:

alter pluggable database all open upgrade;

select open_mode,status from v$database,v$instance;


=====================================
2 :  run DBUPGRADE Script
=====================================

nohup $ORACLE_HOME/bin/dbupgrade -n 2 -l /u01/upgradelogs &

======================
3:POST UPGRADE CHECKS:
======================

select name,open_mode,status,banner from v$database,v$instance,v$version;

select name,open_mode,cdb,version,status from v$database, v$instance;

col COMP_ID for a10
col COMP_NAME for a40
col VERSION for a15
set lines 180
set pages 999
select COMP_ID,COMP_NAME,VERSION,STATUS from dba_registry;

SQL> select count(*) from  cdb_objects where status ='INVALID';

  COUNT(*)
----------
      2295


@/u01/upgradelogs/postupgrade_fixups.sql

@?/rdbms/admin/utlrp.sql

@$ORACLE_HOME/rdbms/admin/utlusts.sql

=================
UPGRADE TIMEZONE:
=================

Select version from v$timezone_file;

@$ORACLE_HOME/rdbms/admin/utltz_upg_check.sql

@$ORACLE_HOME/rdbms/admin/utltz_upg_apply.sql

COL NAME FOR A25
COL GUARANTEE_FLASHBACK_DATABASE FOR A31
select NAME,GUARANTEE_FLASHBACK_DATABASE,TIME from V$restore_point;

drop restore point preupgrade;

show parameter compatible

alter system set compatible = '19.0.0' scope =spfile;
