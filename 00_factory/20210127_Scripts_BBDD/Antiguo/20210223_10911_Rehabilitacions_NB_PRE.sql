----------------------------------------------------------------------------------------------------------------- 
-- 
--  ESOCIAL-10911 - PRE - nòmina Desembre NB- Rehabilitacions
--
-- [23/02/2021]
-----------------------------------------------------------------------------------------------------------------
SET SCHEMA 'esocial';
--------------------------------------------------------------------------------------------
-- Desquadrament Imports Quadre per expedient 00006/2020/1033
--------------------------------------------------------------------------------------------
--
-- [01] Evitar solapament de les activitats existents:
--
SELECT * FROM eco_activitat WHERE dret_id = 308;
UPDATE eco_activitat SET data_efecte_inicial='2020-12-01 00:00:00.000' WHERE id = 636;
DELETE FROM eco_activitat WHERE id = 1210;
--
-- [02] Activar la nòmina:
--
SELECT * FROM eco_nomina WHERE id = 308;
UPDATE eco_nomina SET estat_id = 1 WHERE id = 308;
--
-- [ERROR] se produce un descuadre en el Quadre 05-2021 al establecer el alta expediente
--
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
---------------------------------------------------
-- Volvemos a ejecutar el Quadre de PNC 04-2021:
---------------------------------------------------
--------------- Nòmina 65 PNC
SELECT * FROM eco_nomina_mensual WHERE tipus_nomina_id = 13 ORDER BY data_nomina DESC;

SELECT * FROM eco_nomina_mensual_quantitat WHERE nomina_mensual_id = 65 ORDER BY id;
DELETE FROM eco_nomina_mensual_quantitat WHERE nomina_mensual_id = 65;

SELECT * FROM eco_nomina_mensual_procediment 
WHERE nomina_mensual_id = 65 ORDER BY data_inici_procediment;
DELETE FROM eco_nomina_mensual_procediment WHERE nomina_mensual_id = 65 AND id > 556;

SELECT * FROM eco_nomina_mensual WHERE id = 65;
UPDATE eco_nomina_mensual SET estat = 'ORDN', fase_id = 4 WHERE id = 65;

DELETE FROM eco_excel_quadre_nomina WHERE nomina_mensual_id = 65;
DELETE FROM eco_quadre_nomina_detall WHERE quadre_nomina_id IN (SELECT id FROM eco_quadre_nomina WHERE nomina_mensual_id = 65);
DELETE FROM eco_quadre_nomina WHERE nomina_mensual_id = 65;
--
--------------- Nòmina 63 CPNC
SELECT * FROM eco_nomina_mensual WHERE tipus_nomina_id = 12 ORDER BY data_nomina DESC;

SELECT * FROM eco_nomina_mensual_quantitat WHERE nomina_mensual_id = 63 ORDER BY id;
DELETE FROM eco_nomina_mensual_quantitat WHERE nomina_mensual_id = 63;

SELECT * FROM eco_nomina_mensual_procediment 
WHERE nomina_mensual_id = 63 ORDER BY data_inici_procediment;
DELETE FROM eco_nomina_mensual_procediment WHERE nomina_mensual_id = 63 AND id > 539;

SELECT * FROM eco_nomina_mensual WHERE id = 63;
UPDATE eco_nomina_mensual SET estat = 'ORDN', fase_id = 4 WHERE id = 63;

DELETE FROM eco_excel_quadre_nomina WHERE nomina_mensual_id = 63;
DELETE FROM eco_quadre_nomina_detall WHERE quadre_nomina_id IN (SELECT id FROM eco_quadre_nomina WHERE nomina_mensual_id = 63);
DELETE FROM eco_quadre_nomina WHERE nomina_mensual_id = 63;
---------------

--------------------------------------------------------------------------------------------
-- Persistencia dels càlculs del Quadre
--------------------------------------------------------------------------------------------
--
-- Actualmente los resultados del cálculo del Quadre se almacenan en:
--
SELECT * FROM eco_nomina_mensual_quantitat WHERE nomina_mensual_id = 65 ORDER BY id;
--
-- El campo "tipus_quantitat_nomina_id" nos indica a que concepto se refiere la "quantitat".
-- Podemos determinar el significado de estos campos mediante las siguiente SQLs:
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
-- Con todo, podemos mostrar "eco_nomina_mensual_quantitat" asociando una descripción a cada concepto:
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
-- CONCLUSIÓN: la tabla que almacene el detalle del Quadre de Nòmina tendrá que disponer 
--					de un campo "tipus_quantitat_nomina_id" que dispondrá de FK con la tabla
--					"llistat_valors.acronim".
--
--
-- Calculo el coste de la obtención de la información a almacenar en la tabla "eco_quadre_nomina":
--
-- Dispondré del Id de la Nòmina, el Id de la Activitat Detall y el Id de la Nòmina Mensual:
--
SELECT * FROM eco_nomina WHERE id = 308;
-- data_alta_nomina, tipus_nomina_id, data_primera_execucio, data_efecte_inici, estat_id, 
SELECT * FROM eco_activitat_detall WHERE nomina_mensual_id = 65 AND nomina_id = 308 ORDER BY data_efecte DESC;
-- id, activitat_id, quantitat, data_efecte, concept_id, pagament_tipus_id, pagament_modalitat_id
SELECT * FROM eco_dret WHERE nomina_id = 308;
-- id = 308
SELECT * FROM prestacio WHERE dret_id = 308;
-- id = 707, expedient_prestacio_id = 782
SELECT * FROM expedient_prestacio WHERE id = 782;
-- persona_id = 503296, numero_expedient
SELECT * FROM persona WHERE id = 503296;
-- nom, cognom1, cognom2, ambit_territorial_id
SELECT * FROM domicili WHERE persona_id = 503296 AND notificacio = TRUE;
-- adreca_id = 502477
SELECT * FROM adreca WHERE id = 502477;

