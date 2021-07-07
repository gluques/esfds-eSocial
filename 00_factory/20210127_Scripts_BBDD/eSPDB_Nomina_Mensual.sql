---------------------------------------------------------------------------------------------------------------------
--  eSPDB_Nomina_Mensual.sql
--	Recopilación de sentencias SQL asociadas a la nómina mensual.
-- 
--  Created by gluques. 
--  Barcelona, April 17, 2021. 
--  						  																					   								    
--  Last update: 17/04/2021
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
-- NOMINA MENSUAL
--
--  [01] FASES NOMINA MENSUAL
--  [02] TIPUS NOMINA MENSUAL
--  [03] TIPUS DE NOMINA
--  [04] ULTIMA NOMINA MENSUAL PER TIPUS NOMINA
--  [05] NOMINES MENSUALS PER UN TIPUS NOMINA 
--  
---------------------------------------------------------------------------------------------------------------------
SET SCHEMA 'esocial';
-----------------------------------------------------------------------
-- [01] FASES NOMINA MENSUAL
-----------------------------------------------------------------------
SELECT enmf.id, enmf.codi, enmf.nom_curt, lvi.descripcio
FROM eco_nomina_mensual_fase enmf	
	JOIN llistat_valors lv ON enmf.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY enmf.codi;
--
-- [02] TIPUS NOMINA MENSUAL
--
SELECT etnm.id, etnm.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_nomina_mensual etnm	
    JOIN llistat_valors lv ON etnm.llistat_valors_id = lv.id
    JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY codi;
-- 
-- [03] TIPUS DE NOMINA
-- 
SELECT tn.id, tn.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_nomina tn	
	JOIN llistat_valors lv ON tn.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY tn.codi;
--
-- [04] ULTIMA NOMINA MENSUAL PER TIPUS NOMINA
--
SELECT etep.id AS "T.Exp.Pres.",
       etp.id AS "T.Prestació",
       etn.id AS "T.Nòmina",
      (SELECT id FROM eco_nomina_mensual enm
       WHERE enm.tipus_nomina_id = etn.id AND enm.tipus_nomina_mensual_id = 1
       ORDER BY data_nomina DESC LIMIT 1) AS "Últ.Nòm.Men.",
      (SELECT TO_CHAR(data_nomina, 'DD-MM-YYYY') 
       FROM eco_nomina_mensual enm
       WHERE enm.tipus_nomina_id = etn.id AND enm.tipus_nomina_mensual_id = 1
       ORDER BY data_nomina DESC LIMIT 1) AS "Data",
      (SELECT estat FROM eco_nomina_mensual enm
       WHERE enm.tipus_nomina_id = etn.id AND enm.tipus_nomina_mensual_id = 1
       ORDER BY data_nomina DESC LIMIT 1) AS "Estat", 
      (SELECT TO_CHAR(data_inici_generacio, 'DD-MM-YYYY HH24:MI:SS') 
       FROM eco_nomina_mensual enm
       WHERE enm.tipus_nomina_id = etn.id AND enm.tipus_nomina_mensual_id = 1
       ORDER BY data_nomina DESC LIMIT 1) AS "Inici Generació",
      (SELECT lvi.descripcio FROM llistat_valors lv 
       JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
       WHERE etep.llistat_valors_id = lv.id) AS "T.P.Descripció",
      (SELECT lvi.descripcio FROM llistat_valors lv 
       JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
       WHERE etn.llistat_valors_id = lv.id) AS "T.N.Descripció"
FROM eco_tipus_expedient_prestacio etep
 LEFT JOIN eco_tipus_prestacio etp ON etep.id = etp.tipus_expedient_prestacio_id
 LEFT JOIN eco_tipus_prestacio_tipus_nomina tptn ON etp.id = tptn.tipus_prestacio_id
 LEFT JOIN eco_tipus_nomina etn ON tptn.tipus_nomina_id = etn.id
ORDER BY etep.id;
--
-- [05] NOMINES MENSUALS PER UN TIPUS NOMINA
--
SELECT * FROM eco_nomina_mensual enm 
WHERE enm.tipus_nomina_id = 13
  AND enm.tipus_nomina_mensual_id = 1
ORDER BY id DESC;

