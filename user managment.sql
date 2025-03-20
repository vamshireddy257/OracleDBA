
set lines 200 pages 200;
col username for a25;
col profile for a20;
col DEFAULT_TABLESPACE for a20;
col TEMPORARY_TABLESPACE for a20;
col ACCOUNT_STATUS for a20;
select username,DEFAULT_TABLESPACE,TEMPORARY_TABLESPACE,PROFILE,ACCOUNT_STATUS from dba_users order by 1 ;






PROFILES:

Get profile information....

set lines 200 ;
set pages 200;
col profile for a32;
col resource_name for a50;
col limit for a50;

select distinct profile from dba_profiles ;

select profile,resource_name, limit from dba_profiles where profile = 'DEFAULT';

CREATE PROFILE:

CREATE PROFILE APP_PROFILE
LIMIT
COMPOSITE_LIMIT UNLIMITED
SESSIONS_PER_USER 2
CPU_PER_SESSION UNLIMITED
CPU_PER_CALL UNLIMITED
LOGICAL_READS_PER_SESSION UNLIMITED
LOGICAL_READS_PER_CALL UNLIMITED
IDLE_TIME 1
CONNECT_TIME 5
PRIVATE_SGA UNLIMITED
FAILED_LOGIN_ATTEMPTS 10
PASSWORD_LIFE_TIME 180
PASSWORD_REUSE_TIME UNLIMITED
PASSWORD_REUSE_MAX UNLIMITED
PASSWORD_VERIFY_FUNCTION NULL
PASSWORD_LOCK_TIME UNLIMITED
PASSWORD_GRACE_TIME UNLIMITED;


select profile,resource_name, limit from dba_profiles where profile = 'APP_PROFILE';


alter profile:

ALTER PROFILE APP_PROFILE LIMIT SESSIONS_PER_USER 1;
ALTER PROFILE APP_PROFILE LIMIT FAILED_LOGIN_ATTEMPTS 3;


ROLES
--check available roles.
col role for a30
select distinct ROLE  from role_role_privs ;


---to check grants of a ROLES

select ROLE,GRANTED_ROLE  from role_role_privs where role='DBA';

-- ALL System privileges  

SELECT distinct PRIVILEGE FROM DBA_SYS_PRIVS order by 1;
-- System privileges granted to an user ( scott)



SELECT * FROM DBA_SYS_PRIVS where grantee='SCOTT';

-- Roles granted to an user ( scott)
col grantee for a20;
col GRANTED_ROLE for a20;
SELECT * FROM DBA_ROLE_PRIVS where grantee='SCOTT';

grant dba to scott;

col grantee for a20;
col GRANTED_ROLE for a20;
SELECT * FROM DBA_ROLE_PRIVS where grantee='SCOTT';

-- Object privileges granted to an user ( SCOTT)
col owner for a20;
col grantee for a20;
col GRANTOR for a20;
col table_name for a20;
select GRANTEE,OWNER,TABLE_NAME,GRANTOR,PRIVILEGE from DBA_TAB_PRIVS WHERE GRANTEE='SCOTT';

-- Column specific privileges granted

SELECT * FROM DBA_COL_PRIVS WHERE GRANTEE='SCOTT';

-- Table privileges

--GRANT READ ANY TABLE TO SCOTT;

GRANT SELECT ANY TABLE TO SCOTT;

GRANT INSERT, UPDATE, DELETE ON TESTUSER1.EMPTABL on SCOTT;
GRANT ALL ON TESTUSER1.EMPTABL on SCOTT;

-- Grant privilege on few columns of a table
--Only INSERT,UPDATE can be granted at COLUMN level.

--GRANT insert (emp_id) ON TESTUSER1.EMPTABL TO SCOTT;
--GRANT UPDATE(emp_id) ON TESTUSER1.EMPTABL TO SCOTT;

USER MANAGEMENT STATS

create user <username> identified by password <desired password> default tablespace users  temporary tablespace temp;



select dbms_metadata.get_ddl('USER', u.username) AS ddl from dba_users u where u.username = 'USER1';

alter user user1 identified by values 'S:3C030687D5FB49EFF32112FA5462C3D4E97E52F50E4CCCA72E009D822998;T:FBB3287F269FC426D3490C05827070CA8D289068F62EA736A0C632A448BC1FC515D359633A4CF79FB37A2CC74072C40F0C479F70C63F588B1C24A0BF0296336B24E2FCD1CE89C590A6AFE31A25504734';



Eg:

create user SCOTT identified by oracle#41234
default tablespace users
temporary tablespace TEMP;

-To create an user, which will prompt for new password upon login:

create user SCOTT identified by oracle#41234
default tablespace users
temporary tablespace TEMP
account unlock 
profile APP_PROFILE
password expire;

-- Change password of an user

ALTER USER SCOTT identified by NEW_PWD;

-- Change user profile;

ALTER USER SCOTT PROFILE APP_PROFILE;

-- Unlock/lock a user

ALTER USER SCOTT account unlock;
ALTER USER SCOTT account lock;

-- 	 sure account expiry, so upon login, it will ask for new one

ALTER USER a124 password expire;

-- Get default tablespace of a user:

set lines 200
col username for a23
select username,DEFAULT_TABLESPACE from dba_users where username='SCOTT';

USERNAME               DEFAULT_TABLESPACE
----------------------- ------------------------------
SCOTT                          USERS

-- Change default tablespace of a user:

ALTER USER SCOTT DEFAULT TABLESPACE DATATS;

select username,DEFAULT_TABLESPACE from dba_users where username='SCOTT';

USERNAME               DEFAULT_TABLESPACE
----------------------- ------------------------------
SCOTT                           DATATS