----------------------------------------------------------------------------------------------------------------
-- 
-- CONSULTES QUADRE NOMINA.
-- 
----------------------------------------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------------------
-- [01] TOTS ELS REGISTRES GENERATS PEL QUADRE
--		  Llista de totes les imputacions realitzades pel Quadre de Nòmina.
--------------------------------------------------------------------------------------------
SELECT epr.numero_expedient AS "Expedient", 
		 qn.nomina_id AS "Nòmina", 
		 qnd.acronim AS "Acronim", 
		 (SELECT lvi.descripcio
		    FROM llistat_valors lv
			 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		 	 JOIN llistat_valors_agrupacions lva ON lv.llistat_valors_agrupacions_id = lva.id
		 	 JOIN llistat_valors_agrupacions_idioma lvai ON lva.id = lvai.llistat_valors_agrupacions_id
		  WHERE lv.acronim = qnd.acronim) AS "Descripció Acronim",
		 quantitat_imputada AS "Quantitat Imputada", 
		 quantitat_actual AS "Quantitat Actual", 
		 quantitat_anterior AS "Quantitat Anterior", 
		 liquidacio AS "Liquidació", 
		 activitat_detall_id AS "Activitat Detall"
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
 JOIN eco_dret dre ON qn.nomina_id = dre.nomina_id
 JOIN prestacio pre ON dre.id = pre.dret_id
 JOIN expedient_prestacio epr ON pre.expedient_prestacio_id = epr.id
WHERE qn.nomina_mensual_id = 66 
ORDER BY qnd.acronim, qn.nomina_id ASC;
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- [02] RESUM TOTAL BENEFICIARIS
--		  Resum amb els totals de tots els tipus de beneficiaris.
--------------------------------------------------------------------------------------------
SELECT betoAnt.quantitat AS "Beneficiaris ordinària anterior (BETO)",
		 beni.altes AS "Altes (BEAL)",
		 beni.baixes AS "Baixes (BEBA)",
		 beni.rehabilitacions AS "Rehabilitacions (BERE)",
		 beni.suspeses AS "Suspeses (BSUS)",
		 (betoAnt.quantitat + beni.altes - beni.baixes + beni.rehabilitacions - beni.suspeses) AS "Beneficiaris ordinària (BENO)",
		 beni.noOrdinaria AS "No ordinària (BENN)",
		 beni.noOrdinariaBaixa AS "No ordinària baixa (BENB)",
 		 (betoAct.quantitat - beni.baixes - beni.suspeses) AS "Total beneficiaris (BETO)"
FROM (SELECT quantitat
		FROM eco_nomina_mensual_quantitat 
		WHERE tipus_quantitat_nomina_id = 'BETO'
		  AND nomina_mensual_id = (SELECT id 
										   FROM eco_nomina_mensual 
										   WHERE tipus_nomina_mensual_id = 1
						 					  AND tipus_nomina_id = 13
		 	 								  AND id < 66
										   ORDER BY data_nomina DESC LIMIT 1)) AS betoAnt,
	  (SELECT SUM((CASE WHEN qnd.acronim = 'BEAL' THEN 1 ELSE 0 END)) AS altes,
				 SUM((CASE WHEN qnd.acronim = 'BEBA' THEN 1 ELSE 0 END)) AS baixes,
		 		 SUM((CASE WHEN qnd.acronim = 'BERE' THEN 1 ELSE 0 END)) AS rehabilitacions,
		 		 SUM((CASE WHEN qnd.acronim = 'BSUS' THEN 1 ELSE 0 END)) AS suspeses,
		 		 SUM((CASE WHEN qnd.acronim = 'BENN' THEN 1 ELSE 0 END)) AS noOrdinaria,
		 		 SUM((CASE WHEN qnd.acronim = 'BENB' THEN 1 ELSE 0 END)) AS noOrdinariaBaixa
		FROM eco_quadre_nomina qn
		 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
		WHERE qnd.acronim IN ('BEAL', 'BEBA', 'BERE', 'BSUS', 'BENN', 'BENB')
		  AND qn.nomina_mensual_id = 66) AS beni,		
	  (SELECT COUNT(qn.nomina_id) AS quantitat 
	   FROM eco_quadre_nomina qn
	   WHERE qn.nomina_mensual_id = 66) AS betoAct;
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- [03] RESUM IMPORTS TOTALS NOMINA ORDINARIA
--		  Resum amb tots els imports de nòmina ordinària.
--------------------------------------------------------------------------------------------
SELECT (SELECT quantitat 
		  FROM eco_nomina_mensual_quantitat 
		  WHERE tipus_quantitat_nomina_id = 'IMTO'
		    AND nomina_mensual_id = (SELECT id 
 										     FROM eco_nomina_mensual 
										     WHERE tipus_nomina_mensual_id = 1
						 					    AND tipus_nomina_id = 13
		 	 								    AND id < 65
										     ORDER BY data_nomina DESC LIMIT 1)
		 ) AS "Total nòmina ordinària mes anterior (IMTO)",
		 TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMAL' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Altes (IMAL)",
		 TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMBA' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Baixes (IMBA)",
		 TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMRE' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Rehabilitacions (IMRE)",		 
		 TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMMI' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Modificacions (IMMI)",
		 TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'ISUS' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Suspeses (ISUS)",
		 (SELECT TO_CHAR(FLOAT8 (SUM(qnd.quantitat_imputada)), 'FM999999990.00')
		  FROM eco_quadre_nomina qn
		  JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
		  WHERE qnd.acronim IN ('IMAL', 'IMBA', 'IMRE', 'IMMI', 'ISUS', 'IMTO'))  AS "Total nomina ordinària (IMTO)"
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 65 
  AND qnd.acronim IN ('IMAL', 'IMBA', 'IMRE', 'IMMI', 'ISUS');
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- [04] RESUM IMPORTS TOTALS ENDARRERIMENTS
--		  Resum amb tots els imports d'endarreriments.
--------------------------------------------------------------------------------------------
SELECT TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMEA' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Altes Ordinària (IMAL)",
		 TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMER' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Baixes Ordinària (IMBA)",
		 TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMEM' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Rehabilitacions Ordinària (IMRE)",		 
		 TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMAE' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Modificacions Ordinària (IMMI)",
		 TO_CHAR(FLOAT8 (SUM(qnd.quantitat_imputada)), 'FM999999990.00') AS "Total endarreriments (IMTE)"
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 65 
  AND qnd.acronim IN ('IMEA', 'IMER', 'IMEM', 'IMAE');
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- [05] RESUM IMPORTS TOTALS DEDUCCIONS
--		  Resum amb tots els imports de deduccions.
--------------------------------------------------------------------------------------------
SELECT TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMDA' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Deducccions altes (IMDA)",
		 TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMDR' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Deduccions rehabilitacions (IMDR)",
		 TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMDB' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Deduccions baixes (IMDB)",		 
		 TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMAD' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Altres deduccions (IMAD)",
		 TO_CHAR(FLOAT8 (SUM(qnd.quantitat_imputada)), 'FM999999990.00') AS "Total deduccions (IMTD)"
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 65 
  AND qnd.acronim IN ('IMDA', 'IMDR', 'IMDB', 'IMAD');  
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- [06] RESUM IMPORTS TOTALS EXTRAORDINARIA
--		  Resum amb tots els imports d'extraordinaria.
--------------------------------------------------------------------------------------------
SELECT TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMLE' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Pag. extraordinari altes (IMLE)",
		 TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMLR' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Pag. extraordinari rehabilitacions (IMLR)",
		 TO_CHAR(FLOAT8 (SUM(CASE WHEN qnd.acronim = 'IMLA' THEN qnd.quantitat_imputada ELSE 0 END)), 'FM999999990.00') AS "Imports Altres pagaments extraordinaris (IMLA)",
		 TO_CHAR(FLOAT8 (SUM(qnd.quantitat_imputada)), 'FM999999990.00') AS "Total pagament extraordinari (IMTL)"
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 65 
  AND qnd.acronim IN ('IMLE', 'IMLR', 'IMLA');
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- [07] TOTAL NÒMINA
--		  Import total de la nòmina mensual, "Total nòmina (IMTN)" 
--------------------------------------------------------------------------------------------
SELECT TO_CHAR(FLOAT8 (SUM(qnd.quantitat_imputada)), 'FM999999990.00') AS "Total nòmina (IMTN)"
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 65;
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- [08] DETALL BENEFICIARIS NÒMINA
--		  
--------------------------------------------------------------------------------------------
--
-- [08.01] Beneficiaris Nòmina Ordinària mes anterior (BETO).
--
SELECT quantitat AS "Beneficiaris nòmina ordinària mes anterior (BETO)"
FROM eco_nomina_mensual_quantitat 
WHERE tipus_quantitat_nomina_id = 'BETO'
  AND nomina_mensual_id = (SELECT id 
								   FROM eco_nomina_mensual 
								   WHERE tipus_nomina_mensual_id = 1
				 					  AND tipus_nomina_id = 13
 	 								  AND id < 66
								   ORDER BY data_nomina DESC LIMIT 1);
