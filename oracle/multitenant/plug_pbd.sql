/*Verifica se o PDB está apto a ser plugado no CDB*/
set serveroutput on
DECLARE
   compatible BOOLEAN := FALSE;
BEGIN
   compatible := DBMS_PDB.CHECK_PLUG_COMPATIBILITY(
        pdb_descr_file => '/home/oracle/pdb_we8mswin1252_1922.pdb');
   if compatible then
      DBMS_OUTPUT.PUT_LINE('Is pluggable PDB compatible? YES');
   else DBMS_OUTPUT.PUT_LINE('Is pluggable PDB compatible? NO');
   end if;
END;
/

set line 200
col value for a40
col parameter for a40
select * from nls_database_parameters where parameter='NLS_CHARACTERSET';


alter pluggable database pdb1252 close immediate;

alter pluggable database pdb1252 unplug into '/home/bd_srvs_comum/pdb_template/pdb_we8mswin1252_1922-guapimirim.pdb';

/*Pluga o PDB no novo CDB*/
create pluggable database pdbsei using '/home/oracle/pdb_we8mswin1252_1922-guapimirim.pdb';

create pluggable database pdbsei using '/home/bd_srvs_comum/pdb_template/pdbsei.pdb';
