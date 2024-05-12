--To get current value of retention and interval
select snap_interval, retention from dba_hist_wr_control;

-- to modify existing values of retention and interval
exec dbms_workload_repository.modify_snapshot_settings(interval => 15, retention => 44640) ;

--to get list of snapids available
SELECT snap_id, begin_interval_time, end_interval_time FROM dba_hist_snapshot  ORDER BY snap_id;

-- to take manual snapshot
exec dbms_workload_repository.create_snapshot;


--to generate AWR report
$ORACLE_HOME/rdbms/admin/awrrpt.sql

--to generate ADDM report
$ORACLE_HOME/rdbms/admin/addmrpt.sql

--to generate ASH report
$ORACLE_HOME/rdbms/admin/ashrpt.sql