--
-- [08.02] Beneficiaris Nòmina Ordinària Altes (BEAL).
-- [08.03] Beneficiaris Nòmina Ordinària Baixes (BEBA).
-- [08.04] Beneficiaris Nòmina Ordinària Rehabilitacions (BERE).
-- [08.05] Beneficiaris Nòmina Ordinària Suspeses (BSUS).
--
SELECT qn.nomina_id, qnd.quantitat_imputada
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 67 
--AND qnd.acronim = 'BEAL'
AND qnd.acronim = 'BEBA'
--AND qnd.acronim = 'BERE'
--AND qnd.acronim = 'BSUS'
ORDER BY qn.nomina_id ASC;
--
-- [08.06] Beneficiaris Nòmina Ordinària (BENO).
--
SELECT DISTINCT qn.nomina_id
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 66 
  AND qnd.acronim IN ('BEAL', 'BERE', 'IMTO')
  AND qn.nomina_id NOT IN (SELECT qn.nomina_id
									FROM eco_quadre_nomina qn
									 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
									WHERE qn.nomina_mensual_id = 66 
									  AND qnd.acronim = 'BSUS')
ORDER BY qn.nomina_id ASC;
--
-- [08.07] Beneficiaris Nòmina No Ordinària (BENN).
-- [08.08] Beneficiaris Nòmina No Ordinària de baixa (BENB)
--
SELECT qn.nomina_id, qnd.quantitat_imputada
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 66 
  AND qnd.acronim = 'BENN'
--AND qnd.acronim = 'BENB'  
ORDER BY qn.nomina_id ASC;
--
-- [08.09] Total Beneficiaris (BETO)
--
SELECT DISTINCT qn.nomina_id
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 66 
  AND qnd.acronim IN ('BEAL', 'BERE', 'BENN', 'IMTO')
  AND qn.nomina_id NOT IN (SELECT qn.nomina_id
									FROM eco_quadre_nomina qn
									 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
									WHERE qn.nomina_mensual_id = 66 
									  AND qnd.acronim = 'BSUS')
ORDER BY qn.nomina_id ASC;
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- [09] DETALL IMPORTS NÒMINA
--		  
--------------------------------------------------------------------------------------------
--
-- [09.01] Total Nòmina Ordinària mes anterior (IMTO)
--
SELECT quantitat AS "Total nòmina ordinària mes anterior (IMTO)"
FROM eco_nomina_mensual_quantitat 
WHERE tipus_quantitat_nomina_id = 'IMTO'
  AND nomina_mensual_id = (SELECT id 
								   FROM eco_nomina_mensual 
								   WHERE tipus_nomina_mensual_id = 1
				 					  AND tipus_nomina_id = 13
 	 								  AND id < 65
								   ORDER BY data_nomina DESC LIMIT 1);
