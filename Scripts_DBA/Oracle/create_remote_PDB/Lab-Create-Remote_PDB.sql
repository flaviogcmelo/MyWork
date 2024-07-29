-- Instância de Origem denver:

ALTER SESSION SET CONTAINER=pdbdenver;

set lines 400
col name for a50
col pdb for a20
SELECT NAME, CREATION_DATE, PDB FROM V$SERVICES;

CREATE USER link IDENTIFIED BY senha;

GRANT CREATE PLUGGABLE DATABASE, SYSOPER, CREATE SESSION TO link;

-- Instancia de desetino orcl:

CREATE DATABASE LINK ORCLPDB CONNECT TO LINK IDENTIFIED BY senha USING 'ORCLPDB#';

CREATE PLUGGABLE DATABASE ORCLPDB2COPY FROM ORCLPDB2@ORCL2PDB SERVICE_NAME_CONVERT=('pdbdenver','orclpdb');

set lines 400
col name for a50
col pdb for a20
SELECT NAME, PDB FROM V$SERVICES;

!lsnrctl status | grep orclpdb2copy