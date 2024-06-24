-- Origem dos scripts
-- https://oracle-base.com/dba/scripts
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/library_cache.sql
-- Author       : Tim Hall
-- Description  : Displays library cache statistics.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @library_cache
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINE WINDOW
SET PAGESIZE 1000
SET VERIFY OFF

SELECT a.namespace "Name Space",
       a.gets "Get Requests",
       a.gethits "Get Hits",
       Round(a.gethitratio,2) "Get Ratio",
       a.pins "Pin Requests",
       a.pinhits "Pin Hits",
       Round(a.pinhitratio,2) "Pin Ratio",
       a.reloads "Reloads",
       a.invalidations "Invalidations"
FROM   v$librarycache a
ORDER BY 1;

SET VERIFY ON


-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/cache_hit_ratio.sql
-- Author       : Tim Hall
-- Description  : Displays cache hit ratio for the database.
-- Comments     : The minimum figure of 89% is often quoted, but depending on the type of system this may not be possible.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @cache_hit_ratio
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
PROMPT
PROMPT Hit ratio should exceed 89%

SELECT Sum(Decode(a.name, 'consistent gets', a.value, 0)) "Consistent Gets",
       Sum(Decode(a.name, 'db block gets', a.value, 0)) "DB Block Gets",
       Sum(Decode(a.name, 'physical reads', a.value, 0)) "Physical Reads",
       Round(((Sum(Decode(a.name, 'consistent gets', a.value, 0)) +
         Sum(Decode(a.name, 'db block gets', a.value, 0)) -
         Sum(Decode(a.name, 'physical reads', a.value, 0))  )/
           (Sum(Decode(a.name, 'consistent gets', a.value, 0)) +
             Sum(Decode(a.name, 'db block gets', a.value, 0))))
             *100,2) "Hit Ratio %"
FROM   v$sysstat a;


-- -----------------------------------------------------------------------------------
-- File Name    : 
-- Author       : Flávio Melo
-- Description  : Script para verificar se o PDB é compativel para conversão
-- Comments     : 
-- Requirements : Acesso a DBMS_PDB.
-- Call Syntax  : 
-- Last Modified: 24/06/2024
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  l_result BOOLEAN;
BEGIN
  l_result := DBMS_PDB.check_plug_compatibility(
                pdb_descr_file => '/home/oracle/pdb1.pdb',
                pdb_name       => 'datamasking');

  IF l_result THEN
    DBMS_OUTPUT.PUT_LINE('compatible');
  ELSE
    DBMS_OUTPUT.PUT_LINE('incompatible');
  END IF;
END;
/