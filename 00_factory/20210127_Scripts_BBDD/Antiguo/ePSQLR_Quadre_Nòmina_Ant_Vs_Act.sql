---------------------------------------------------------------------------------------------------------------------
-- eSocial_DB_Quadre_Nomina.sql                                                                               
--	Recopilación de sentencias SQL asociadas al Quadre de Nòmina Anterior Vs. Actual.
-- 
--  Created by Gregorio Luque Serrano.                                                                             
--  Barcelona, January 28, 2020.                                                                                 
--  						  																					   								    
--  Last update: 11/01/2021
---------------------------------------------------------------------------------------------------------------------
-- 01.QUADRE DE NÒMINA ANTERIOR VS. ACTUAL
--
--		01.01. TIPUS PAGAMENT CONCEPTE
--		01.02. TIPUS PAGAMENT MODALITAT
--		01.03. TIPUS PAGAMENT TIPUS
--		01.04. TIPUS EFECTES

--		05. TOTES LES NOMINES, ACTIVIDTATS DETALL I EFECTES
--		06. TOTES LES NOMINES Y EFECTES
--		07. NOMINES AMB MES D'UN EFECTE
--		08. TOTAL TIPUS D'EFECTES APLICATS
--      09. PROCEDIMENT QUANTITAT
--
--      Pendent de verificació:
--
--		04.08. IMPORTE TOTAL ORDINARIES ALTES
--		04.09. IMPORTE TOTAL ORDINARIES BAIXES
--		04.10. IMPORTE TOTAL ENDARRERIMENTS ALTES
--		04.11. IMPORTE TOTAL LIQUIDACIONS
--		04.12. IMPORTE TOTAL PAGAMENT EXTRAORDINARI
--
---------------------------------------------------------------------------------------------------------------------
SET SCHEMA 'esocial';
--
-- [01.01] TIPUS PAGAMENT CONCEPTE
--
SELECT tac.id, tac.codi, lv.acronim, lvi.descripcio
FROM tipus_activitat_concepte tac	
	JOIN llistat_valors lv ON tac.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY tac.codi;
--
-- [01.02] TIPUS PAGAMENT MODALITAT
--
SELECT tpm.id, tpm.codi, lv.acronim, lvi.descripcio
FROM tipus_pagament_modalitat tpm	
	JOIN llistat_valors lv ON tpm.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY tpm.codi;
--
-- [01.03] TIPUS PAGAMENT TIPUS
--
SELECT tpt.id, tpt.codi, lv.acronim, lvi.descripcio
FROM tipus_pagament_tipus tpt	
	JOIN llistat_valors lv ON tpt.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY tpt.codi;
--
-- [01.04] TIPUS EFECTES
--
SELECT eten.id, eten.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_efecte_nomina eten	
	JOIN llistat_valors lv ON eten.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY eten.codi;
--
-- [01.05] TIPUS NOMINA MENSUAL
--
SELECT etnm.id, etnm.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_nomina_mensual etnm	
    JOIN llistat_valors lv ON etnm.llistat_valors_id = lv.id
    JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY codi;
-- 
-- [01.06] TIPOS DE NOMINA
-- 
SELECT tn.id, tn.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_nomina tn	
	JOIN llistat_valors lv ON tn.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY tn.codi;
--
-- [01.07] LLISTA NOMINES MENSUALS D'UN TIPUS NOMINA
--
SELECT enm.* 
FROM eco_nomina_mensual enm 
WHERE enm.tipus_nomina_id = 13 
ORDER BY id DESC;
--
-- [01.08] ACTIVITAT DETALL NOMINA MENSUAL 
--
SELECT actdet.*
FROM eco_activitat_detall actdet
WHERE actdet.nomina_mensual_id = 59
ORDER BY actdet.nomina_id;
--
-- [01.09] TOTAL NOMINA
--
SELECT TO_CHAR(FLOAT8 (SUM(actdet.quantitat)), 'FM999999999.00') AS "Total nòmina (IMTN)"	
FROM eco_activitat_detall actdet
WHERE actdet.nomina_mensual_id = 59;
--
-- [01.10] BENEFICIARIS I TOTAL NOMINA ORDINARIA
--
SELECT COUNT(actdet.nomina_id) AS "Beneficiaris nòmina ordinària (BENO)",
		 TO_CHAR(FLOAT8 (SUM(actdet.quantitat)), 'FM999999999.00') AS "Total nomina ordinària (IMTO)"	
