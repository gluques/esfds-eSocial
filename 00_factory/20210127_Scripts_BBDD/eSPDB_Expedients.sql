---------------------------------------------------------------------------------------------------------------------
--  eSocial_DB_Quadre_Nomina.sql                                                                               
--	Recull de sentències SQL associades als expedients.
-- 
--  Created by Gregorio Luque Serrano.                                                                             
--  Barcelona, January 28, 2020.                                                                                 
--  						  																					   								    
--  Last update: 08/07/2021
---------------------------------------------------------------------------------------------------------------------
--
-- INFORMACIO EXPEDIENTS
--
--	[01] TIPUS EXPEDIENT PRESTACIO 
--  [02] TIPUS PRESTACIO
--  [03] TIPOS PRESTACIO TIPUS NOMINA
--  [04] TIPOS DE NOMINA
--  [05] TIPUS EXPEDIENT PRESTACIO, TIPUS PRESTACIO, TIPUS PRESTACIO TIPUS NOMINA I TIPUS NOMINA
--	[06] TOTAL NOMINAS POR TIPOS Y ESTADO
--	[07] TIPUS TIPUS PRESTACIO Y TIPUS NOMINA PER UNA PRESTACIÓ EN PARTICULAR [¡¡¡¡¡INCORRECTA!!!!!]
--  [08] INFORMACION EXPEDIENTES SIN NOMINA (DATOS JSON ALTA)
--	[09] INFORMACION EXPEDIENTES CON NOMINA (DATOS JSON BAJA, MODIFICACION, ETC.)
--
---------------------------------------------------------------------------------------------------------------------
SET SCHEMA 'esocial';
--
-- [01] TIPUS EXPEDIENT-PRESTACIO
--
SELECT tep.id, tep.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_expedient_prestacio tep	
	JOIN llistat_valors lv ON tep.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY tep.codi;
--
-- [02] TIPUS PRESTACIO
--
SELECT tp.id, tp.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_prestacio tp	
	JOIN llistat_valors lv ON tp.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY tp.codi;
-- 
-- [03] TIPOS PRESTACIO TIPUS NOMINA
-- 
SELECT * 
FROM eco_tipus_prestacio_tipus_nomina;
-- 
-- [04] TIPOS DE NOMINA
-- 
SELECT tn.id, tn.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_nomina tn	
	JOIN llistat_valors lv ON tn.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY tn.codi;
--
-- [05] TIPUS EXPEDIENT PRESTACIO, TIPUS PRESTACIO, TIPUS PRESTACIO TIPUS NOMINA I TIPUS NOMINA
--
SELECT tep.id AS "Id",
		 tep.codi AS "Codi",
		(SELECT lvi.descripcio FROM llistat_valors lv 
		 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		 WHERE tep.llistat_valors_id = lv.id) AS "Tipus Expedient Prestació",
		 tp.id AS "Id",
		 tp.codi AS "Codi",
		 (SELECT lvi.descripcio FROM llistat_valors lv 
		  JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		  WHERE tp.llistat_valors_id = lv.id) AS "Tipus Prestació",
		 tn.id AS "Id",
		 tn.codi AS "Codi",
		 (SELECT lvi.descripcio FROM llistat_valors lv 
		  JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		  WHERE tn.llistat_valors_id = lv.id) AS "Tipus Nòmina"
FROM eco_tipus_expedient_prestacio tep
  FULL JOIN eco_tipus_prestacio tp ON tep.id = tp.tipus_expedient_prestacio_id
  FULL JOIN eco_tipus_prestacio_tipus_nomina tptn ON tp.id = tptn.tipus_prestacio_id
  FULL JOIN eco_tipus_nomina tn ON tptn.tipus_nomina_id = tn.id
ORDER BY tep.id, tp.id, tn.id;
--
-- [06] TOTAL NOMINAS POR TIPOS Y ESTADO
--
SELECT tep.id AS "T.Expedient",
		 tpr.id AS "T.Prestació",
		 nom.tipus_nomina_id AS "T.Nòmina",
		 COUNT(nom.*) AS "Total Nòmines",
		 (SELECT lvi.descripcio 
		  FROM eco_tipus_nomina tno
		   JOIN llistat_valors lv ON tno.llistat_valors_id = lv.id
		   JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		  WHERE tno.id = nom.tipus_nomina_id) AS "T.Nòmina Descripció"
