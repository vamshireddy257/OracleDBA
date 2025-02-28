Useful Query for both DBA and Developer
Instructions of use:

Either run this query logged on to SYS or SYSTEM or GRANT SELECT on the DICTIONARY TABLES:DBA_TAB_COLUMNS, V$DATABASE, DBA_TABLES, DBA_EXTENTS, DBA_CONS_COLUMNS, DBA_CONSTRAINTS, DBA_TRIGGERS, DBA_TAB_PRIVS, DBA_COL_PRIVS

In toad you just copy and paste these script. It will be requested to enter the schema owner and the tablename. At SQL*PLUS You will need Column format setting for proper output layout.

——————————————————————————————————————————————————————–
======================================================
Display the Table/INDEX Details for Particular Schema
======================================================
	

SELECT owner, table_name, TRUNC(sum(bytes)/1024/1024) Meg
FROM (SELECT segment_name table_name, owner, bytes
FROM dba_segments
WHERE segment_type = 'TABLE'
UNION ALL
SELECT i.table_name, i.owner, s.bytes
FROM dba_indexes i, dba_segments s
WHERE s.segment_name = i.index_name
AND s.owner = i.owner AND s.segment_type = 'INDEX'
UNION ALL
SELECT l.table_name, l.owner, s.bytes
FROM dba_lobs l, dba_segments s
WHERE s.segment_name = l.segment_name
AND s.owner = l.owner AND s.segment_type = 'LOBSEGMENT'
UNION ALL
SELECT l.table_name, l.owner, s.bytes
FROM dba_lobs l, dba_segments s
WHERE s.segment_name = l.index_name
AND s.owner = l.owner AND s.segment_type = 'LOBINDEX')
WHERE owner in UPPER('&owner')
GROUP BY table_name, owner
–HAVING SUM(bytes)/1024/1024 > 10  — For size greater than 10 MB
ORDER BY SUM(bytes) desc;




=========================
Show the Table Structure
=========================

SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE, COLUMN_ID POS
FROM   SYS.DBA_TAB_COLUMNS
WHERE  OWNER = upper('&&owner')
AND    TABLE_NAME = upper('&&table')
ORDER  BY COLUMN_ID;

========================
Show Physical Attributes
========================

SELECT PCT_FREE, PCT_INCREASE, INITIAL_EXTENT, NEXT_EXTENT, MAX_EXTENTS, NUM_ROWS, AVG_ROW_LEN
FROM   SYS.DBA_TABLES
WHERE  OWNER = upper('&&owner') AND TABLE_NAME = upper('&&table');

=====================================
Show the actual Maximum Size of a Row
=====================================

SELECT SUM(DATA_LENGTH) FROM SYS.DBA_TAB_COLUMNS
WHERE  OWNER = upper('&&owner') AND TABLE_NAME = upper('&&table');

========================================================================
Show the Number of Physical EXTENTS that have been allocated Attributes
========================================================================

SELECT SEGMENT_NAME, COUNT(*) COUNTER
FROM   SYS.DBA_EXTENTS
WHERE  OWNER = upper('&&owner') AND SEGMENT_NAME = upper('&&table')
GROUP  BY SEGMENT_NAME;

===============================================
Show the Physical SIZE IN BYTES of the TABLE
===============================================

SELECT SEGMENT_NAME, SUM(BYTES) "TABSIZE in MB"
FROM   SYS.DBA_EXTENTS
WHERE  OWNER = upper('&&owner') AND SEGMENT_NAME = upper('&&table')
GROUP  BY SEGMENT_NAME;

================================================================================
GET ALL THE INDEX DETAILS: Show all the indexes and their columns for this table
================================================================================

SELECT IND.OWNER,IND.TABLE_OWNER,IND.INDEX_NAME,IND.UNIQUENESS,COL.COLUMN_NAME, COL.COLUMN_POSITION
FROM   SYS.DBA_INDEXES IND, SYS.DBA_IND_COLUMNS COL
WHERE  IND.TABLE_NAME = upper('&&table') AND IND.TABLE_OWNER = upper('&&owner')
AND    IND.TABLE_NAME = COL.TABLE_NAME AND IND.OWNER = COL.INDEX_OWNER
AND    IND.TABLE_OWNER = COL.TABLE_OWNER AND IND.INDEX_NAME = COL.INDEX_NAME;

=================================================================================
Display all the physical details of the Primary and Other Indexes for this table
=================================================================================