FROM eco_activitat_detall actdet
WHERE actdet.nomina_mensual_id = 59
  AND actdet.pagament_tipus_id = 1;
--
-- [01.11] BENEFICIARIS I IMPORT ALTES ORDINARIA
--
SELECT COUNT(actdet.nomina_id) AS "Beneficiaris altes ordinària (BEAL)",
		 TO_CHAR(FLOAT8 (SUM(actdet.quantitat)), 'FM999999999.00') AS "Import altes ordinària (IMAL)"	
FROM eco_activitat_detall actdet
WHERE actdet.nomina_mensual_id = 59
  AND actdet.pagament_tipus_id = 1
  AND actdet.nomina_id IN (
		SELECT DISTINCT actdet.nomina_id
		FROM eco_activitat_detall actdet
			JOIN eco_activitat act ON actdet.activitat_id = act.id
			JOIN eco_moviment mov ON act.moviment_id = mov.id
			JOIN eco_moviment_detall movdet ON mov.id = movdet.moviment_id,
			eco_efecte_moviment_nomina efemovnom
		WHERE movdet.id = efemovnom.moviment_detall_id
		  AND actdet.nomina_mensual_id = 59
		  AND efemovnom.data_efecte_inici <= '2021-02-01 00:00:00'
		  AND (efemovnom.data_efecte_fi IS NULL OR efemovnom.data_efecte_fi >= actdet.data_efecte)
		  AND efemovnom.data_efecte_inici <= actdet.data_efecte
		  AND efemovnom.tipus_id = 1
);

--
-- [01.13] IMPORT MODIFICACIONS ORDINARIA
--
SELECT COUNT(actdet.nomina_id) AS "Total nòmines modificacions ordinària",
		 TO_CHAR(FLOAT8 (SUM(actdet.quantitat)), 'FM999999999.00') AS "Import modificacions ordinària (IMMI)"	
FROM eco_activitat_detall actdet
WHERE actdet.nomina_mensual_id = 59
  AND actdet.pagament_tipus_id = 1
  AND actdet.nomina_id IN (
		SELECT DISTINCT actdet.nomina_id
		FROM eco_activitat_detall actdet
			JOIN eco_activitat act ON actdet.activitat_id = act.id
			JOIN eco_moviment mov ON act.moviment_id = mov.id
			JOIN eco_moviment_detall movdet ON mov.id = movdet.moviment_id,
			eco_efecte_moviment_nomina efemovnom
		WHERE movdet.id = efemovnom.moviment_detall_id
		  AND actdet.nomina_mensual_id = 59
		  AND efemovnom.data_efecte_inici = '2021-02-01 00:00:00'
		  AND efemovnom.tipus_id = 19
);



--
-- Beneficiaris e imports:
--
SELECT lv.id AS "Id Concepte",
		 lv.acronim AS "Acronim Concepte",
		 lvi.descripcio AS "Descripció Concepte",
		 lva.id AS "Id Agrupació",
		 lva.acronim AS "Acronim Agrupació",
		 lvai.descripcio AS "Descripció Agrupació"		 
FROM llistat_valors lv
	JOIN llistat_valors_agrupacions lva ON lv.llistat_valors_agrupacions_id = lva.id
	JOIN llistat_valors_agrupacions_idioma lvai ON lva.id = lvai.llistat_valors_agrupacions_id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
	JOIN idioma i ON lvi.idioma_id = i.id
WHERE lva.acronim IN ('NUMBE', 'IMPRT')
ORDER BY lva.acronim DESC, lv.acronim;

--
-- Llistat de quantitats Quadre amb agrupació i descripció de conceptes:
--
SELECT nmq.*, 
		 lvai.descripcio AS "Agrupació", 
		 lvi.descripcio AS "Concepte"
FROM eco_nomina_mensual_quantitat nmq
 JOIN llistat_valors lv ON nmq.tipus_quantitat_nomina_id = lv.acronim
 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
 JOIN llistat_valors_agrupacions lva ON lv.llistat_valors_agrupacions_id = lva.id
 JOIN llistat_valors_agrupacions_idioma lvai ON lva.id = lvai.llistat_valors_agrupacions_id
WHERE nomina_mensual_id = 65
ORDER BY lva.acronim DESC, lv.acronim;




