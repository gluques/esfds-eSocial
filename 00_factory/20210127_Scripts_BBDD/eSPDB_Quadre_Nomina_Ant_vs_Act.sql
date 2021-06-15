---------------------------------------------------------------------------------------------------------------------
--  eSPDB_Quadre_Nomina_Ant_vs_Act.sql
--	Recopilación de sentencias SQL asociadas al Quadre de Nòmina Anterior Vs. Actual.
-- 
--  Created by gluques. 
--  Barcelona, April 16, 2021. 
--  						  																					   								    
--  Last update: 04/05/2021
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
-- QUADRE NÒMINA ANTERIOR VS. ACTUAL
--
--  [01] 
--  [02] 
--  [03] 
--
---------------------------------------------------------------------------------------------------------------------
SET SCHEMA 'esocial';
-----------------------------------------------------------------------
-- [01] Taules implicades i consultes bàsiques
-----------------------------------------------------------------------
--
-- [01.01] Darrera nòmina mensual d'un tipus nòmina determinat.
--
SELECT * FROM eco_nomina_mensual 
WHERE tipus_nomina_id = 13 AND tipus_nomina_mensual_id = 1 
ORDER BY data_nomina DESC;
--
-- [01.02] Estat procediments nòmina mensual.
--
SELECT * FROM eco_nomina_mensual_procediment 
WHERE nomina_mensual_id = 80 
ORDER BY data_inici_procediment;
--
-- [01.03] Control d'errors.
--
SELECT * FROM eco_control_errors	
WHERE nomina_mensual_historic_id IN (SELECT id 
                                     FROM eco_nomina_mensual_procediment 
                                     WHERE nomina_mensual_id = 80)
ORDER BY nomina_mensual_historic_id;
--
-- [01.04] Ordenació de pagament.
--
SELECT * FROM eco_ordenacio_pagament 
WHERE nomina_mensual_id = 71 
ORDER BY nomina_id, id;
--
-- [01.05] Ordenació de pagament detall.
--
SELECT * FROM eco_ordenacio_pagament_detall 
WHERE nomina_mensual_id = 71 
ORDER BY nomina_id, id;


--
-- [01.03] Totals per fase.
--
--         En aquesta taula s'emmagatzemen els resultats totals per fases de nòmina mensual. 
--         S'empren diferents conceptes, alguns presents en BBDD (llistat_valors):
--
--              BETO - Total beneficiaris
--              IMTN - Total nòmina
--
--         I altres declarats com a constants a "EconomicsConstants.java":
--
--              IORD - Import Ordinàries
--              NORD - Número Beneficiaris Ordinàries
--              IOAL - Import Ordinàries Altes
--              NOAL - Número Beneficiaris Ordinàries Altes
--              IEND - Import Enderrariments
--              IEAL - Import Enderrariments Altes
--              NNOR - Número Beneficiaris NO ordinàries
--              INOM - Total import procés de nòmines
--              NBNF - Número total de beneficiaris
--              NNOK - Número total OK a últim procés executat
--              NNKO - Número total KO a últim procés executat
--              INOK - Total import nòmines OK a últim procés executat
--
SELECT enmp.estat, enmpq.* 
FROM eco_nomina_mensual_procediment_quantitat enmpq
 JOIN eco_nomina_mensual_procediment enmp ON enmpq.nomina_mensual_procediment_id = enmp.id
WHERE enmp.nomina_mensual_id = 80
ORDER BY enmpq.id;
--
-- [01.05] Quantitats imputades.
--
SELECT * FROM eco_nomina_mensual_quantitat 
WHERE nomina_mensual_id = 80 
ORDER BY id;
--
-- [01.06] Quadre i nòmines processades.
--
SELECT * FROM eco_quadre_nomina 
WHERE nomina_mensual_id = 80
ORDER BY id;
--
-- [01.07] Quadre i imputacions per nòmina.
--
SELECT eqnd.* 
FROM eco_quadre_nomina_detall eqnd
 JOIN eco_quadre_nomina eqn ON eqnd.quadre_nomina_id = eqn.id