FROM eco_nomina nom
JOIN eco_tipus_prestacio_tipus_nomina tptn ON nom.tipus_nomina_id = tptn.tipus_nomina_id
JOIN eco_tipus_prestacio tpr ON tptn.tipus_prestacio_id = tpr.id
JOIN eco_tipus_expedient_prestacio tep ON tpr.tipus_expedient_prestacio_id = tep.id
WHERE tep.id IN (1, 2, 3, 4)
  AND nom.estat_id IN (1, 3)
GROUP BY tep.id, tpr.id, nom.tipus_nomina_id
ORDER BY tep.id;
--
-- [07] TIPUS TIPUS PRESTACIO Y TIPUS NOMINA PER UNA PRESTACIÓ EN PARTICULAR [INCORRECTA]
-- 
SELECT pre.id AS "Prestació",	
		 etep.id AS "T.Exp.Pres.",
		 etp.id AS "T.Prestació",
		 etn.id AS "T.Nòmina",
		 lvi.descripcio AS "T.Prestació.",
		 (SELECT lvi.descripcio FROM llistat_valors lv 
		  JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		  WHERE etn.llistat_valors_id = lv.id) AS "T.Nòmina"
FROM prestacio pre
	JOIN expedient_prestacio epr ON pre.expedient_prestacio_id = epr.id
	JOIN eco_tipus_expedient_prestacio etep ON epr.tipus_expedient_prestacio_id = etep.id
	JOIN eco_tipus_prestacio etp ON etep.id = etp.tipus_expedient_prestacio_id
	JOIN eco_tipus_prestacio_tipus_nomina etptn ON etp.tipus_nomina_id = etptn.tipus_nomina_id AND etp.id = etptn.tipus_prestacio_id
	JOIN eco_tipus_nomina etn ON etptn.tipus_nomina_id = etn.id
	JOIN llistat_valors lv ON etp.llistat_valors_id = lv.id
 	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id 	
WHERE pre.id = 308;

SELECT etn.*
FROM eco_tipus_nomina etn
 JOIN eco_tipus_prestacio_tipus_nomina tptn ON etn.id = tptn.tipus_nomina_id
WHERE tptn.tipus_prestacio_id = 8;
--
-- --------------------------------
-- Información JSON actuació nómina
-- --------------------------------
--
-- Los datos mínimos necesarios para la generación de cualquier JSON de "Actuació 
-- en Nòmina" son:
-- 
--      Id del Expedient    (expedient_prestacio.id)
--      Id del Procediment  (procediment_prestacio.id)
--      Id del Tramit       (tramit_prestacio.id)
--      Id de la Prestació  (prestacio.id)
--
-- Sigamos el método que sigamos, lo primero será determinar el tipo de prestación 
-- que deseamos crear; consultar [01.001].
--
-- El proceso de selección de los datos del JSON requiere de la consulta de las 
-- siguientes tablas:
--
--	a) PRESTACIO: seleccionamos una de las disponibles y anotamos "expedient_prestacio_id":
       SELECT * FROM prestacio WHERE dret_id IS NULL AND tipus_prestacio_id = 6;
--
--  b) EXPEDIENT PRESTACIO: empleamos "expedient_prestacio_id" para filtrar, obtendremos
--     "persona_id" y "expedient_prestacio_id"; no son datos necesarios para el JSON:
       SELECT * FROM expedient_prestacio WHERE id = 6;
--
--  c) PROCEDIMENT PRESTACIO: empleamos "expedient_prestacio_id" para filtrar y anotamos
--     el "id" del registro obtenido (aquí localizamos el "numero_expediente"):
       SELECT * FROM procediment_prestacio WHERE expedient_prestacio_id = 6;    --  (*)
--       
--  d) TRAMIT PRESTACIO: seleccionamos un "id" cualquiera de los que se muestran, no
--     dispongo de criterio para ello.
       SELECT * FROM tramit_prestacio WHERE procediment_prestacio_id = 5;