SELECT IND.OWNER, IND.TABLE_OWNER, IND.INDEX_NAME, IND.UNIQUENESS, COL.COLUMN_NAME, COL.COLUMN_POSITION, IND.PCT_FREE, IND.PCT_INCREASE, IND.INITIAL_EXTENT, IND.NEXT_EXTENT, IND.MAX_EXTENTS
FROM DBA_INDEXES IND, DBA_IND_COLUMNS CO
WHERE IND.TABLE_NAME = upper('&&table') AND IND.TABLE_OWNER = upper('&&owner')
AND IND.TABLE_NAME = COL.TABLE_NAME AND IND.OWNER = COL.INDEX_OWNER
AND IND.TABLE_OWNER = COL.TABLE_OWNER AND IND.INDEX_NAME = COL.INDEX_NAME;

====================================================================================
GET ALL THE CONSTRAINT DETAILS: Show the Non-Foreign Keys Constraints on this table
====================================================================================
SELECT COL.OWNER, COL.CONSTRAINT_NAME, COL.COLUMN_NAME,COL.POSITION,CON.CONSTRAINT_TYPE
DECODE (CON.CONSTRAINT_TYPE, 'P','primary','R','foreign','U','unique','C','check') "Type"
FROM DBA_CONS_COLUMNS COL, DBA_CONSTRAINTS CON
WHERE COL.OWNER = upper('&&owner') AND COL.TABLE_NAME = upper('&&table')
AND CONSTRAINT_TYPE <> 'R' AND  COL.OWNER = CON.OWNER
AND COL.TABLE_NAME = CON.TABLE_NAME AND COL.CONSTRAINT_NAME = CON.CONSTRAINT_NAME
ORDER BY COL.CONSTRAINT_NAME, COL.POSITION;

=========================================================================
Show the Foreign Keys on this table pointing at other tables Primary Key
=========================================================================

SELECT CON.OWNER, CON.TABLE_NAME, CON.CONSTRAINT_NAME, CON.R_CONSTRAINT_NAME,

CON.DELETE_RULE, COL.COLUMN_NAME, COL.POSITION,

—     CON1.OWNER,

CON1.TABLE_NAME “Ref Tab”, CON1.CONSTRAINT_NAME “Ref Const”

—     COL1.COLUMN_NAME “Ref Column”,

—     COL1.POSITION

–FROM   DBA_CONS_COLUMNS COL,

FROM   DBA_CONSTRAINTS CON1, DBA_CONS_COLUMNS COL, DBA_CONSTRAINTS CON

WHERE  CON.OWNER = upper(‘&&owner’) AND    CON.TABLE_NAME = upper(‘&&table’)

AND    CON.CONSTRAINT_TYPE = ‘R’ AND    COL.OWNER = CON.OWNER

AND    COL.TABLE_NAME = CON.TABLE_NAME AND    COL.CONSTRAINT_NAME = CON.CONSTRAINT_NAME

— Leave out next line if looking for other Users with Foriegn Keys.

AND    CON1.OWNER = CON.OWNER AND    CON1.CONSTRAINT_NAME = CON.R_CONSTRAINT_NAME

AND    CON1.CONSTRAINT_TYPE IN ( ‘P’, ‘U’ );

— The extra DBA_CONS_COLUMNS will give details of refered to columns,

— but has a multiplying effect on the query results.

— NOTE: Could use temporary tables to sort out.

–AND    COL1.OWNER = CON1.OWNER

–AND    COL1.TABLE_NAME = CON1.TABLE_NAME

–AND    COL1.CONSTRAINT_NAME = CON1.CONSTRAINT_NAME;

==============================================================================================
Show the Foreign Keys pointing at this table via the recursive call  to the Constraints table.
==============================================================================================

SELECT CON1.OWNER, CON1.TABLE_NAME, CON1.CONSTRAINT_NAME, CON1.DELETE_RULE, CON1.STATUS, CON.TABLE_NAME, CON.CONSTRAINT_NAME, COL.POSITION, COL.COLUMN_NAME
FROM   DBA_CONSTRAINTS CON, DBA_CONS_COLUMNS COL, DBA_CONSTRAINTS CON1
WHERE  CON.OWNER = upper('&&owner') AND    CON.TABLE_NAME = upper('&&table')
AND ((CON.CONSTRAINT_TYPE = 'P') OR (CON.CONSTRAINT_TYPE = 'U'))
AND COL.TABLE_NAME = CON1.TABLE_NAME AND COL.CONSTRAINT_NAME = CON1.CONSTRAINT_NAME
AND    CON1.OWNER = CON.OWNER AND CON1.R_CONSTRAINT_NAME = CON.CONSTRAINT_NAME
AND    CON1.CONSTRAINT_TYPE = 'R' GROUP BY CON1.OWNER, CON1.TABLE_NAME, CON1.CONSTRAINT_NAME, CON1.DELETE_RULE, CON1.STATUS, CON.TABLE_NAME, CON.CONSTRAINT_NAME, COL.POSITION, COL.COLUMN_NAME;

==============================
Show all the check Constraints
==============================

