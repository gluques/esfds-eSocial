---------------------------------------------------------------------------------------------------------------------
--  eSocial_DB_Quadre_Nomina.sql                                                                               
--	Recopilación de sentencias SQL SGBD PostgreSQL.
-- 
--  Created by Gregorio Luque Serrano.                                                                             
--  Barcelona, January 28, 2020.                                                                                 
--  						  																					   								    
--  Last update: 19/01/2021
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
--
-- POSTGRESQL
--
--		01. SELECCION DE ESQUEMA Y ROLE
--   	02. ESQUEMAS DISPONIBLES
--   	03. ESQUEMAS DE USUARIO Y PRIVILEGIOS
--   	04. ACTIVIDAD BBDD
--   	05. BLOQUEO DE TABLAS
--   	06. CONSULTA CATALOGO
--
---------------------------------------------------------------------------------------------------------------------
--
-- [01] SELECCION DE ESQUEMA Y ROLE
--
SET SCHEMA 'esocial';
SET ROLE esocial;
--
-- [02] ESQUEMAS DISPONIBLES
--
SELECT * FROM pg_catalog.pg_namespace;
--
-- [03] ESQUEMAS DE USUARIO Y PRIVILEGIOS
--
WITH "names"("name") 
  AS (SELECT n.nspname AS "name"
		FROM pg_catalog.pg_namespace n
	   WHERE n.nspname !~ '^pg_'
		  AND n.nspname <> 'information_schema'
     ) 
SELECT "name" AS "SCHEMA",
		 pg_catalog.has_schema_privilege(current_user, "name", 'CREATE') AS "CREATE",
  		 pg_catalog.has_schema_privilege(current_user, "name", 'USAGE')  AS "USAGE"
FROM "names";
--
-- [04] ACTIVIDAD BBDD
--
SELECT * FROM pg_stat_activity;
--
-- [05] BLOQUEO DE TABLAS
--
SELECT pg_class.relname, 
pg_locks.mode,
substr(pg_stat_activity.query,1,30), 
age(now(),pg_stat_activity.query_start) as "age", 
pg_stat_activity.pid 
FROM pg_stat_activity,pg_locks 
LEFT OUTER JOIN pg_class ON (pg_locks.relation = pg_class.oid)  
WHERE pg_locks.pid=pg_stat_activity.pid 
ORDER BY age DESC;
--
-- [06] CONSULTA CATALOGO
--
SELECT table_name, column_name FROM information_schema.columns
WHERE table_schema = 'esocial' 
  --AND table_name LIKE '%incidencia%'
  --OR column_name LIKE '%incidencia%'    
  --AND data_type = 'double precision';
    AND column_name LIKE '%persona%';
--
-- [07] SECUENCIAS
--    
SELECT n.nspname AS schemaname,
		 c.relname AS sequencename,
	    pg_get_userbyid(c.relowner) AS sequenceowner,
		 (s.seqtypid)::regtype AS data_type,
		 s.seqstart AS start_value,
	    s.seqmin AS min_value,
	    s.seqmax AS max_value,
		 s.seqincrement AS increment_by,
		 s.seqcycle AS cycle,
		 s.seqcache AS cache_size,
     	 CASE
         WHEN has_sequence_privilege(c.oid, 'SELECT,USAGE'::text) THEN pg_sequence_last_value((c.oid)::regclass)
         ELSE NULL::bigint
       END AS last_value
FROM ((pg_sequence s
  JOIN pg_class c ON ((c.oid = s.seqrelid)))
  LEFT JOIN pg_namespace n ON ((n.oid = c.relnamespace)))
WHERE ((NOT pg_is_other_temp_schema(n.oid)) AND (c.relkind = 'S'::"char"));    
--
-- Valor actual de la secuencia:
--
SELECT CURRVAL('llistat_valors_id_seq');
--
-- Mayor Id en una tabla:
--
SELECT MAX(id) FROM llistat_valors;
-- 
-- Establecer el valor de una secuencia:
--
SELECT SETVAL('llistat_valors_id_seq', 12452);
--
-- Obtener el siguiente valor de una secuencia:
--
SELECT NEXTVAL('llistat_valors_id_seq');