WHERE eqn.nomina_mensual_id = 80
ORDER BY eqnd.id;
--
-- [01.08] Fitxer Excel.
--
SELECT * FROM eco_excel_quadre_nomina WHERE nomina_mensual_id = 80;
-----------------------------------------------------------------------
-- [00] Fases nòmina mensual.
-----------------------------------------------------------------------
SELECT enmf.id, enmf.codi, enmf.nom_curt, lvi.descripcio
FROM eco_nomina_mensual_fase enmf
 JOIN llistat_valors lv ON enmf.llistat_valors_id = lv.id
 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY enmf.id;
-----------------------------------------------------------------------
-- [00] Descripció conceptes quadre.
-----------------------------------------------------------------------
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
-----------------------------------------------------------------------
-- [00] Detall conceptes i quantitats imputades.
-----------------------------------------------------------------------
SELECT enmq.id, lvai.descripcio, lvi.descripcio, 
		 enmq.tipus_quantitat_nomina_id, enmq.quantitat
FROM eco_nomina_mensual_quantitat enmq
 JOIN llistat_valors lv ON enmq.tipus_quantitat_nomina_id = lv.acronim
 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
 JOIN llistat_valors_agrupacions lva ON lv.llistat_valors_agrupacions_id = lva.id
 JOIN llistat_valors_agrupacions_idioma lvai ON lva.id = lvai.llistat_valors_agrupacions_id
WHERE enmq.nomina_mensual_id = 80
ORDER BY lva.acronim DESC, lv.acronim;

-----------------------------------------------------------------------
-- [00] Tipus incidencia
-----------------------------------------------------------------------
SELECT eti.id, eti.codi, lv.acronim, lvi.descripcio
FROM eco_tipus_incidencia eti
 JOIN llistat_valors lv ON eti.llistat_valors_id = lv.id
 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY eti.id;
-----------------------------------------------------------------------
-- [00] Motiu incidencia
-----------------------------------------------------------------------
SELECT emi.id, emi.codi, lv.acronim, lvi.descripcio
FROM eco_motiu_incidencia emi
 JOIN llistat_valors lv ON emi.llistat_valors_id = lv.id
 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY emi.id;
-----------------------------------------------------------------------
-- [00] Detall incidencies pagament
-----------------------------------------------------------------------
SELECT eip.id, eip.opt_lck_ctl, eip.rcd_crt_nm, eip.ordenacio_pagament_id,
	   eip.data_incidencia, eip.tipus_incidencia_id,
	   (SELECT lvi.descripcio FROM llistat_valors lv
 	    JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		WHERE lv.id = eti.llistat_valors_id) AS "Descripció",
	   eip.motiu_id,
	   (SELECT lvi.descripcio FROM llistat_valors lv
 	    JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
	    WHERE lv.id = emi.llistat_valors_id) AS "Descripció"
FROM eco_incidencies_pagament eip
 JOIN eco_tipus_incidencia eti ON eip.tipus_incidencia_id = eti.id
 JOIN eco_motiu_incidencia emi ON eip.motiu_id = emi.id 
WHERE eip.ordenacio_pagament_id IN (SELECT id FROM eco_ordenacio_pagament 
									WHERE nomina_mensual_id = 71);
-----------------------------------------------------------------------
-- [00] TORNAR A GENERAR EL QUADRE
-----------------------------------------------------------------------
--
-- eco_excel_quadre_nomina:
--
SELECT * FROM eco_excel_quadre_nomina WHERE nomina_mensual_id = 67;
DELETE FROM eco_excel_quadre_nomina WHERE nomina_mensual_id = 67;
--
-- eco_quadre_nomina_detall:
--
SELECT * FROM eco_quadre_nomina_detall eqnd 
WHERE eqnd.quadre_nomina_id IN (SELECT eqn.id FROM eco_quadre_nomina eqn 
							    WHERE eqn.nomina_mensual_id = 67);                              
DELETE FROM eco_quadre_nomina_detall eqnd 
WHERE eqnd.quadre_nomina_id IN (SELECT id FROM eco_quadre_nomina eqn 
							    WHERE eqn.nomina_mensual_id = 67);