--
-- [01.09] NOMINAS CON ACTIVITAT DETALL EN NOMINA MENSUAL
-- 
SELECT DISTINCT actdet.nomina_id
FROM eco_activitat_detall actdet
WHERE actdet.nomina_mensual_id = 55
ORDER BY actdet.nomina_id;
--
-- [01.08] NOMINAS EN NOMINA MENSUAL ACTUAL NO ANTERIOR (Altas, Rehabilitacions)
--			  NOMINAS EN NOMINA MENSUAL ANTERIOR NO ACTUAL (Bajas)
--
--			  Nota: para ejecutar una consulta u otra, intercambiar los Ids de 
--					  las nóminas mensuales.
--
SELECT DISTINCT actdet.nomina_id
FROM eco_activitat_detall actdet
WHERE actdet.nomina_mensual_id = 55
  AND actdet.nomina_id NOT IN (SELECT DISTINCT actdet.nomina_id
										 FROM eco_activitat_detall actdet
										 WHERE actdet.nomina_mensual_id = 47)
ORDER BY actdet.nomina_id;

--
-- [01.12] Datos expedientes nòminas altas:
--
SELECT DISTINCT 
   epr.numero_expedient AS "Num.Expedient", 
   nom.id AS "Nòmina",
   nom.data_alta_nomina AS "D.Alta Nòmina",
   nom.data_primera_execucio AS "D.Pri. Excecució",
   per.id AS "Persona",
   ide.valor AS "Identificador"
FROM eco_nomina nom
 JOIN eco_dret dre ON nom.id = dre.nomina_id
 JOIN prestacio pre ON dre.id = pre.dret_id
 JOIN expedient_prestacio epr ON pre.expedient_prestacio_id = epr.id
 JOIN persona per ON epr.persona_id = per.id
 JOIN identificador ide ON per.id = ide.persona_id
WHERE nom.id IN (SELECT DISTINCT actdet.nomina_id
					  FROM eco_activitat_detall actdet
					  WHERE actdet.nomina_mensual_id = 63
					    AND actdet.nomina_id NOT IN (SELECT DISTINCT actdet.nomina_id
						  									   FROM eco_activitat_detall actdet
															   WHERE actdet.nomina_mensual_id = 59))
ORDER BY nom.data_alta_nomina;

--
-- [01.09] NOMINES AMB CANVI D'IMPORT
--
SELECT DISTINCT actNMActual.*
FROM (SELECT * FROM eco_activitat_detall
		WHERE nomina_mensual_id = 55
  		  AND pagament_modalitat_id = 1
  		  AND pagament_tipus_id = 1) actNMActual,
     (SELECT * FROM eco_activitat_detall
		WHERE nomina_mensual_id = 47
  		  AND pagament_modalitat_id = 1
  		  AND pagament_tipus_id = 1) actNMAnterior
WHERE actNMActual.nomina_id = actNMAnterior.nomina_id
  AND actNMActual.quantitat <> actNMAnterior.quantitat; 

SELECT DISTINCT actdet.nomina_id
FROM eco_activitat_detall actdet
WHERE actdet.nomina_mensual_id = 55
  AND actdet.pagament_modalitat_id = 1
  AND actdet.pagament_tipus_id = 1
  AND actdet.nomina_id IN (SELECT DISTINCT nomina_id
									FROM eco_activitat_detall
									WHERE nomina_mensual_id = 47
									  AND pagament_modalitat_id = 1
								     AND pagament_tipus_id = 1)
  AND actdet.quantitat <> (SELECT quantitat FROM eco_activitat_detall
  									WHERE nomina_mensual_id = 47
  									  AND pagament_modalitat_id = 1
								     AND pagament_tipus_id = 1
								     AND nomina_id = actdet.nomina_id)  																		
ORDER BY actdet.nomina_id;


--
-- [06] TOTES LES NOMINES Y EFECTES
--
SELECT DISTINCT actdet.nomina_id AS "Id Nòmina",
					 efemovnom.tipus_id AS "Id T.Efecte",					 
					 (SELECT lvi.descripcio FROM  eco_tipus_efecte_nomina eten	
					 	 JOIN llistat_valors lv ON eten.llistat_valors_id = lv.id
						 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
					  WHERE eten.id = efemovnom.tipus_id) AS "Descripció",
					  efemovnom.import_actual AS "Import Actual",
					  efemovnom.import_anterior AS "Import Anterior",
					  efemovnom.diferencial AS "Diferencial"					  
