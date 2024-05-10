CREATE TABLE SOE.ORDERS2 ( ORDER_ID NUMBER(12), ORDER_DATE TIMESTAMP(6) WITH
LOCAL TIME ZONE, ORDER_TOTAL NUMBER(8,2),ORDER_MODE VARCHAR2(8), CUSTOMER_ID
NUMBER(12), ORDER_STATUS NUMBER(2), SALES_REP_ID NUMBER(6));

INSERT INTO SOE.ORDERS2 SELECT ORDER_ID, ORDER_DATE, ORDER_TOTAL, ORDER_MODE,
CUSTOMER_ID, ORDER_STATUS, SALES_REP_ID FROM SOE.ORDERS WHERE ORDER_TOTAL
BETWEEN 10000 AND 15000;


SET AUTOTRACE TRACEONLY;

SELECT COUNT(*) FROM SOE.ORDERS2 WHERE ORDER_TOTAL < 10050;
get sql id from v$sql

SET AUTOT OFF

DECLARE
  l_sql_tune_task_id VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.CREATE_TUNING_TASK(
                          sql_id => '3h1jhbpk98zwy', 
                          scope => 'COMPREHENSIVE',
                          time_limit => 10000,
                          task_name => 'tuning_task_3h1jhbpk98zwy',
                          description => 'Tuning task for SQL ID 3h1jhbpk98zwy');
  DBMS_OUTPUT.PUT_LINE('Task Created: ' || l_sql_tune_task_id);
END;
/

exec DBMS_SQLTUNE.EXECUTE_TUNING_TASK(TASK_NAME=>'tuning_task_3h1jhbpk98zwy')
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('tuning_task_3h1jhbpk98zwy' ) FROM DUAL;


create index SOE.IDX$$_00350001 on SOE.ORDERS2("ORDER_TOTAL");