--
-- 	(*) Para una Prestación-Expedient-Procediment se dispone de más de un Tramit.
--      No dispongo de criterio para seleccionar uno u otro Tramit, pero el JSON 
--      funcionará con cualquiera de ellos.
--
-- [08] INFORMACION EXPEDIENTES SIN NOMINA (DATOS JSON ALTA)
--      Estas prestaciones no disponen de nómina alguna, por tanto están 
--      disponibles para su empleo en una actuación en nómina de alta.
--
SELECT
     epr.numero_expedient                                   AS "Num.Expedient",	
     epr.id                                                 AS "Expedient",
     ppr.id                                                 AS "Procediment",
     (SELECT tpr.id FROM tramit_prestacio tpr
      WHERE tpr.procediment_prestacio_id = ppr.id
      ORDER BY tpr.id LIMIT 1)                              AS "Tramit",
     pre.id                                                 AS "Prestació",     
     epr.solicitud_id                                       AS "Solicitud",
     epr.tipus_expedient_prestacio_id                       AS "T.Exp.Pres.",
     pre.tipus_prestacio_id                                 AS "T.Prestació",
     per.id                                                 AS "Persona",
     ide.valor                                              AS "Identificador",
     per.nom || ' ' || per.cognom1 || ' ' || per.cognom2    AS "Nom i Cognoms"
FROM prestacio pre
	JOIN expedient_prestacio epr ON epr.id = pre.expedient_prestacio_id
	JOIN procediment_prestacio ppr ON ppr.expedient_prestacio_id = epr.id
	JOIN persona per ON per.id = epr.persona_id
	JOIN identificador ide ON ide.persona_id = per.id
WHERE pre.dret_id IS NULL
  AND pre.tipus_prestacio_id = 6
ORDER BY epr.numero_expedient LIMIT 50;
--
-- [09] INFORMACION EXPEDIENTES CON NOMINA (DATOS JSON BAJA, MODIFICACION, ETC.)
--      Estas prestaciones disponen de nómina, por lo que están disponibles 
--      para realizar una actuación de baja, modificación, etc.
--
SELECT DISTINCT 
     epr.numero_expedient                                    AS "Num.Expedient", 
     nom.id                                                  AS "Nòmina",
     nom.estat_id                                            AS "Estat Nòm.",
     epr.id                                                  AS "Expedient",
     emo.procediment_id                                      AS "Procediment",
     emo.tramit_id                                           AS "Tramit",
     pre.id                                                  AS "Prestació",
     pre.dret_id                                             AS "Dret",
     epr.solicitud_id                                        AS "Solicitud",
     per.id                                                  AS "Persona",		 
     emo.id                                                  AS "Moviment",
     emd.id                                                  AS "Mov.Detall",
     emd.import_moviment || '€'                              AS "Import",	
     emd.data_efecte_inicial                                 AS "Efecte inicial",
     emd.data_efecte_final                                   AS "Efecte final",
     lvi.descripcio || ' [' || pre.tipus_prestacio_id || ']' AS "Tipus Prestació",
     ide.valor                                               AS "Identificador",
     per.nom || ' ' || per.cognom1 || ' ' || per.cognom2     AS "Nom i Cognoms",
     ban.iban                                                AS "IBAN",
     emo.contingut_moviment                                  AS "JSON"
FROM eco_nomina nom 
	JOIN eco_moviment_detall emd ON emd.nomina_id = nom.id
	JOIN eco_moviment emo ON emo.id = emd.moviment_id
	JOIN eco_nomina_persona enp ON enp.nomina_id = nom.id
	JOIN persona per ON per.id = enp.persona_id
	JOIN identificador ide ON ide.persona_id = per.id
	JOIN dades_bancaries ban ON ban.persona_id = per.id
	JOIN expedient_prestacio epr ON epr.persona_id = per.id
	JOIN prestacio pre ON pre.expedient_prestacio_id = epr.id
	JOIN eco_tipus_prestacio etp ON pre.tipus_prestacio_id = etp.id
	JOIN llistat_valors lva ON etp.llistat_valors_id = lva.id
	JOIN llistat_valors_idioma lvi ON lva.id = lvi.llistat_valors_id
WHERE pre.dret_id IS NOT NULL
	 AND ide.data_fi IS NULL
  --AND nom.tipus_nomina_id = 13
  AND pre.tipus_prestacio_id = 6
  --AND epr.numero_expedient = '00002/2019/168'
  --AND pre.dret_id = 174
  --AND nom.id = 174
  --AND pre.id = 594
ORDER BY emo.id;