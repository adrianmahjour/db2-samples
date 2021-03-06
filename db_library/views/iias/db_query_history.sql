--# Copyright IBM Corp. All Rights Reserved.
--# SPDX-License-Identifier: Apache-2.0

-- Shows history of queries captured by the Db2 Datamanagement Console (or DSM) event monitor

CREATE OR REPLACE VIEW DB_QUERY_HISTORY AS
SELECT
    DB.DB_FORMAT_SQL(SQL_TEXT)    AS FORMATED_SQL
,   S.SQL_TEXT  
,   DBCONN_INT
,   COLLECTED
,   ACTIVITY_ID
,   AGENT_ID
,   UOW_ID
,   MEMBER
,   APPL_ID
,   PLANID
,   APPL_NAME
,   SESSION_AUTH_ID
,   TPMON_ACC_STR
,   TPMON_CLIENT_APP
,   TPMON_CLIENT_USERID
,   TPMON_CLIENT_WKSTN
,   ADDRESS
,   TIME_STARTED
,   TIME_COMPLETED
,   WLM_QUEUE_ASSIGNMENTS_TOTAL
,   WLM_QUEUE_TIME_TOTAL
,   ROWS_READ
,   ROWS_RETURNED
,   ROWS_MODIFIED
,   POOL_DATA_L_READS
,   POOL_INDEX_L_READS
,   POOL_XDA_L_READS
,   POOL_COL_L_READS
,   POOL_TEMP_DATA_L_READS
,   POOL_TEMP_INDEX_L_READS
,   POOL_TEMP_XDA_L_READS
,   POOL_TEMP_COL_L_READS
,   POOL_DATA_P_READS
,   POOL_INDEX_P_READS
,   POOL_XDA_P_READS
,   POOL_COL_P_READS
,   POOL_TEMP_DATA_P_READS
,   POOL_TEMP_INDEX_P_READS
,   POOL_TEMP_XDA_P_READS
,   POOL_TEMP_COL_P_READS
,   QUERY_COST_ESTIMATE
,   QUERY_CARD_ESTIMATE
,   QUERY_ACTUAL_DEGREE
,   WORKLOAD_ID
,   SERVICE_SUPERCLASS_NAME
,   SERVICE_SUBCLASS_NAME
,   SC_WORK_ACTION_SET_ID
,   SC_WORK_CLASS_ID
,   DB_WORK_ACTION_SET_ID
,   DB_WORK_CLASS_ID
,   SQLCODE
,   SQLWARN
,   ACTIVITY_TYPE
,   POST_SHRTHRESHOLD_SORTS
,   POST_THRESHOLD_SORTS
,   TOTAL_ROUTINE_INVOCATIONS
,   TOTAL_SORTS
,   TOTAL_HASH_JOINS
,   TOTAL_HASH_LOOPS
,   HASH_JOIN_OVERFLOWS
,   HASH_JOIN_SMALL_OVERFLOWS
,   POST_SHRTHRESHOLD_HASH_JOINS
,   POST_THRESHOLD_HASH_JOINS
,   TOTAL_OLAP_FUNCS
,   OLAP_FUNC_OVERFLOWS
,   COORD_PARTITION_NUM
,   PARTIAL_RECORD
,   DIRECT_READS
,   DIRECT_WRITE_TIME
,   DIRECT_WRITES
,   EXECUTABLE_ID
,   FCM_RECV_VOLUME
,   FCM_RECV_WAIT_TIME
,   FCM_SEND_VOLUME
,   FCM_SEND_WAIT_TIME
,   FCM_TQ_RECVS_TOTAL
,   FCM_TQ_SENDS_TOTAL
,   LOCK_ESCALS
,   LOCK_TIMEOUTS
,   LOCK_WAIT_TIME
,   LOCK_WAITS
,   LOG_BUFFER_WAIT_TIME
,   LOG_DISK_WAIT_TIME
,   LOG_DISK_WAITS_TOTAL
,   POOL_DATA_WRITES
,   POOL_INDEX_WRITES
,   POOL_READ_TIME
,   POOL_XDA_WRITES
,   PREP_TIME
,   ROUTINE_ID
,   SORT_OVERFLOWS
,   STMT_EXEC_TIME
,   STMT_ISOLATION
,   THRESH_VIOLATIONS
,   TOTAL_ACT_WAIT_TIME
,   TOTAL_CPU_TIME
,   TOTAL_RT_USER_CODE_PROC_TIME
,   TOTAL_SECTION_PROC_TIME
,   TOTAL_SECTION_SORT_PROC_TIME
,   TOTAL_SECTION_SORT_TIME
,   TQ_TOT_SEND_SPILLS
,   EVENT_ID
,   WORKLOADNAME
,   FED_WAIT_TIME
,   FED_ROWS_DELETED
,   FED_ROWS_INSERTED
,   FED_ROWS_UPDATED
,   FED_ROWS_READ
,   FED_WAITS_TOTAL
FROM   
    IBM_RTMON_EVMON.EVENT_ACTIVITY
JOIN
    IBMOTS.SQL_DIM  S  USING ( SQL_HASH_ID )