SELECT 'alter table ', TABLE_NAME, ' add constraint ',
CONSTRAINT_NAME, ' check ( ', SEARCH_CONDITION, ' ); '
FROM DBA_CONSTRAINTS
WHERE OWNER = upper('&&owner') AND TABLE_NAME = upper('&&table')
AND CONSTRAINT_TYPE = 'C';

===========================================================
Show all the Triggers that have been created on this table
===========================================================

SELECT OWNER, 'CREATE OR REPLACE TRIGGER ', TRIGGER_NAME, DESCRIPTION,
TRIGGER_BODY,       '/'
FROM  DBA_TRIGGERS
WHERE OWNER = upper('&&owner') AND TABLE_NAME = upper('&&table');


=================================
Get the First day of the Month:
=================================
SELECT TRUNC (SYSDATE, 'MONTH') "First day of current month" FROM DUAL;

================================
Get the last day of the Month:
================================

SELECT TRUNC (LAST_DAY (SYSDATE)) "Last day of current month" FROM DUAL;

==============================
Get the First day of the year:
==============================

SELECT TRUNC (SYSDATE, 'YEAR') "Year First Day" FROM DUAL;

=============================
Get the last day of the year:
=============================

SELECT ADD_MONTHS (TRUNC (SYSDATE, 'YEAR'), 12) – 1 "Year Last Day" FROM DUAL;

====================================
Get number of days in current month
====================================

SELECT CAST (TO_CHAR (LAST_DAY (SYSDATE), 'dd') AS INT) number_of_days FROM DUAL;
Get number of days left in Current month
SELECT SYSDATE, LAST_DAY (SYSDATE) "Last", LAST_DAY (SYSDATE) – SYSDATE "Days left" FROM DUAL;
Get number of days between two dates
SELECT ROUND ( (MONTHS_BETWEEN ('01-Feb-2014′, '01-Mar-2012′) * 30), 0) num_of_days FROM DUAL;
OR
SELECT TRUNC(sysdate) – TRUNC(e.hire_date) FROM employees;
===================================================================
Display each months start and end date upto last month of the year:
===================================================================
SELECT ADD_MONTHS (TRUNC (SYSDATE, 'MONTH'), i) start_date,
TRUNC (LAST_DAY (ADD_MONTHS (SYSDATE, i))) end_date
FROM XMLTABLE ('for $i in 0 to xs:int(D) return $i' PASSING XMLELEMENT
(d, FLOOR (MONTHS_BETWEEN (ADD_MONTHS (TRUNC (SYSDATE, 'YEAR') – 1, 12), SYSDATE)))
COLUMNS i INTEGER PATH '.');
==========================================================
Get number of seconds passed since today (since 00:00 hr):
==========================================================
SELECT (SYSDATE – TRUNC (SYSDATE)) * 24 * 60 * 60 num_of_sec_since_morning FROM DUAL;
Get number of seconds left today (till 23:59:59 hr)
SELECT (TRUNC (SYSDATE+1) – SYSDATE) * 24 * 60 * 60 num_of_sec_left FROM DUAL;

=======================================================
Check if a table exists in the current database schema:
=======================================================

SELECT table_name FROM user_tables
WHERE table_name = 'TABLE_NAME';
Check if a column exists in a table:
SELECT column_name AS FOUND
FROM user_tab_cols
WHERE table_name = 'TABLE_NAME' AND column_name = 'COLUMN_NAME';
Showing the Table Structure:
SELECT DBMS_METADATA.get_ddl ('TABLE', 'TABLE_NAME', 'USER_NAME') FROM DUAL;
Getting Current Schema
SELECT SYS_CONTEXT ('userenv', 'current_schema') FROM DUAL;
Convert Number to Words:
SELECT TO_CHAR (TO_DATE (1526, 'j'), 'jsp') FROM DUAL;


======================================
Find the Last records from the Table:
======================================

SELECT *  FROM employees
WHERE ROWID IN (SELECT MAX (ROWID) FROM employees);
-(or)-
SELECT * FROM employees
MINUS
SELECT * FROM employees
WHERE ROWNUM < (SELECT COUNT (*) FROM employees);

===================================
Random number generator in Oracle:
===================================
SELECT ROUND (DBMS_RANDOM.VALUE () * 100) + 1 AS random_num FROM DUAL;

========================================================
Show all the GRANTS made on this table and it''s columns
========================================================

SELECT 'GRANT ', PRIVILEGE, ' ON ', TABLE_NAME,' TO ', GRANTEE,  ';'
FROM DBA_TAB_PRIVS
WHERE OWNER = upper('&&owner') AND TABLE_NAME = upper('&&table');

SELECT 'GRANT ', PRIVILEGE, ' ( ', COLUMN_NAME, ' ) ', ' ON ', TABLE_NAME, ' TO ', GRANTEE, ';'
FROM DBA_COL_PRIVS
WHERE OWNER = upper('&&owner') AND TABLE_NAME = upper('&&table');