FROM eco_activitat_detall actdet
	JOIN eco_activitat act ON actdet.activitat_id = act.id
	JOIN eco_moviment mov ON act.moviment_id = mov.id
	JOIN eco_moviment_detall movdet ON mov.id = movdet.moviment_id,
	eco_efecte_moviment_nomina efemovnom
WHERE movdet.id = efemovnom.moviment_detall_id
  AND actdet.nomina_mensual_id = 55
  AND efemovnom.data_efecte_inici <= '2021-01-01 00:00:00'
  AND (efemovnom.data_efecte_fi IS NULL OR efemovnom.data_efecte_fi >= actdet.data_efecte)
  AND efemovnom.data_efecte_inici <= actdet.data_efecte
  --AND efemovnom.tipus_id IN (1, 6)      -- Alta i Continuació d'Alta
  --AND efemovnom.tipus_id IN (3, 16)     -- Baixa i Continuació de Baixa
  --AND efemovnom.tipus_id IN (19, 20)    -- Modificació i Continuació de Modificació
  --AND efemovnom.tipus_id IN (2, 15)     -- Rehabilitació i Continuació de Rehabilitació
  --AND actdet.nomina_id IN (308, 309, 310, 311, 312, 313, 314, 315)
ORDER BY actdet.nomina_id;
--
-- [07] NÒMINES I NOMBRE EFECTES EMPLEATS
--
SELECT consulta.nominaId AS "Id Nòmina",
		 COUNT(consulta.efectoTipo) AS "T.Efectes"
FROM (
	SELECT DISTINCT actdet.nomina_id AS nominaId,
			  		 	 efemovnom.tipus_id AS efectoTipo
	FROM eco_activitat_detall actdet
		JOIN eco_activitat act ON actdet.activitat_id = act.id
		JOIN eco_moviment mov ON act.moviment_id = mov.id
		JOIN eco_moviment_detall movdet ON mov.id = movdet.moviment_id,
		eco_efecte_moviment_nomina efemovnom
	WHERE movdet.id = efemovnom.moviment_detall_id
	  AND actdet.nomina_mensual_id = 55
	  AND efemovnom.data_efecte_inici <= '2021-01-01 00:00:00'
	  AND (efemovnom.data_efecte_fi IS NULL OR efemovnom.data_efecte_fi >= actdet.data_efecte)
	  AND efemovnom.data_efecte_inici <= actdet.data_efecte
) consulta
GROUP BY consulta.nominaId
--HAVING COUNT(consulta.efectoTipo) > 1
ORDER BY consulta.nominaId;
--
-- [08] TOTAL TIPUS D'EFECTES APLICATS
--
SELECT efemovnom.tipus_id AS "Id T.Efecte", 
		 (SELECT lvi.descripcio FROM  eco_tipus_efecte_nomina eten	
		 	 JOIN llistat_valors lv ON eten.llistat_valors_id = lv.id
			 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		  WHERE eten.id = efemovnom.tipus_id) AS "Descripció",
		 COUNT(efemovnom.tipus_id) AS "Total efectes"					  
FROM eco_activitat_detall actdet
	JOIN eco_activitat act ON actdet.activitat_id = act.id
	JOIN eco_moviment mov ON act.moviment_id = mov.id
	JOIN eco_moviment_detall movdet ON mov.id = movdet.moviment_id,
	eco_efecte_moviment_nomina efemovnom
WHERE movdet.id = efemovnom.moviment_detall_id
  AND actdet.nomina_mensual_id = 55
  AND efemovnom.data_efecte_inici <= '2021-01-01 00:00:00'
  AND (efemovnom.data_efecte_fi IS NULL OR efemovnom.data_efecte_fi >= actdet.data_efecte)
  AND efemovnom.data_efecte_inici <= actdet.data_efecte
GROUP BY efemovnom.tipus_id
ORDER BY efemovnom.tipus_id;
--
--  [09] PROCEDIMENT QUANTITAT
-- 		 Nota: aquest registres es crean a les fases 'CONT' i 'ORDN'
--
SELECT * FROM eco_nomina_mensual_procediment_quantitat 
WHERE nomina_mensual_procediment_id IN (SELECT id FROM eco_nomina_mensual_procediment 
													 WHERE nomina_mensual_id = 55);
