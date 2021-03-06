--# Copyright IBM Corp. All Rights Reserved.
--# SPDX-License-Identifier: Apache-2.0

/*
 * Shows total rows read etc by Workload defined on the database
 */

CREATE OR REPLACE VIEW DB_WORKLOAD_ACTIVITY AS
SELECT  
    WORKLOAD_NAME           AS WORKLOAD
,   SERVICE_CLASS
,   M.CONNECTIONS
,   M.ACTIVE
,   M.ACTIVE_USERS
,   M.CONNECTED_USERS
,   M.ROWS_READ
,   M.ROWS_MODIFIED
,   M.ROWS_RETURNED
,   M.TOTAL_ACT_TIME
,   CASE WHEN AGENTPRIORITY = -32768 THEN 0 ELSE AGENTPRIORITY END    AS AGENT_PRI
,   CASE WHEN PREFETCHPRIORITY <> '' THEN PREFETCHPRIORITY ELSE (SELECT PREFETCHPRIORITY FROM SYSCAT.SERVICECLASSES P WHERE P.SERVICECLASSID = S.PARENTID ) END
             AS PREF_PRI
,   CASE WHEN BUFFERPOOLPRIORITY <> '' THEN BUFFERPOOLPRIORITY ELSE (SELECT BUFFERPOOLPRIORITY FROM SYSCAT.SERVICECLASSES P WHERE P.SERVICECLASSID = S.PARENTID ) END
             AS BUFF_PRI
--,       MAXDEGREE
FROM
    SYSCAT.SERVICECLASSES  S
INNER JOIN
(
    SELECT
        SERVICE_CLASS_ID
    --
    ,   CASE WHEN WORKLOAD_NAME IS NULL THEN 'NONE'
            WHEN WORKLOAD_NAME = 'SYSDEFAULTUSERWORKLOAD'   THEN 'DEFAULT USER' 
            WHEN WORKLOAD_NAME = 'SYSDEFAULTADMWORKLOAD'    THEN 'DEFAULT ADMIN'
            WHEN WORKLOAD_NAME = 'SYSDEFAULTSYSTEMWORKLOAD' THEN 'DEFAULT SYSTEM' 
            WHEN WORKLOAD_NAME = 'SYSDEFAULTMAINTWORKLOAD'  THEN 'DEFAULT MAINT' 
        ELSE WORKLOAD_NAME END AS WORKLOAD_NAME
    --    
    ,      CASE WHEN SERVICE_SUPERCLASS_NAME IN ('SYSDEFAULTUSERCLASS','SYSDEFAULTSYSTEMCLASS') THEN 'DEFAULT' ELSE SERVICE_SUPERCLASS_NAME END 
        || CASE WHEN SERVICE_SUBCLASS_NAME IN ('SYSDEFAULTSUBCLASS','SYSDEFAULTSYSTECLASS') THEN '' ELSE '.' || SERVICE_SUBCLASS_NAME END    AS SERVICE_CLASS  
    --
    ,  SUM(ROWS_READ)       AS ROWS_READ
    ,  SUM(ROWS_READ)       AS ROWS_MODIFIED
    ,  SUM(ROWS_READ)       AS ROWS_RETURNED
    ,  SUM(TOTAL_ACT_TIME)  AS TOTAL_ACT_TIME
    --            
    ,   SUM(CONNECTIONS) AS CONNECTIONS
    ,   SUM(ACTIVE)      AS ACTIVE
    --
    ,   SUBSTR((LISTAGG(CASE WHEN ACTIVE_USER <> '' THEN ',' || ACTIVE_USER ELSE '' END,'') WITHIN GROUP ( ORDER BY  SESSION_AUTH_ID)) || ' ',2)
            AS ACTIVE_USERS
    --
    ,  TRIM(LISTAGG(TRIM(SESSION_AUTH_ID),',') WITHIN GROUP ( ORDER BY  SESSION_AUTH_ID))
            AS CONNECTED_USERS
    --
    FROM
        (
            SELECT 
                SERVICE_CLASS_ID  
            ,   SESSION_AUTH_ID
            ,   WORKLOAD_NAME
            ,   SERVICE_SUPERCLASS_NAME
            ,   SERVICE_SUBCLASS_NAME        
            ,   COUNT(DISTINCT APPLICATION_HANDLE)      AS CONNECTIONS
            ,   COUNT(DISTINCT CASE WHEN WORKLOAD_OCCURRENCE_STATE = 'UOWEXEC' THEN APPLICATION_HANDLE END) AS ACTIVE
            ,   MAX(CASE WHEN WORKLOAD_OCCURRENCE_STATE = 'UOWEXEC' THEN TRIM(SESSION_AUTH_ID) ELSE '' END) AS ACTIVE_USER
            ,   SUM(ROWS_READ)       AS ROWS_READ
            ,   SUM(ROWS_READ)       AS ROWS_MODIFIED
            ,   SUM(ROWS_READ)       AS ROWS_RETURNED
            ,   SUM(TOTAL_ACT_TIME)  AS TOTAL_ACT_TIME
            FROM
                TABLE(MON_GET_UNIT_OF_WORK(NULL, -2))
            WHERE APPLICATION_HANDLE <> MON_GET_APPLICATION_HANDLE()
            AND   WORKLOAD_OCCURRENCE_STATE <> 'TRANSIENT'
            GROUP BY
                SERVICE_CLASS_ID  
            ,   SESSION_AUTH_ID
            ,   WORKLOAD_NAME
            ,   SERVICE_SUPERCLASS_NAME
            ,   SERVICE_SUBCLASS_NAME
        ) MS
        GROUP BY
            SERVICE_CLASS_ID  
        ,   WORKLOAD_NAME
        ,   SERVICE_SUPERCLASS_NAME
        ,   SERVICE_SUBCLASS_NAME
     ) M
ON
    S.SERVICECLASSID = M.SERVICE_CLASS_ID 