--
-- [09.01] Imports Altes Ordinària (IMAL)
-- [09.02] Imports Baixes Ordinària (IMBA)
-- [09.03 Imports Rehabilitacions Ordinària (IMRE)
-- [09.04] Imports Modificacions Ordinària (IMMI)
-- [09.05] Imports Suspeses Ordinària (ISUS)
-- 
SELECT qn.nomina_id, qnd.quantitat_imputada
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 65 
--AND qnd.acronim = 'IMAL'
--AND qnd.acronim = 'IMBA'
AND qnd.acronim = 'IMRE'
--AND qnd.acronim = 'IMMI'
--AND qnd.acronim = 'ISUS'
ORDER BY qn.nomina_id ASC;
--
-- [09.06] Total Nomina Ordinària (IMTO) 
--
SELECT TO_CHAR(FLOAT8 (SUM(qnd.quantitat_imputada)), 'FM999999990.00') AS "Total nomina ordinària (IMTO)"
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 65
  AND qnd.acronim IN ('IMAL', 'IMBA', 'IMRE', 'IMMI', 'ISUS', 'IMTO');
--
-- [09.07] Imports Endarreriments Altes (IMEA)
-- [09.08] Imports Endarreriments Rehabilitacions (IMER)
-- [09.09] Imports Endarreriments Modificacions (IMEM)
-- [09.10] Imports Altres Enderreriments (IMAE)
--
SELECT qn.nomina_id, qnd.quantitat_imputada
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 65 
--AND qnd.acronim = 'IMEA'
AND qnd.acronim = 'IMER'
--AND qnd.acronim = 'IMEM'
--AND qnd.acronim = 'IMAE'
ORDER BY qn.nomina_id ASC;
--
-- [09.11] Total Endarreriments (IMTE)
--
SELECT TO_CHAR(FLOAT8 (SUM(qnd.quantitat_imputada)), 'FM999999990.00') AS "Total endarreriments (IMTE)"
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 65
  AND qnd.acronim IN ('IMEA', 'IMER', 'IMEM', 'IMAE');
--
-- [09.12] Imports Deducccions altes (IMDA)
-- [09.13] Imports Deduccions rehabilitacions (IMDR)
-- [09.14] Imports Deduccions baixes (IMDB)
-- [09.15] Imports Altres deduccions (IMAD)
--
SELECT qn.nomina_id, qnd.quantitat_imputada
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 65 
AND qnd.acronim = 'IMDA'
--AND qnd.acronim = 'IMDR'
--AND qnd.acronim = 'IMDB'
--AND qnd.acronim = 'IMAD'
ORDER BY qn.nomina_id ASC;
--
-- [09.16] Total deduccions (IMTD)
--
SELECT TO_CHAR(FLOAT8 (SUM(qnd.quantitat_imputada)), 'FM999999990.00') AS "Total endarreriments (IMTE)"
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 65
  AND qnd.acronim IN ('IMDA', 'IMDR', 'IMDB', 'IMAD');
--
-- [09.17] Imports Pag. extraordinari altes (IMLE)
-- [09.18] Imports Pag. extraordinari rehabilitacions (IMLR)
-- [09.19] Imports Altres pagaments extraordinaris (IMLA)
--
SELECT qn.nomina_id, qnd.quantitat_imputada
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 65 
AND qnd.acronim = 'IMLE'
--AND qnd.acronim = 'IMLR'
--AND qnd.acronim = 'IMLA'
ORDER BY qn.nomina_id ASC;
--
-- [09.20] Total pagament extraordinari (IMTL)
--
SELECT TO_CHAR(FLOAT8 (SUM(qnd.quantitat_imputada)), 'FM999999990.00') AS "Total endarreriments (IMTE)"
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 65
  AND qnd.acronim IN ('IMLE', 'IMLR', 'IMLA');
--------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
-- 
-- [20210305] PRUEBAS
-- 
----------------------------------------------------------------------------------------------------------------
--
-- [02.03] ULTIMA NOMINA MENSUAL POR TIPOS
--
SELECT etep.id AS "T.Exp.Pres.",
		 etp.id AS "T.Prestació",
		 etn.id AS "T.Nòmina",
		 (SELECT id FROM eco_nomina_mensual nom
		  WHERE nom.tipus_nomina_id = etn.id AND nom.auditoria <> 'ECONOMICS'
		  ORDER BY data_nomina DESC LIMIT 1) AS "Últ.Nòm.Men.",
		 (SELECT TO_CHAR(data_nomina, 'DD-MM-YYYY') 
		  FROM eco_nomina_mensual nom
		  WHERE nom.tipus_nomina_id = etn.id AND nom.auditoria <> 'ECONOMICS'
		  ORDER BY data_nomina DESC LIMIT 1) AS "Data",
		 (SELECT estat FROM eco_nomina_mensual nom
		  WHERE nom.tipus_nomina_id = etn.id AND nom.auditoria <> 'ECONOMICS'
		  ORDER BY data_nomina DESC LIMIT 1) AS "Estat", 
		 (SELECT TO_CHAR(data_inici_generacio, 'DD-MM-YYYY HH24:MI:SS') 
		  FROM eco_nomina_mensual nom
		  WHERE nom.tipus_nomina_id = etn.id AND nom.auditoria <> 'ECONOMICS'
		  ORDER BY data_nomina DESC LIMIT 1) AS "Inici Generació",
	    (SELECT lvi.descripcio FROM llistat_valors lv 
		  JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		  WHERE etep.llistat_valors_id = lv.id) AS "Descripció"
FROM eco_tipus_expedient_prestacio etep
 LEFT JOIN eco_tipus_prestacio etp ON etep.id = etp.tipus_expedient_prestacio_id
 LEFT JOIN eco_tipus_prestacio_tipus_nomina tptn ON etp.id = tptn.tipus_prestacio_id
 LEFT JOIN eco_tipus_nomina etn ON tptn.tipus_nomina_id = etn.id
ORDER BY etep.id;

SELECT * FROM eco_nomina_mensual WHERE tipus_nomina_id = 2 AND tipus_nomina_mensual_id = 1 ORDER BY data_nomina DESC;
SELECT * FROM eco_nomina_mensual WHERE tipus_nomina_id = 11 AND tipus_nomina_mensual_id = 1 ORDER BY data_nomina DESC;
SELECT * FROM eco_nomina_mensual WHERE tipus_nomina_id = 12 AND tipus_nomina_mensual_id = 1 ORDER BY data_nomina DESC;
SELECT * FROM eco_nomina_mensual WHERE tipus_nomina_id = 13 AND tipus_nomina_mensual_id = 1 ORDER BY data_nomina DESC;
SELECT * FROM eco_nomina_mensual WHERE tipus_nomina_id = 14 AND tipus_nomina_mensual_id = 1 ORDER BY data_nomina DESC;

--------------------------------------------------------------------------------------------------------
-- [2021/03/08] Número de altas PNC nòmina mensual 66 incorrectas
--------------------------------------------------------------------------------------------------------
--
-- Quadre altas: 59 
-- Excel altas:  56
--		
--
-- [08.02] Beneficiaris Nòmina Ordinària Altes (BEAL).
--
SELECT qn.nomina_id, qnd.quantitat_imputada
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 66 
  AND qnd.acronim = 'BEAL'
ORDER BY qn.nomina_id;
--
-- Datos nòminas altas:
--
SELECT id, data_alta_nomina, data_primera_execucio, data_efecte_inici 
FROM eco_nomina
WHERE id IN (SELECT qn.nomina_id
 				 FROM eco_quadre_nomina qn
				 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id 
				 WHERE qn.nomina_mensual_id = 66
				   AND qnd.acronim = 'BEAL')
ORDER BY data_primera_execucio DESC, id;
--
-- Las nóminas 695, 732 y 750 disponen de data_primera_execucio = NULL
-- y no disponen de activitat detall, por lo que en ningún caso puede considerarse un alta!!!
SELECT * FROM eco_activitat_detall WHERE nomina_id IN (695, 732, 750) ORDER BY data_efecte DESC;
--
-- CONCLUSIÓN: es un error del Quadre!!! Corrijo "getNominesSuspesesSenseActDetNomMenAnterior()" donde
--				   se está imputando el alta.
--
-- Al volver a ejecutar ahora las altas coinciden con el Excel pero el número de Suspeses en éste es
--	16 y en el Quadre 13:
--
--
-- Si copiamos los números de expedientes del Excel:
--
SELECT epr.numero_expedient AS "Expedient", 
		 qn.nomina_id AS "Nòmina"
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
 JOIN eco_dret dre ON qn.nomina_id = dre.nomina_id
 JOIN prestacio pre ON dre.id = pre.dret_id
 JOIN expedient_prestacio epr ON pre.expedient_prestacio_id = epr.id
WHERE qn.nomina_mensual_id = 66 
  AND qnd.acronim = 'BSUS'
  AND epr.numero_expedient IN ('00006/2020/1099', '00006/2020/1166', '00006/2020/1305', '00006/2020/1001',
										 '00006/2020/1099', '00006/2020/1166', '00006/2020/1215', '00006/2020/1305',
										 '00006/2020/1001', '00006/2020/1761', '00006/2020/1695', '00006/2020/2164',
										 '00006/2020/1442', '00006/2020/2025', '00006/2020/1418', '00006/2020/1657',
										 '00006/2020/2856', '00006/2020/1391', '00006/2020/1052', '00006/2020/1783')
ORDER BY qn.nomina_id ASC;
--
-- Obtengo 13 nóminas suspendidas registradas en "eco_quadre_nomina_detall".
-- Si consulto el estado de estas nóminas:
--
SELECT * FROM eco_nomina 
WHERE id IN (224, 238, 245, 344, 393, 398, 462, 498, 537, 547, 562, 579, 587) ORDER BY id;
--
-- Las nóminas 224, 238, 344, 393 disponen de estat_id = 1 (Alta), el resto resto estat_id = 3 (Suspesa)
-- Los expedientes asociados a las 4 nóminas de alta son:
--
--			00006/2020/1099, 00006/2020/1166, 00006/2020/1001, 00006/2020/1305 
-- 
-- Se trata de los expedientes que no han pasado el control de errores, y por eso el Quadre los considera 
-- suspendidas, lo que es correcto:
--
SELECT * FROM eco_nomina_mensual_procediment 
WHERE nomina_mensual_id = 66 ORDER BY data_inici_procediment;
--
-- CONT - 565, ORDN - 566
SELECT * FROM eco_control_errors 
WHERE nomina_id IN (224, 238, 344, 393) AND nomina_mensual_historic_id IN (565, 566);
--
-- Existen 3 expedientes en el Excell que no están en el Quadre:
--
SELECT epr.numero_expedient
FROM expedient_prestacio epr 
WHERE epr.numero_expedient IN ('00006/2020/1099', '00006/2020/1166', '00006/2020/1305', '00006/2020/1001',
										 '00006/2020/1099', '00006/2020/1166', '00006/2020/1215', '00006/2020/1305',
										 '00006/2020/1001', '00006/2020/1761', '00006/2020/1695', '00006/2020/2164',
										 '00006/2020/1442', '00006/2020/2025', '00006/2020/1418', '00006/2020/1657',
										 '00006/2020/2856', '00006/2020/1391', '00006/2020/1052', '00006/2020/1783')
  AND epr.numero_expedient NOT IN (
			SELECT epr.numero_expedient AS "Expedient"
			FROM eco_quadre_nomina qn
			 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
			 JOIN eco_dret dre ON qn.nomina_id = dre.nomina_id
			 JOIN prestacio pre ON dre.id = pre.dret_id
			 JOIN expedient_prestacio epr ON pre.expedient_prestacio_id = epr.id
			WHERE qn.nomina_mensual_id = 66 
			  AND qnd.acronim = 'BSUS'
			  AND epr.numero_expedient IN ('00006/2020/1099', '00006/2020/1166', '00006/2020/1305', '00006/2020/1001',
													 '00006/2020/1099', '00006/2020/1166', '00006/2020/1215', '00006/2020/1305',
													 '00006/2020/1001', '00006/2020/1761', '00006/2020/1695', '00006/2020/2164',
													 '00006/2020/1442', '00006/2020/2025', '00006/2020/1418', '00006/2020/1657',
													 '00006/2020/2856', '00006/2020/1391', '00006/2020/1052', '00006/2020/1783')
);
-- Estos expedientes no los contempla el Quadre:
-- 
-- 00006/2020/1783
-- 00006/2020/1391
-- 00006/2020/1442
--
SELECT nom.*
FROM eco_nomina nom 
JOIN eco_dret dre ON nom.id = dre.nomina_id
JOIN prestacio pre ON dre.id = pre.dret_id
JOIN expedient_prestacio epr ON pre.expedient_prestacio_id = epr.id
WHERE epr.numero_expedient IN ('00006/2020/1783', '00006/2020/1391', '00006/2020/1442');
--
-- Las nóminas son 750, 695 y 732, y las tres disponen de estat_id = 3
--
-- CONCLUSIÓN: Quadre está mal!!! debe contabilizar estas suspensiones que ahora no cuenta
-- 			   por el cambio anterior.
--					Es decir, debería contabilizarlas como suspendidas pero no como altas, no se
--					en qué caso se deberían imputar como altas... 
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--
-- [2021/03/10] El listado Excel indica 313 beneficiarios pero el Quadre indica 310.
--------------------------------------------------------------------------------------------------------
--
-- Ordenació de Pagaments:
--
SELECT DISTINCT nomina_id FROM eco_ordenacio_pagament WHERE nomina_mensual_id = 66;
-- Aparecen 313 nóminas.
--
-- Activitat Detall 
-- 
SELECT DISTINCT nomina_id FROM eco_activitat_detall WHERE nomina_mensual_id = 66
-- Aparecen 313 nóminas.
--
-- CONCLUSIÓN: parece claro que son 313 beneficiarios; ¿qué está pasando en el Quadre?
--
-- Quadre Nomina
--
SELECT DISTINCT nomina_id FROM eco_quadre_nomina WHERE nomina_mensual_id = 66;
-- Aparecen 329 nóminas
--
SELECT DISTINCT qn.nomina_id
FROM eco_quadre_nomina qn
JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 66;
-- Aparecen 329 nóminas
--
SELECT DISTINCT nomina_id FROM eco_quadre_nomina 
WHERE nomina_mensual_id = 66
  AND nomina_id NOT IN (SELECT DISTINCT nomina_id FROM eco_activitat_detall WHERE nomina_mensual_id = 66);
-- Aparecen 16 nóminas; 329 - 313 = 16. Estas 16 nóminas se corresponden con las nóminas suspendidas.
--
--
-- [SUSPESES]:
--
SELECT qn.nomina_id
FROM eco_quadre_nomina qn
JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 66
  AND qnd.acronim = 'BSUS';
-- Aparecen 16 suspendidas:
-- 224, 238, 245, 393, 344, 462, 579, 562, 695, 498, 537, 547, 587, 750, 398, 732
--
SELECT * FROM eco_nomina 
WHERE id IN (224, 238, 245, 393, 344, 462, 579, 562, 695, 498, 537, 547, 587, 750, 398, 732)
 AND estat_id <> '3';
-- Todas las nóminas aparecen con "estat_id = 3", suspendidas, menos 224, 238, 344 y 393 que disponen de "estat_id = 1"
-- Compruebo si estas nóminas están suspendidas por el Control Errors:
SELECT DISTINCT(nomina_id) 
FROM eco_control_errors ce
JOIN eco_nomina_mensual_procediment nmp ON ce.nomina_mensual_historic_id = nmp.id
WHERE nmp.nomina_mensual_id = 66;
-- Nóminas: 224, 238, 344, 393, por lo que es correcto que se hayan suspendido las 16 nóminas.
--
-- De las nóminas suspendidas, han imputado importes en la nómina mensual:
--
SELECT DISTINCT (qn.nomina_id)
FROM eco_quadre_nomina qn
JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 66
  AND qnd.acronim NOT IN ('BSUS', 'BEAL', 'BERE')
  AND qnd.activitat_detall_id IS NULL;
-- Aparecen 13 nóminas, todas son 'ISUS', 'Imports Ordinària Suspeses'
-- 344, 562, 245, 224, 587, 537, 462, 579, 393, 238, 498, 547, 398
--
-- Estas 13 nóminas, suspendidas, han imputado importe en la nómina mensual, tres no!!!
-- 
SELECT * 
FROM eco_nomina nom
WHERE nom.id IN (224, 238, 245, 393, 344, 462, 579, 562, 695, 498, 537, 547, 587, 750, 398, 732)
  AND nom.id NOT IN (344, 562, 245, 224, 587, 537, 462, 579, 393, 238, 498, 547, 398);
--
-- Las nóminas suspendidas que NO han imputado importe en el Quadre son: 695, 732, 750 !!!!!!!!!!!!!!!!!!
--
SELECT * 
FROM eco_ordenacio_pagament 
WHERE nomina_mensual_id = 66
  AND nomina_id IN (224, 238, 245, 393, 344, 462, 579, 562, 695, 498, 537, 547, 587, 750, 398, 732);
--
-- NINGUNA DE LAS NÓMINAS SUSPESES HAN GENERADO ORDENACIÓ DE PAGAMENT, LO QUE ES CORRECTO.
--
SELECT * 
FROM eco_activitat_detall 
WHERE nomina_mensual_id = 66
  AND nomina_id IN (224, 238, 245, 393, 344, 462, 579, 562, 695, 498, 537, 547, 587, 750, 398, 732);
--
-- NINGUNA DE LAS NÓMINAS SUSPESES HAN GENERADO ACTIVITAT DETALL, LO QUE ES CORRECTO.
--
SELECT qn.nomina_id 
FROM eco_quadre_nomina qn 
WHERE nomina_mensual_id = 66
  AND nomina_id NOT IN (SELECT DISTINCT(nomina_id) FROM eco_activitat_detall WHERE nomina_mensual_id = 66)
ORDER BY nomina_id;
--
-- Se confirma que las nóminas de más en Quadre Nomina son exclusivamente las SUSPESES, lo que es correcto.
--
--
-- [ALTES]:
--
SELECT qn.nomina_id
FROM eco_quadre_nomina qn
JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 66
  AND qnd.acronim = 'BEAL';
-- Aparecen 56 altas
--
SELECT * FROM eco_nomina nom
WHERE nom.id IN (SELECT qn.nomina_id
					  FROM eco_quadre_nomina qn
					   JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
					  WHERE qn.nomina_mensual_id = 66
						 AND qnd.acronim = 'BEAL');
-- Todas las nóminas disponen de "data_primera_execucio = 2021-03-01 14:16:29"
-- TODAS LAS ALTAS DE NOMINA SON CORRECTAS!!!
--
--
-- [REHABILITACIONS]:
--
SELECT qn.nomina_id
FROM eco_quadre_nomina qn
JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 66
  AND qnd.acronim = 'BERE';
-- Aparece 1 rehabilitación: 308
--
-- Comprobamos si esta nómina se pagó en la nómina mensual anterior:
--
SELECT * FROM eco_activitat_detall WHERE nomina_mensual_id = 59 AND nomina_id = 308;
SELECT * FROM eco_ordenacio_pagament WHERE nomina_mensual_id = 59 AND nomina_id = 308;
--
-- LA NÓMINA REHABILITADA ES CORRECTA.
--


-- RECOPILEMOS:
--
--		1. En ACTIVITAT DETALL existen 313 nóminas.
--		2. En ORDENACIO PAGAMENT existen 313 nóminas.
--    3. En QUADRE NOMINA existen 329 nóminas:
--				Altas: 56
--				Rehabilitacions: 1
--				Suspeses: 16
--
SELECT qnd.*
FROM eco_quadre_nomina qn
JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 66
  AND qnd.activitat_detall_id IS NULL
  AND qnd.acronim <> 'ISUS';
-- Aparecen 73 nóminas: 16 + 56 + 1 = 73 - TODO CUADRA!!
-- Si es cierto que existían de la nómina anterior 269 beneficiarios:
--	
--			269 + 56 + 1 - 16 = 310 BENEFICIARIS!!!!
--
-- ¿Dónde están las tres nóminas que faltan? !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--
SELECT qnd.*
FROM eco_quadre_nomina qn
JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 66
  AND (qnd.activitat_detall_id IS NOT NULL
   OR qnd.acronim = 'ISUS');
-- Aparecen 648 registros, 648 + 73 = 721, que son exactamente todos los registros
-- presentes en "eco_quadre_nomina_detall" para la nómina mensual 66.
--
-- Las nóminas que han imputado importes positivos en el Quadre:
-- 
SELECT DISTINCT(qn.nomina_id)
FROM eco_quadre_nomina qn
JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 66
  AND qnd.activitat_detall_id IS NOT NULL
  AND qnd.acronim <> 'ISUS';
--
-- 313 NÓMINAS!!!!!!!!!!!!! ESTO NO TIENE SENTIDO!!!!!
-- 
SELECT DISTINCT nomina_id 
FROM eco_ordenacio_pagament 
WHERE nomina_mensual_id = 66
  AND nomina_id NOT IN (SELECT DISTINCT(qn.nomina_id)
								FROM eco_quadre_nomina qn
								JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
								WHERE qn.nomina_mensual_id = 66
								  AND qnd.activitat_detall_id IS NOT NULL
								  AND qnd.acronim <> 'ISUS');
--
-- Todas las nóminas en ORDENACIO PAGAMENT están QUADRE NOMINA.
-- 
SELECT DISTINCT nomina_id 
FROM eco_activitat_detall 
WHERE nomina_mensual_id = 66
  AND nomina_id NOT IN (SELECT DISTINCT(qn.nomina_id)
								FROM eco_quadre_nomina qn
								JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
								WHERE qn.nomina_mensual_id = 66
								  AND qnd.activitat_detall_id IS NOT NULL
								  AND qnd.acronim <> 'ISUS');
--
-- Todas las nóminas en ACTIVITAT DETALL están QUADRE NOMINA.
-- 
SELECT DISTINCT(qn.nomina_id)
FROM eco_quadre_nomina qn
JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
WHERE qn.nomina_mensual_id = 66
  AND qnd.activitat_detall_id IS NOT NULL
  AND qnd.acronim <> 'ISUS'
  AND qn.nomina_id NOT IN (SELECT DISTINCT(nomina_id) FROM eco_ordenacio_pagament WHERE nomina_mensual_id = 66)
  AND qn.nomina_id NOT IN (SELECT DISTINCT(nomina_id) FROM eco_activitat_detall WHERE nomina_mensual_id = 66);
--
-- CONCLUSIÓN: todas las nóminas pagadas estan en ACTIVITA DETALL, ORDENACIO PAGAMENT i QUADRE NOMINA.
--					La única explicación posible para el descuadre es que el número de beneficiarios de 
--				   la nómina mensual anterior sea incorrecto.
--
SELECT DISTINCT(nomina_id) FROM eco_ordenacio_pagament WHERE nomina_mensual_id = 59; -- 269
SELECT DISTINCT(nomina_id) FROM eco_activitat_detall WHERE nomina_mensual_id = 59; -- 269
--
-- PERO LOS BENEFICIARIOS DE LA NÓMINA MENSUAL ANTERIOR SON 269!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--
-- Nóminas en la nómina mensual ANTERIOR y no la ACTUAL:
--
SELECT DISTINCT actdet.nomina_id
FROM eco_activitat_detall actdet
WHERE actdet.nomina_mensual_id = 59
  AND actdet.nomina_id NOT IN (SELECT DISTINCT actdet.nomina_id
										 FROM eco_activitat_detall actdet
										 WHERE actdet.nomina_mensual_id = 66)
ORDER BY actdet.nomina_id;
-- Aparecen 13 nóminas presentes en la nómina mensual anterior y no la actual:
-- Nóminas: 224,238,245,344,393,398,462,498,537,547,562,579,587
--
--
-- Nóminas en la nómina mensual ACTUAL y no la ANTERIOR:
--
SELECT DISTINCT actdet.nomina_id
FROM eco_activitat_detall actdet
WHERE actdet.nomina_mensual_id = 66
  AND actdet.nomina_id NOT IN (SELECT DISTINCT actdet.nomina_id
										 FROM eco_activitat_detall actdet
										 WHERE actdet.nomina_mensual_id = 59)
ORDER BY actdet.nomina_id;
-- Aparecen 57 nóminas, lo que coincide con las altas de la nómina mensual de marzo (66): 
-- Altes + Rehabilitacions (56 + 1 = 57)
-- 
-- Sin embargo sólo existe 13 nóminas que estaban en la nómina mensual anterior y no la 
-- actual, lo que indica que 3 nóminas fueron introducidas posteriormente:
--
SELECT * 
FROM eco_nomina nom
WHERE nom.id IN (224, 238, 245, 393, 344, 462, 579, 562, 695, 498, 537, 547, 587, 750, 398, 732)
  AND nom.id NOT IN (224,238,245,344,393,398,462,498,537,547,562,579,587);
--
-- Las 3 nóminas son 695, 732, 750, que curiosamente coinciden con las nóminas suspendidas
-- que NO han imputado importe en el Quadre (ver SUSPESES).
-- 
-- CONCLUSIÓN FINAL:
--
--		- Existen 13 nóminas presentes en la nómina mensual anterior y no la actual:
-- 	  Nóminas: 224,238,245,344,393,398,462,498,537,547,562,579,587
--
--		- Existen 57 nóminas presentes en la nómina mensual actual y no la anterior.
--		  Ninguna nómina es: 695, 732, 750
--
--		- Existen 3 nóminas dadas de alta en febrero y suspendidas también en febrero:
--		  Nóminas son 695, 732, 750
--
-- El problema es que estas tres nóminas Suspendidas se están restando del total y de ahí el descuadre.

--------------------------------------------------------------------------------------------------------
--
-- [2021/03/11] Pruebas.
--
--------------------------------------------------------------------------------------------------------
-- Pago PNC 04-2021
SELECT * from eco_nomina WHERE id IN (202,203,753);
UPDATE eco_nomina SET estat_id = 3 WHERE id = 202;
UPDATE eco_nomina SET estat_id = 3 WHERE id = 203;
UPDATE eco_nomina SET estat_id = 3 WHERE id = 753;

-- Dades Bancaries Excel:
SELECT Substr(dadesbanca4_.iban, 5, 4) AS col_0_0_,
       Count(ordenaciop0_.quantitat)   AS col_1_0_,
       Sum(ordenaciop0_.quantitat)     AS col_2_0_
FROM   eco_ordenacio_pagament ordenaciop0_
       INNER JOIN eco_nomina_mensual nominamens1_
               ON ordenaciop0_.nomina_mensual_id = nominamens1_.id
       INNER JOIN eco_nomina nomina2_
               ON ordenaciop0_.nomina_id = nomina2_.id
       INNER JOIN eco_nomina_persona nominapers3_
               ON nomina2_.id = nominapers3_.nomina_id
       INNER JOIN dades_bancaries dadesbanca4_
               ON nominapers3_.dades_bancaries_id = dadesbanca4_.id
WHERE  ordenaciop0_.nomina_mensual_id = 67
       AND ( nomina2_.id NOT IN ( 753 ) )
GROUP  BY Substr(dadesbanca4_.iban, 5, 4) 

-- Pago PNC 05-2021
SELECT * from eco_nomina WHERE id IN (202,203,753);
UPDATE eco_nomina SET estat_id = 1 WHERE id = 202;
UPDATE eco_nomina SET estat_id = 1 WHERE id = 753;

-- Pago PNC 06-2021
SELECT * from eco_nomina WHERE id IN (202,203,753);
UPDATE eco_nomina SET estat_id = 1 WHERE id = 203;


--------------------------------------------------------------------------------------------------------
-- Volver a generar Quadre nòmina mensual PNC
SELECT * FROM eco_nomina_mensual WHERE tipus_nomina_id = 13 AND tipus_nomina_mensual_id = 1 ORDER BY data_nomina DESC;

SELECT * FROM eco_nomina_mensual_quantitat WHERE nomina_mensual_id = 70 ORDER BY id;
DELETE FROM eco_nomina_mensual_quantitat WHERE nomina_mensual_id = 70;

SELECT * FROM eco_nomina_mensual_procediment 
WHERE nomina_mensual_id = 70 ORDER BY data_inici_procediment;
DELETE FROM eco_nomina_mensual_procediment WHERE nomina_mensual_id = 70 AND id > 649;

SELECT * FROM eco_nomina_mensual WHERE id = 70;
UPDATE eco_nomina_mensual SET estat = 'ORDN', fase_id = 4 WHERE id = 70;

DELETE FROM eco_excel_quadre_nomina WHERE nomina_mensual_id = 70;
DELETE FROM eco_quadre_nomina_detall WHERE quadre_nomina_id IN (SELECT id FROM eco_quadre_nomina WHERE nomina_mensual_id = 70);
DELETE FROM eco_quadre_nomina WHERE nomina_mensual_id = 70;
--------------------------------------------------------------------------------------------------------
-- 00006/2020/1021
SELECT * FROM eco_nomina WHERE id = 754;
UPDATE eco_nomina SET estat_id = 1 WHERE id = 754;
-- 00006/2020/1101
SELECT * FROM eco_nomina WHERE id = 382;
UPDATE eco_nomina SET estat_id = 3 WHERE id = 382;

SELECT epr.numero_expedient AS "Expedient", 
		 qn.nomina_id AS "Nòmina", 
		 qnd.acronim AS "Acronim", 
		 (SELECT lvi.descripcio
		    FROM llistat_valors lv
			 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		 	 JOIN llistat_valors_agrupacions lva ON lv.llistat_valors_agrupacions_id = lva.id
		 	 JOIN llistat_valors_agrupacions_idioma lvai ON lva.id = lvai.llistat_valors_agrupacions_id
		  WHERE lv.acronim = qnd.acronim) AS "Descripció Acronim",
		 quantitat_imputada AS "Quantitat Imputada", 
		 quantitat_actual AS "Quantitat Actual", 
		 quantitat_anterior AS "Quantitat Anterior", 
		 liquidacio AS "Liquidació", 
		 activitat_detall_id AS "Activitat Detall"
FROM eco_quadre_nomina qn
 JOIN eco_quadre_nomina_detall qnd ON qn.id = qnd.quadre_nomina_id
 JOIN eco_dret dre ON qn.nomina_id = dre.nomina_id
 JOIN prestacio pre ON dre.id = pre.dret_id
 JOIN expedient_prestacio epr ON pre.expedient_prestacio_id = epr.id
WHERE qn.nomina_mensual_id = 69 
  AND qnd.acronim = 'IMMI'
ORDER BY qnd.acronim, qn.nomina_id ASC;

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