--
-- eco_quadre_nomina:            
--
SELECT * FROM eco_quadre_nomina eqn WHERE eqn.nomina_mensual_id = 67;                    
DELETE FROM eco_quadre_nomina eqn WHERE eqn.nomina_mensual_id = 67;
--
-- eco_nomina_mensual_quantitat:
--
SELECT * FROM eco_nomina_mensual_quantitat enmq WHERE enmq.nomina_mensual_id = 67;
DELETE FROM eco_nomina_mensual_quantitat enmq WHERE enmq.nomina_mensual_id =67;
--
-- eco_nomina_mensual_procediment:
--
SELECT * FROM eco_nomina_mensual_procediment enmp 
WHERE enmp.nomina_mensual_id = 67 ORDER BY enmp.id;
DELETE FROM eco_nomina_mensual_procediment enmp 
WHERE enmp.nomina_mensual_id = 67 AND id > 584;
--
-- eco_nomina_mensual:
--
SELECT * FROM eco_nomina_mensual enm WHERE enm.id = 67;
UPDATE eco_nomina_mensual SET estat = 'ORDN' WHERE id = 67;
-----------------------------------------------------------------------
-- [00] Llista Activitat Detall processada pel Quadre
--      ActivitatDetallRepository.getActivitatsDetallAnbEfectes()
-----------------------------------------------------------------------
SELECT DISTINCT actdet.nomina_id AS "Id Nòmina",
		        actdet.id AS "Id Act.Detall",
		        actdet.data_efecte AS "Data Efecte",
		        actdet.quantitat AS "Quantitat",
		        actdet.pagament_tipus_id AS "T.Pagament",
		        efemovnom.id AS "Id Efecte",
		        efemovnom.tipus_id AS "Id T.Efecte",
		        efemovnom.import_actual AS "Imp.Actual",
		        efemovnom.import_anterior AS "Imp.Anterior",
		        efemovnom.diferencial AS "Diferencial",
		        efemovnom.data_efecte_inici AS "D.Efecte Inici",
		        act.tipus_incidencia_id AS "T.Incidencia",
		        actdet.pagament_modalitat_id AS "Id Modalitat"
FROM eco_activitat_detall actdet
 JOIN eco_activitat act ON actdet.activitat_id = act.id
 JOIN eco_moviment mov ON act.moviment_id = mov.id
 JOIN eco_moviment_detall movdet ON mov.id = movdet.moviment_id,
 eco_efecte_moviment_nomina efemovnom
WHERE movdet.id = efemovnom.moviment_detall_id
  AND actdet.nomina_mensual_id = 67
  AND efemovnom.data_efecte_inici <= '2021-04-01 00:00:00'
  AND (efemovnom.data_efecte_fi IS NULL OR efemovnom.data_efecte_fi >= actdet.data_efecte)
  AND efemovnom.data_efecte_inici <= actdet.data_efecte
ORDER BY actdet.nomina_id, actdet.data_efecte;


-----------------------------------------------------------------------
-- [00] Taules Quadre Nòmina.
-----------------------------------------------------------------------
--
-- [00.00] Nòmines processades.
--
SELECT DISTINCT nomina_id 
FROM eco_quadre_nomina 
WHERE nomina_mensual_id = 80
ORDER BY nomina_id;
--
-- [00.00] Detall imputacions per nòmina.
--
SELECT eqnd.id AS "Id", 
	   eqn.nomina_id AS "Nòmina",
 	   lvai.descripcio AS "Tipus",
	   eqnd.acronim AS "Concepte", 
	   lvi.descripcio AS "Descripció",
	   eqnd.quantitat_imputada AS "Quantitat Imputada", 
	   eqnd.quantitat_actual AS "Quantitat Actual", 
	   eqnd.quantitat_anterior AS "Quantitat Anterior",
	   eqnd.activitat_detall_id AS "Activitat Detall" 
FROM eco_quadre_nomina_detall eqnd
 JOIN eco_quadre_nomina eqn ON eqnd.quadre_nomina_id = eqn.id
 JOIN llistat_valors lv ON eqnd.acronim = lv.acronim
 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
 JOIN llistat_valors_agrupacions lva ON lv.llistat_valors_agrupacions_id = lva.id
 JOIN llistat_valors_agrupacions_idioma lvai ON lva.id = lvai.llistat_valors_agrupacions_id
WHERE eqn.nomina_mensual_id = 77
ORDER BY eqnd.acronim;
--
-- [00.00] Tipus de conceptes amb imputacions.
--
SELECT DISTINCT eqnd.acronim
FROM eco_quadre_nomina_detall eqnd
 JOIN eco_quadre_nomina eqn ON eqnd.quadre_nomina_id = eqn.id
 JOIN llistat_valors lv ON eqnd.acronim = lv.acronim
 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
 JOIN llistat_valors_agrupacions lva ON lv.llistat_valors_agrupacions_id = lva.id
 JOIN llistat_valors_agrupacions_idioma lvai ON lva.id = lvai.llistat_valors_agrupacions_id
