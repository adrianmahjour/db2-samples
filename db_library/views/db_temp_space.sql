--# Copyright IBM Corp. All Rights Reserved.
--# SPDX-License-Identifier: Apache-2.0

/*
 * Shows current system and user temporary tablespace usage by user
 */

CREATE OR REPLACE VIEW DB_TEMP_SPACE AS
  SELECT
      USER_NAME
  ,   TABSCHEMA  
  ,   TABNAME
  ,   DECIMAL(DECIMAL(SUM(SIZE_PAGES) * 16,21,2) / 1024 / 1024,7,2) AS SIZE_GB
  ,   SUM(ROWS_INSERTED)   AS ROWS_INSERTED
  ,   SUM(ROWS_READ)       AS ROWS_READ
  ,   MIN(TIMESTAMP(CREATE_CONNECT_TIME,0))   AS CREATE_CONNECT_TIME
  ,   CASE MIN(TEMPTABTYPE) WHEN 'S' THEN 'temp' WHEN 'D' THEN 'DGTT' WHEN 'C' THEN 'CGTT' END         AS TYPE
  ,   SMALLINT(MAX(COLCOUNT))                AS COLUMNS
  ,   MIN(PARTITION_MODE)                    AS HASH
  ,   CASE WHEN MIN(LOGGED) IN ('','Y') THEN 'Y' ELSE 'N' END    AS LOGGED
  FROM
  (
  SELECT
      I.USER_NAME
  ,   CASE WHEN I.TEMPTABTYPE = 'S' THEN '' ELSE T.TABSCHEMA END                    AS TABSCHEMA
  ,   CASE WHEN I.TEMPTABTYPE = 'S' THEN 'Query temp table(s)' ELSE T.TABNAME END   AS  TABNAME
  ,     COALESCE(T.DATA_OBJECT_L_PAGES,0) 
      + COALESCE(T.INDEX_OBJECT_L_PAGES,0)
      + COALESCE(T.LOB_OBJECT_L_PAGES,0)
      + COALESCE(T.LONG_OBJECT_L_PAGES,0)
      + COALESCE(T.XDA_OBJECT_L_PAGES,0)
            AS SIZE_PAGES
  ,   T.ROWS_INSERTED
  ,   T.ROWS_READ
  ,   I.TEMPTABTYPE
  ,   I.CREATE_CONNECT_TIME
  ,   I.COLCOUNT
  ,   I.PARTITION_MODE
  ,   I.ONCOMMIT
  ,   I.ONROLLBACK
  ,   I.LOGGED
  FROM (
    SELECT 
            TABSCHEMA
    ,       TABNAME
    ,       INSTANTIATOR    AS USER_NAME
    ,       TEMPTABTYPE
    ,       INSTANTIATION_TIME   AS CREATE_CONNECT_TIME
    ,       COLCOUNT
    ,       PARTITION_MODE
    ,       ONCOMMIT
    ,       ONROLLBACK
    ,       LOGGED
    FROM  TABLE(ADMIN_GET_TEMP_TABLES(null,null,null))
    UNION ALL
    SELECT
            '<' || APPLICATION_HANDLE || '><' || SYSTEM_AUTH_ID || '>' AS   TABSCHEMA
    ,       NULL            AS TABNAME
    ,       SYSTEM_AUTH_ID  AS USER_NAME
    ,       'S'             AS TEMPTABTYPE
    ,       CONNECTION_START_TIME   AS CREATE_CONNECT_TIME
    ,       NULL            AS COLCOUNT
    ,       NULL            AS PARTITION_MODE
    ,       NULL            AS ONCOMMIT
    ,       NULL            AS ONROLLBACK
    ,       NULL            AS LOGGED
    FROM TABLE(MON_GET_CONNECTION(NULL,-1))
    ) AS I
    , TABLE(MON_GET_TABLE(I.TABSCHEMA,I.TABNAME,-2)) T
 )
GROUP BY USER_NAME, TABSCHEMA, TABNAME