--
-- [10] RESULTATS QUADRE [NO FINALIZADO]
--													 
SELECT id, rcd_crt_ts, tipus_quantitat_nomina_id, quantitat, 'Beneficiaris nòmina ordinària mes anterior' AS "Descripció"
FROM eco_nomina_mensual_quantitat 
WHERE nomina_mensual_id = 47 AND tipus_quantitat_nomina_id = 'BETO'
UNION
SELECT id, rcd_crt_ts, tipus_quantitat_nomina_id, quantitat, 'Altes' AS "Descripció"
FROM eco_nomina_mensual_quantitat 
WHERE nomina_mensual_id = 55 AND tipus_quantitat_nomina_id = 'BEAL'
UNION
SELECT id, rcd_crt_ts, tipus_quantitat_nomina_id, quantitat, 'Baixes' AS "Descripció"
FROM eco_nomina_mensual_quantitat 
WHERE nomina_mensual_id = 55 AND tipus_quantitat_nomina_id = 'BEBA'
UNION
SELECT id, rcd_crt_ts, tipus_quantitat_nomina_id, quantitat, 'Rehabilitacions' AS "Descripció"
FROM eco_nomina_mensual_quantitat 
WHERE nomina_mensual_id = 55 AND tipus_quantitat_nomina_id = 'BERE'
UNION
SELECT id, rcd_crt_ts, tipus_quantitat_nomina_id, quantitat, 'Suspeses' AS "Descripció"
FROM eco_nomina_mensual_quantitat 
WHERE nomina_mensual_id = 55 AND tipus_quantitat_nomina_id = 'BSUS'
UNION
SELECT id, rcd_crt_ts, tipus_quantitat_nomina_id, quantitat, 'Beneficiaris nòmina ordinària' AS "Descripció"
FROM eco_nomina_mensual_quantitat 
WHERE nomina_mensual_id = 55 AND tipus_quantitat_nomina_id = 'BENO'
UNION
SELECT id, rcd_crt_ts, tipus_quantitat_nomina_id, quantitat, 'Beneficiaris nòmina no ordinària' AS "Descripció"
FROM eco_nomina_mensual_quantitat 
WHERE nomina_mensual_id = 55 AND tipus_quantitat_nomina_id = 'BENN'
UNION
SELECT id, rcd_crt_ts, tipus_quantitat_nomina_id, quantitat, 'Beneficiaris nòmina no ordinària de baixa' AS "Descripció"
FROM eco_nomina_mensual_quantitat 
WHERE nomina_mensual_id = 55 AND tipus_quantitat_nomina_id = 'BENB';
UNION
SELECT id, rcd_crt_ts, tipus_quantitat_nomina_id, quantitat, 'Total beneficiaris' AS "Descripció"
FROM eco_nomina_mensual_quantitat 
WHERE nomina_mensual_id = 55 AND tipus_quantitat_nomina_id = 'BETO';



---------------------------------------------------------------------------------------------------------------------
-- Pendiente de verificación !!!!!!!!!!!!!!!!!!!!!!!!!!!
---------------------------------------------------------------------------------------------------------------------
--
-- [04.08] IMPORTE TOTAL ORDINARIES ALTES
--			  
SELECT DISTINCT COUNT(actdet.nomina_id) AS "Total nòmines", 
					 TO_CHAR(FLOAT8 (SUM(efemovnom.import_actual)), 'FM999999999.00') AS "Import total"					 				 
FROM eco_activitat_detall actdet
	JOIN eco_activitat act ON actdet.activitat_id = act.id
	JOIN eco_moviment mov ON act.moviment_id = mov.id
	JOIN eco_moviment_detall movdet ON mov.id = movdet.moviment_id,
	eco_efecte_moviment_nomina efemovnom
WHERE movdet.id = efemovnom.moviment_detall_id
  AND actdet.nomina_mensual_id = 40
  AND efemovnom.data_efecte_inici <= '2020-11-01 00:00:00'
  AND (efemovnom.data_efecte_fi IS NULL OR efemovnom.data_efecte_fi >= actdet.data_efecte)
  AND efemovnom.data_efecte_inici <= actdet.data_efecte
  AND efemovnom.tipus_id = 1;  
