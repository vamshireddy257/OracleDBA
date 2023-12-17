--Check opatch version 
cd $ORACLE_HOME/OPatch/
./optach version

if opatch is not upto date download optach from oraclesupport and replace with existiing

cd $ORACLE_HOME
mv OPatch OPatch_bkp

mkdir -p  /u01/patch/
cd /u01/patch/
unzip p6880880_190000_Linux-x86-64.zip $ORACLE_HOME

cd $ORACLE_HOME/OPatch/
./optach version

--prerquisites check

$ lsnrctl stop listener;

sqlplus / as sysdba

SQL> select name,open_mode from v$database;

SQL>  select * from v$version;

SQL> select PATCH_ID,to_char(ACTION_TIME,'DD-MON-YY'), action from dba_registry_sqlpatch;

SQL> select name from v$datafile
union
select name from v$controlfile
union 
select member from v$logfile;
-- create GRP
SQL> create restore point before_patch_1712 guarantee flashback database;

--rman backup
rman target /
rman> backup database plus archivelog

SQL> shut immediate;

-- Take backup of ORACLE_HOME
tar -cvf /u01/rman_bkp/oracle_home_1712bkp.tar $ORACLE_HOME


cd /u01/patch

unzip <patchname>

cd /u01/patch/35643107

-- check conflicts
$ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -ph ./

-- rollback conflicted patch 
## opatch rollback -id 35643107

-- apply patch 

cd /u01/patch/35643107
$ORACLE_HOME/OPatch/opatch apply

-- check patches applied

$ORACLE_HOME/OPatch/opatch lsinventory |grep applied

-- start database once oracle-home patch applied

SQL> startup;
SQL> alter pluggable database all open;


-- run datapatch

cd $ORACLE_HOME
./datapatch -verbose

--verify datapatch at dblevel

sqlplus / as sysdba

SQL> select PATCH_ID,to_char(ACTION_TIME,'DD-MON-YY'), action from dba_registry_sqlpatch;

$lsnrctl start listener;

select owner,object_type,status,count(*) from dba_objects where status='INVALID' Group by owner,object_type,status;
alter view <> compile;
alter procedure <proc> compile;
alter package <pkgname> compile body;
alter trigger <trig> compile;

alter index <index> rebuild online;
