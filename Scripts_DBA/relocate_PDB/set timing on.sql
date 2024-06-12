set timing on
drop user PERGAMUM_WEB_INT cascade;
drop user PERGAMUM cascade;
drop user SYSPERGAMUM cascade;



SQL> create bigfile tablespace ts_pergamum_d01 datafile size 11g autoextend on next 256m maxsize 31g;

Tablespace created.

SQL> create bigfile tablespace ts_pergamum_i01 datafile size 8m autoextend on next 256m maxsize 31g;

Tablespace created.

SQL> create bigfile tablespace ts_pergamum_l01 datafile size 8m autoextend on next 256m maxsize 31g;

Tablespace created.

SQL> create bigfile tablespace pergamarc datafile size 1G autoextend on next 256m maxsize 8G;

Tablespace created.

create bigfile tablespace ts_pergamum_d01 datafile size 11g autoextend on next 256m maxsize 31g;

create bigfile tablespace ts_pergamum_i01 datafile size 8m autoextend on next 256m maxsize 31g;

create bigfile tablespace ts_pergamum_l01 datafile size 8m autoextend on next 256m maxsize 31g;

create bigfile tablespace pergamarc datafile size 1G autoextend on next 256m maxsize 8G;

create role CATALOGACAO_GERAL;

create role GENERICO;

create role SAS_INEP07_CON;

create role BIBINTERNET;



-- ALTERNATIVA PARA MUDANÇA DO TAMANHO DAS COLUNAS PARA QUE NÃO HAJA PERDA DE DADOS NO IMPORT PARA OUTRO COLLATION


-- https://www.linkedin.com/pulse/ao-executar-o-impdp-error-ora-12899-value-too-large-column-sousa/?originalSubdomain=pt

/*
Ao executar o IMPDP: ERROR ORA-12899: value too large for column
No mundo teórico, onde vocês consultarem, vão mencionar que não é possivel resolver esse caso porque a instância destino está com diferença em algum NLS_DATABASE_PARAMETERES.
No mundo real, você poderia não ter mais acesso ao ambiente origem ou talvez não pudesse executar um novo export ajustando parâmetros. Sem contar que o mundo real tem prazos definidos para entregar resultados.
Pensando no que acontece no dia a dia e no que já me aconteceu, como se tratava de um schema legado, apenas de consulta, resolvi importar (IMPDP) a estrutura de tabelas primeiro usando o impdp com o parâmetro CONTENT=METADATA_ONLY.
Feito isso, executei o bloco abaixo, aumentando todas as colunas do tipo CHAR e VARCHAR2 em 10 posições (LENGTH):

*/



SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON SERVEROUTPUT ON

DECLARE 
	v_comando VARCHAR2(999);
BEGIN
	FOR i IN (SELECT 'ALTER TABLE ' || OWNER || '.' || TABLE_NAME || ' MODIFY (' || COLUMN_NAME || ' ' || DATA_TYPE || '(' || TO_CHAR(DATA_LENGTH + 10) || '))' AS COMANDO
	FROM DBA_TAB_COLUMNS
	WHERE OWNER='MEU_SCHEMA'
	AND DATA_TYPE IN ('VARCHAR2','CHAR')
	ORDER BY TABLE_NAME
	, DATA_TYPE)
	LOOP
		v_comando := i.comando;

		BEGIN
			--comentando para evitar problemas. Descomente a linha abaixo e comente a de output para colocar na execução
			EXECUTE IMMEDIATE v_comando;
			--DBMS_OUTPUT.PUT_LINE(v_comando);
		EXCEPTION WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Erro inesperado: ' || SQLCODE || '.');
		END;
	
	END LOOP;
END;
/
/*
Depois, importei os dados usando IMPDP com o parâmetro TABLE_EXISTS_ACTION=APPEND. Recomendo desabilitar chaves estrangeiras, chaves primárias, constraints e triggers antes disso e reabilitar somente depois que o impdp terminar.
Blocos para desabilitar e habilitar constraints:
*/

-- Desabilitar constraints

BEGIN


	FOR i IN (SELECT table_name, constraint_name -- Desabilita chaves estrangeiras primeiro
			  FROM dba_constraints
			  WHERE constraint_type ='R'
			  AND owner = 'MEU_SCHEMA'
			  AND status = 'ENABLED')
			  LOOP
				EXECUTE IMMEDIATE 'ALTER TABLE ' ||i.table_name|| ' DISABLE CONSTRAINT ' ||i.constraint_name;
			  END LOOP;
	FOR i IN (SELECT table_name, constraint_name -- Desabilita todo o resto
			  FROM dba_constraints
			  WHERE owner = 'MEU_SCHEMA'
			  AND status = 'ENABLED')
			  LOOP
				EXECUTE IMMEDIATE 'ALTER TABLE ' ||i.table_name|| ' DISABLE CONSTRAINT ' ||i.constraint_name;
			  END LOOP;
END;
/


-- Habilitar constraints
BEGIN
	FOR I IN (SELECT table_name, constraint_name -- Habilita todas as chaves que não forem estrangeiras
			  FROM dba_constraints
			  WHERE owner = 'MEU_SCHEMA'
			  AND constraint_type <> 'R'
			  AND status = 'DISABLE')
			  LOOP
				EXECUTE IMMEDIATE 'alter table ' ||i.table_name|| ' enable constraint ' ||i.constraint_name;
				
			  END LOOP;
	
	FOR i IN (SELECT table_name, constraint_name -- Habilita o que sobrou desabilitado, estrangeiras.
			  FROM dba_constraints
			  WHERE owner = 'MEU_SCHEMA'
			  AND status = 'DISABLE')
			  LOOP
			  
				EXECUTE IMMEDIATE 'alter table ' ||i.table_name|| ' enable constraint ' ||i.constraint_name;
				
			  END LOOP;
	
	END;
/