--
-- [04.09] IMPORTE TOTAL ORDINARIES BAIXES
--		 		
SELECT DISTINCT COUNT(actdet.nomina_id) AS "Total nòmines", 
					 TO_CHAR(FLOAT8 (SUM(efemovnom.import_anterior)), 'FM999999999.00') AS "Import total"	  
FROM eco_activitat_detall actdet
	JOIN eco_activitat act ON actdet.activitat_id = act.id
	JOIN eco_moviment mov ON act.moviment_id = mov.id
	JOIN eco_moviment_detall movdet ON mov.id = movdet.moviment_id,
	eco_efecte_moviment_nomina efemovnom
WHERE movdet.id = efemovnom.moviment_detall_id
  AND actdet.nomina_mensual_id = 40
  AND efemovnom.data_efecte_inici <= '2020-11-01 00:00:00'
  AND (efemovnom.data_efecte_fi IS NULL OR efemovnom.data_efecte_fi >= actdet.data_efecte)
  AND efemovnom.data_efecte_inici <= actdet.data_efecte
  AND efemovnom.tipus_id IN (3, 16);
--
-- [04.10] IMPORTE TOTAL ENDARRERIMENTS ALTES
--
SELECT DISTINCT COUNT(actdet.nomina_id) AS "Total nòmines", 
					 TO_CHAR(FLOAT8 (SUM(efemovnom.import_actual)), 'FM999999999.00') AS "Import total"
FROM eco_activitat_detall actdet
	JOIN eco_activitat act ON actdet.activitat_id = act.id
	JOIN eco_moviment mov ON act.moviment_id = mov.id
	JOIN eco_moviment_detall movdet ON mov.id = movdet.moviment_id,
	eco_efecte_moviment_nomina efemovnom
WHERE movdet.id = efemovnom.moviment_detall_id
  AND actdet.nomina_mensual_id = 40
  AND efemovnom.data_efecte_inici <= '2020-11-01 00:00:00'
  AND (efemovnom.data_efecte_fi IS NULL OR efemovnom.data_efecte_fi >= actdet.data_efecte)
  AND efemovnom.data_efecte_inici <= actdet.data_efecte
  AND efemovnom.tipus_id IN (1, 6)
  AND actdet.pagament_tipus_id = 2;
--
-- [04.11] IMPORTE TOTAL LIQUIDACIONS
--
SELECT DISTINCT COUNT(actdet.nomina_id) AS "Total nòmines", 
					 TO_CHAR(FLOAT8 (SUM(actdet.quantitat)), 'FM999999999.00') AS "Import total"
FROM eco_activitat_detall actdet
	JOIN eco_activitat act ON actdet.activitat_id = act.id
	JOIN eco_moviment mov ON act.moviment_id = mov.id
	JOIN eco_moviment_detall movdet ON mov.id = movdet.moviment_id,
	eco_efecte_moviment_nomina efemovnom
WHERE movdet.id = efemovnom.moviment_detall_id
  AND actdet.nomina_mensual_id = 40
  AND efemovnom.data_efecte_inici <= '2020-11-01 00:00:00'
  AND (efemovnom.data_efecte_fi IS NULL OR efemovnom.data_efecte_fi >= actdet.data_efecte)
  AND efemovnom.data_efecte_inici <= actdet.data_efecte
  AND act.liquidacio = true;
--
-- [04.12] IMPORTE TOTAL PAGAMENT EXTRAORDINARI
--
SELECT DISTINCT COUNT(actdet.nomina_id) AS "Total nòmines", 
					 TO_CHAR(FLOAT8 (SUM(actdet.quantitat)), 'FM999999999.00') AS "Import total"
FROM eco_activitat_detall actdet
	JOIN eco_activitat act ON actdet.activitat_id = act.id
	JOIN eco_moviment mov ON act.moviment_id = mov.id
	JOIN eco_moviment_detall movdet ON mov.id = movdet.moviment_id,
	eco_efecte_moviment_nomina efemovnom
WHERE movdet.id = efemovnom.moviment_detall_id
  AND actdet.nomina_mensual_id = 40
  AND efemovnom.data_efecte_inici <= '2020-11-01 00:00:00'
  AND (efemovnom.data_efecte_fi IS NULL OR efemovnom.data_efecte_fi >= actdet.data_efecte)
  AND efemovnom.data_efecte_inici <= actdet.data_efecte
  AND actdet.pagament_modalitat_id = 2;
---------------------------------------------------------------------------------------------------------------------