-- Get the current tablespace quota information of an user
set lines 299
select TABLESPACE_NAME,BYTES/1024/1024 "UTILIZIED_SPACE" ,MAX_BYTES/1024/1024 "QUOTA_ALLOCATED" from dba_ts_quotas where username='SCOTT';

TABLESPACE_NAME                                 UTILIZIED_SPACE                  QUOTA_ALLOCATED
------------------------------         ---------------------------        --------------------------
USERS                                           .0625                                    1024

--- Change the tablespace quota for the user to 5G

ALTER USER SCOTT QUOTA 5G ON USERS;

--- Grant unlimited tablespace quota:

ALTER USER SCOTT QUOTA UNLIMITED ON USERS;

--- You can connect to another user without knowing the password, with grant connect through privilege
--- Suppose a user TEST1 wants to connect to TEST2 user and create a table and we don’t know the password of TEST2.

Conn / as sysdba
SQL >alter user SCOTT grant connect through supriya;

User altered.

SQL >conn TEST1[TEST2]
Enter password:< Give password for TEST1>

SQL >show user
USER is "TEST2"
SQL >create table emp_test as select * from emp;

Table created.

SQL > conn / as sysdba
connected
SQL > select owner from dba_tables where table_name='EMP_TEST';

OWNER
------
TEST2


--get all the privilages of the user.
set lines 300;
column PRIVILEGE for a30;
column OBJ_OWNER for a15;
column OBJ_NAME for a30;
column USERNAME for a15;
column GRANT_SOURCES for a15;
column ADMIN_OR_GRANT_OPT for a5;
column HIERARCHY_OPT for a5;

SELECT
    PRIVILEGE,
    OBJ_OWNER,
    OBJ_NAME,
    USERNAME,
    LISTAGG(GRANT_TARGET, ',') WITHIN GROUP (ORDER BY GRANT_TARGET) AS GRANT_SOURCES, -- Lists the sources of the permission
    MAX(ADMIN_OR_GRANT_OPT) AS ADMIN_OR_GRANT_OPT, -- MAX acts as a Boolean OR by picking 'YES' over 'NO'
    MAX(HIERARCHY_OPT) AS HIERARCHY_OPT -- MAX acts as a Boolean OR by picking 'YES' over 'NO'
FROM (
    -- Gets all roles a user has, even inherited ones
    WITH ALL_ROLES_FOR_USER AS (
        SELECT DISTINCT CONNECT_BY_ROOT GRANTEE AS GRANTED_USER, GRANTED_ROLE
        FROM DBA_ROLE_PRIVS
        CONNECT BY GRANTEE = PRIOR GRANTED_ROLE
    )
    SELECT
        PRIVILEGE,
        OBJ_OWNER,
        OBJ_NAME,
        USERNAME,
        REPLACE(GRANT_TARGET, USERNAME, 'Direct to user') AS GRANT_TARGET,
        ADMIN_OR_GRANT_OPT,
        HIERARCHY_OPT
    FROM (
        -- System privileges granted directly to users
        SELECT PRIVILEGE, NULL AS OBJ_OWNER, NULL AS OBJ_NAME, GRANTEE AS USERNAME, GRANTEE AS GRANT_TARGET, ADMIN_OPTION AS ADMIN_OR_GRANT_OPT, NULL AS HIERARCHY_OPT
        FROM DBA_SYS_PRIVS
        WHERE GRANTEE IN (SELECT USERNAME FROM DBA_USERS)
        UNION ALL
        -- System privileges granted users through roles
        SELECT PRIVILEGE, NULL AS OBJ_OWNER, NULL AS OBJ_NAME, ALL_ROLES_FOR_USER.GRANTED_USER AS USERNAME, GRANTEE AS GRANT_TARGET, ADMIN_OPTION AS ADMIN_OR_GRANT_OPT, NULL AS HIERARCHY_OPT
        FROM DBA_SYS_PRIVS
        JOIN ALL_ROLES_FOR_USER ON ALL_ROLES_FOR_USER.GRANTED_ROLE = DBA_SYS_PRIVS.GRANTEE
        UNION ALL
        -- Object privileges granted directly to users
        SELECT PRIVILEGE, OWNER AS OBJ_OWNER, TABLE_NAME AS OBJ_NAME, GRANTEE AS USERNAME, GRANTEE AS GRANT_TARGET, GRANTABLE, HIERARCHY
        FROM DBA_TAB_PRIVS
        WHERE GRANTEE IN (SELECT USERNAME FROM DBA_USERS)
        UNION ALL
        -- Object privileges granted users through roles
        SELECT PRIVILEGE, OWNER AS OBJ_OWNER, TABLE_NAME AS OBJ_NAME, ALL_ROLES_FOR_USER.GRANTED_USER AS USERNAME, ALL_ROLES_FOR_USER.GRANTED_ROLE AS GRANT_TARGET, GRANTABLE, HIERARCHY
        FROM DBA_TAB_PRIVS
        JOIN ALL_ROLES_FOR_USER ON ALL_ROLES_FOR_USER.GRANTED_ROLE = DBA_TAB_PRIVS.GRANTEE
    ) ALL_USER_PRIVS
    -- Adjust your filter here
    WHERE USERNAME = 'SCOTT'
) DISTINCT_USER_PRIVS
GROUP BY
    PRIVILEGE,
    OBJ_OWNER,
    OBJ_NAME,
    USERNAME
;

replicat user grants:
set long 9999;
set pages 1000;
SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT','SCOTT') FROM DUAL;
SELECT DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT','SCOTT')  FROM DUAL;
SELECT DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT','SCOTT') FROM DUAL;
