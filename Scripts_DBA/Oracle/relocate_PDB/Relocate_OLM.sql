-- Realocação de PDBs
-- Dia 2 Manhã 1:51:07

-- source Carapebus1
-- dest EMREP


-- RELOCATE PDB PARA OUTRO HOST

-- Create common user and grant needed privileges
create user c##root_dba identified by "MigraPDB123" account unlock;

GRANT CREATE SESSION, CREATE PLUGGABLE DATABASE, SYSOPER TO c##root_dba CONTAINER=ALL;

-- source
col property_name for a30
col property_value for a30
SELECT PROPERTY_NAME, PROPERTY_VALUE 
FROM   DATABASE_PROPERTIES 
WHERE  PROPERTY_NAME = 'LOCAL_UNDO_ENABLED';

SELECT LOG_MODE FROM V$DATABASE;

-- Connected to Source CDB$ROOT
ALTER SESSION SET CONTAINER=[target container];

SELECT DBID, NAME, CREATED FROM V$DATABASE;

-- dest

CREATE PUBLIC DATABASE LINK relocatedb CONNECT TO c##root_dba IDENTIFIED BY [PASSWORD] USING 'DEST_TNS_ENTRANCE';

-- omf habilitado
show parameter db_create

-- acompanhar alerts

tail -f $ORACLE_BASE/diag/rdbms/orcl2/orcl2/trace/alert

tail -f $ORACLE_BASE/diag/rdbms/orcl/orcl/trace/alert

CREATE PLUGGABLE DATABASE pdb FROM pdb5@orcl2link RELOCATE AVAILABILITY NORMAL;

ALTER PLUGGABLE DATABASE pdb OPEN;

-- source

DROP PLUGGABLE DATABASE pdb INCLUDING DATAFILES;



-- realocação via dbca silent mode

-- source

SELECT PROPERTY_NAME, PROPERTY_VALUE 
FROM   DATABASE_PROPERTIES 
WHERE  PROPERTY_NAME = 'LOCAL_UNDO_ENABLED';

SELECT LOG_MODE FROM V$DATABASE;

CREATE USER c##conector IDENTIFIED BY senha;

GRANT CREATE SESSION, CREATE PLUGGABLE DATABASE, SYSOPER TO c##conector CONTAINER=ALL;

ALTER SESSION SET CONTAINER=orclpdb2;

create user teste identified by senha;

grant dba, resource, connect to teste;

sqlplus teste/senha@ol7-dba:1521/orclpdb2.localdomain
-- ou
sqlplus teste/senha@orclpdb2

SELECT DBID, NAME, CREATED FROM V$DATABASE;

-- dest

dbca -silent  \
-relocatePDB \
-sourceDB orcl2   \
-remotePDBName orclpdb2  \
-remoteDBConnString ol7-dba:1521/orcl.localdomain  \
-remoteDBSYSDBAUserName sys  \
-remoteDBSYSDBAUserPassword senha  \
-dbLinkUsername c##conector  \
-dbLinkUserPassword senha  \
-sysDBAUserName sys  \
-sysDBAPassword senha \
-pdbName orclpdb2

sqlplus teste/senha@orclpdb2

SELECT DBID, NAME, CREATED FROM V$DATABASE;

dbca -silent  \
-relocatePDB \
-sourceDB cdb3   \
-remotePDBName pdb5  \
-remoteDBConnString ol7-dba2:1521/orcl2.localdomain  \
-remoteDBSYSDBAUserName sys  \
-remoteDBSYSDBAUserPassword senha  \
-dbLinkUsername c##conector  \
-dbLinkUserPassword senha  \
-sysDBAUserName sys  \
-sysDBAPassword senha \
-pdbName pdb5