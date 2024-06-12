# Analyze Redo Log with Oracle LogMiner
## Identifying High Redo Log Generation
In my database, there is a huge amount of redo generation, and upon checking, I
found that there are no long-running sessions exceeding 1 minute. I am unable to determine what is causing the high redo generation. However, I did identify the time period during which the high log generation occurs.
## Find Archive Generation with Timestamp
```SQL
SELECT
 TO_CHAR(first_time, 'YYYY-MM-DD HH24') AS hour,
 ROUND(SUM(blocks * block_size) / POWER(1024, 3), 2) AS size_in_gb
FROM
 v$archived_log
WHERE
 first_time IS NOT NULL
GROUP BY
 TO_CHAR(first_time, 'YYYY-MM-DD HH24')
ORDER BY
 TO_CHAR(first_time, 'YYYY-MM-DD HH24') DESC;
```

## Get Archive Log File Name
``` SQL
SELECT THREAD#, SEQUENCE#, NAME, FIRST_TIME, NEXT_TIME, ARCHIVED
FROM V$ARCHIVED_LOG
WHERE FIRST_TIME BETWEEN TO_DATE('2024-06-12 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
 AND TO_DATE('2024-06-12 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
ORDER BY FIRST_TIME DESC;
```
## Using Oracle LogMiner
Oracle LogMiner is used to read the contents of Redo / Archive log files. Below are
the steps to configure and query LogMiner:

### 1. Enable Supplemental Logging
The supplemental logging records additional information regarding each transaction into redo log files. You must enable supplemental logging before generating the redo log files that will be analyzed by Oracle LogMiner.
``` SQL
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
SELECT SUPPLEMENTAL_LOG_DATA_MIN FROM V$DATABASE;
```

### 2. Add Log Files
Oracle LogMiner can mine both Redo / Archive log files. Let us assume we would like to analyze all the redo logs inside the database. The DBMS_LOGMNR.NEW parameter specifies the first log file to be analyzed. The subsequent log files are defined with the DBMS_LOGMNR.ADDFILE option.
```SQL
EXECUTE DBMS_LOGMNR.ADD_LOGFILE(
 LOGFILENAME => '/u01/prddb/redo01.log',
 OPTIONS => DBMS_LOGMNR.NEW);
EXECUTE DBMS_LOGMNR.ADD_LOGFILE(
 LOGFILENAME => '/u01/prddb/redo01.log',
 OPTIONS => DBMS_LOGMNR.ADDFILE);
EXECUTE DBMS_LOGMNR.ADD_LOGFILE(
 LOGFILENAME => '/u01/prddb/redo01.log',
 OPTIONS => DBMS_LOGMNR.ADDFILE);
Alternatively, you can directly give the name of the archive log file:
SQL CODE :-
EXECUTE DBMS_LOGMNR.ADD_LOGFILE(
 LOGFILENAME => '/u01/FRA/TESTDB/archivelog/o1_mf_1_3027_k6dcc33y_.arc',
 OPTIONS => DBMS_LOGMNR.NEW);
EXECUTE DBMS_LOGMNR.ADD_LOGFILE(
 LOGFILENAME => '/u01/FRA/TESTDB/archivelog/o1_mf_1_3028_k6dcc33y_.arc',
 OPTIONS => DBMS_LOGMNR.ADDFILE);
EXECUTE DBMS_LOGMNR.ADD_LOGFILE(
 LOGFILENAME => '/u01/FRA/TESTDB/archivelog/o1_mf_1_3029_k6dcc33y_.arc',
 OPTIONS => DBMS_LOGMNR.ADDFILE);
```
### 3. Start LogMiner
If you are starting LogMiner:
SQL CODE :-
```sql
EXECUTE DBMS_LOGMNR.START_LOGMNR(
 OPTIONS => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG);
 ```
### 4. Query V$LOGMNR_CONTENTS
Now you are ready to query V$LOGMNR_CONTENTS view that allows you to see the
contents of Redo / Archive log files.
#### Example: Check redo log files for any queries run against the EMPLOYEES table:
SQL CODE :-
```sql
SELECT username, SQL_REDO, SQL_UNDO FROM V$LOGMNR_CONTENTS
WHERE seg_owner = 'SCOTT' and seg_name like 'EMPLOYEES';
```
### 5. End LogMiner
Oracle LogMiner takes system resources and it does not release those resources
until you stop it:
SQL CODE :-
```sql
EXECUTE DBMS_LOGMNR.END_LOGMNR;
```
## Filtering LogMiner Contents
When you add log files and start LogMiner, you can view all the contents of the log files. If the log files are huge, then it's a good idea to use some filters to find out specific transactions.

### Filter with SCN Number
You can filter the log file contents between particular SCN numbers:
```sql
EXECUTE DBMS_LOGMNR.START_LOGMNR(
 STARTSCN => 280389,
 ENDSCN => 351390,
 OPTIONS => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG);
```
### Filter with Date & Time
You can filter the log file contents between particular date & time:

``` sql 
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';

EXECUTE DBMS_LOGMNR.START_LOGMNR(
 STARTTIME => '23-Nov-2001 11:23:00',
 ENDTIME => '23-Nov-2001 11:43:00',
 OPTIONS => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG);
```