WHERE eqn.nomina_mensual_id = 76
  AND lvai.descripcio <> 'Nombre Beneficiaris'
ORDER BY eqnd.acronim;


-----------------------------------------------------------------------
-- [00.00] Ordenació de Pagaments
-----------------------------------------------------------------------
--
-- [00.00] Ordenacions de pagament.
--
SELECT * FROM eco_ordenacio_pagament 
WHERE nomina_mensual_id = 76 
ORDER BY nomina_id, id;
--
-- [00.00] Nòmines amb pagaments.
--
SELECT DISTINCT nomina_id 
FROM eco_ordenacio_pagament 
WHERE nomina_mensual_id = 76 
ORDER BY nomina_id;
--
-- [00.00] Total pagaments.
--
SELECT SUM(quantitat) 
FROM eco_ordenacio_pagament 
WHERE nomina_mensual_id = 76;
--
-- [00.00] Nòmines amb imports diferents a Quadre Nòmina Detall.
--
SELECT ordpag.nomina_id AS "Nòmina", 
       TO_CHAR(FLOAT8(ordpag.quantitat), 'FM999999999.00') AS "Quantitat Ord.Pag.",
       TO_CHAR(FLOAT8(quadre.quantitat), 'FM999999999.00') AS "Quantitat Quadre"
FROM (SELECT eop.nomina_id, eop.quantitat 
      FROM eco_ordenacio_pagament eop
      WHERE eop.nomina_mensual_id = 78
      ORDER BY eop.nomina_id) ordpag,
     (SELECT eqn.nomina_id, SUM(eqnd.quantitat_imputada) AS "quantitat"
      FROM eco_quadre_nomina_detall eqnd
      JOIN eco_quadre_nomina eqn ON eqnd.quadre_nomina_id = eqn.id
      WHERE eqn.nomina_mensual_id = 78
        AND eqnd.acronim IN ('IMAL','IMRE','IMMI','IMTO','IMEA','IMER','IMEM','IMAE','IMLE','IMLR','IMLA')
      GROUP BY eqn.nomina_id                                            
      ORDER BY nomina_id) AS quadre                                     
WHERE ordpag.nomina_id = quadre.nomina_id                               
  AND ordpag.quantitat <> quadre.quantitat;





--
-- [05/05/2021] Dejo aquí esta SQL por si hiciera falta, pero creo que tengo ya otras similares:
--
SELECT (CASE WHEN eqnd.acronim = 'IMTO' THEN TO_CHAR(FLOAT8(SUM(eqnd.quantitat_imputada)), 'FM999999999.00')  END) AS "Total nomina ordinària (IMTO)",
		 (CASE WHEN eqnd.acronim = 'IMLA' THEN TO_CHAR(FLOAT8(SUM(eqnd.quantitat_imputada)), 'FM999999999.00')  END) AS "Altres pagaments extraordinaris (IMLA)",
		 (CASE WHEN eqnd.acronim = 'IMEM' THEN TO_CHAR(FLOAT8(SUM(eqnd.quantitat_imputada)), 'FM999999999.00')  END) AS "Endarreriments modificacions (IMEM)",
		 (CASE WHEN eqnd.acronim = 'IMBA' THEN TO_CHAR(FLOAT8(SUM(eqnd.quantitat_imputada)), 'FM999999999.00')  END) AS "Baixes (IMBA)"		 
FROM eco_quadre_nomina_detall eqnd
 JOIN eco_quadre_nomina eqn ON eqnd.quadre_nomina_id = eqn.id
 JOIN llistat_valors lv ON eqnd.acronim = lv.acronim
 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
 JOIN llistat_valors_agrupacions lva ON lv.llistat_valors_agrupacions_id = lva.id
 JOIN llistat_valors_agrupacions_idioma lvai ON lva.id = lvai.llistat_valors_agrupacions_id
WHERE eqn.nomina_mensual_id = 76
  AND lvai.descripcio <> 'Nombre Beneficiaris'
GROUP BY eqnd.acronim;