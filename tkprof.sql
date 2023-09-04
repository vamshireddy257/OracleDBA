EXECUTE DBMS_SYSTEM.SET_SQL_TRACE_IN_SESSION(19,14284,TRUE);

EXECUTE DBMS_SYSTEM.SET_SQL_TRACE_IN_SESSION(19,14284,FALSE);

alter session set tracefile_identifier=performace_tuning;

alter session set sql_trace=true;

alter session set sql_trace=false;

tkprof ORADB_ora_4175_PERFORMACE_TUNING.trc output_pt.log sys=no SORT=execpu,fchcpu