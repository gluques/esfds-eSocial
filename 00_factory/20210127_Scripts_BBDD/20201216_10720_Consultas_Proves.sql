----------------------------------------------------------------------------------------------------------------- 
--  ESOCIAL-10720 - Procès increment anual prestacions
--
-- [01/12/2020] - Consultes Proves
-----------------------------------------------------------------------------------------------------------------
SET SCHEMA 'esocial';
----------------------------------------------------------------------
-- Consultes prèvies a l'inici dels processos
----------------------------------------------------------------------
--
-- Últimes nòmines mensuals per tipus.
--
--  ATENCIÓ: s'espera que l'última nòmina mensual de tots els tipus 
--           de prestacions sigui 12-12-2020
--
SELECT etep.id AS "T.Exp.Pres.",
		 etp.id AS "T.Prestació",
		 etn.id AS "T.Nòmina",
		 (SELECT id FROM eco_nomina_mensual
		  WHERE tipus_nomina_id = etn.id
		  ORDER BY data_nomina DESC LIMIT 1) AS "Últ.Nòm.Men.",
		 (SELECT TO_CHAR(data_nomina, 'DD-MM-YYYY') FROM eco_nomina_mensual
		  WHERE tipus_nomina_id = etn.id
		  ORDER BY data_nomina DESC LIMIT 1) AS "Data",
		 (SELECT estat FROM eco_nomina_mensual
		  WHERE tipus_nomina_id = etn.id
		  ORDER BY data_nomina DESC LIMIT 1) AS "Estat", 
		 (SELECT TO_CHAR(data_inici_generacio, 'DD-MM-YYYY HH24:MI:SS') FROM eco_nomina_mensual
		  WHERE tipus_nomina_id = etn.id
		  ORDER BY data_nomina DESC LIMIT 1) AS "Inici Generació",
	    (SELECT lvi.descripcio FROM llistat_valors lv 
		  JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		  WHERE etep.llistat_valors_id = lv.id) AS "Descripció"
FROM eco_tipus_expedient_prestacio etep
 LEFT JOIN eco_tipus_prestacio etp ON etep.id = etp.tipus_expedient_prestacio_id
 LEFT JOIN eco_tipus_prestacio_tipus_nomina tptn ON etp.id = tptn.tipus_prestacio_id
 LEFT JOIN eco_tipus_nomina etn ON tptn.tipus_nomina_id = etn.id
ORDER BY etep.id;
--
-- Estat reserves disponibles para un exercici en particular.
--
--  ATENCIÓ: S'espera disposar d'alguna reserva de l'any 2021 per a algun 
--           tipus de prestació.
--
SELECT tep.id AS "T.Expedient",		 
		 etp.id AS "T.Prestació",
		 res.id AS "Reserva",
		 res.import_reservat AS "R.Imp.Reservat",
		 res.import_restant AS "R.Imp.Restant",
		 par.id AS "Partida",
		 par.import_reservat AS "P.Imp.Reservat",
		 par.import_restant AS "P.Imp.Restant",
		 bos.id AS "Bossa",
		 bos.import_reservat AS "B.Imp.Reservat",
		 bos.import_restant AS "B.Imp.Restant",		 
		 con.id AS "Convocatoria" 
FROM eco_tipus_expedient_prestacio tep
 JOIN eco_tipus_prestacio etp ON tep.id = etp.tipus_expedient_prestacio_id
 JOIN eco_convocatoria con ON tep.id = con.tipus_expedient_id
 JOIN eco_bossa_pressupostaria bos ON con.id = bos.convocatoria_id
 JOIN eco_partida_pressupostaria par ON bos.id = par.bossa_pressupostaria_id
 JOIN eco_reserva res ON par.id = res.partida_pressupostaria_id
WHERE con.data_termini_inici = '2021-01-01 00:00'
  AND bos.import_restant > 0
  AND par.import_restant > 0
  AND par.actuacio_gestio_id = 1
  AND res.import_restant > 0
ORDER BY etp.id;
----------------------------------------------------------------------
-- Pressupostos i reserves per taules
----------------------------------------------------------------------
--
-- Convocatorias 2021:
--
SELECT * FROM eco_convocatoria 
WHERE data_pagament_inici = '2021-01-01 00:00:00.000'
ORDER BY tipus_expedient_id;
--
-- Partides 2021:
--
SELECT * FROM eco_partida_pressupostaria 
WHERE exercici = '2021'
ORDER BY exercici DESC, ordre_consum, id;
--
-- Bosses 2021:
--
SELECT * FROM eco_bossa_pressupostaria 
WHERE exercici = '2021'
ORDER BY exercici DESC, convocatoria_id, id;
--
-- Reserves 2021:
--
SELECT res.* 
FROM eco_reserva res 
 JOIN eco_partida_pressupostaria par ON res.partida_pressupostaria_id = par.id
WHERE par.exercici = '2021'
ORDER BY res.data_creacio DESC, res.partida_pressupostaria_id, id;
--
-- Prestacións Reserves 2021:
--
SELECT epr.*
FROM eco_prestacio_reserva epr
 JOIN eco_reserva res ON epr.reserva_id = res.id
 JOIN eco_partida_pressupostaria par ON res.partida_pressupostaria_id = par.id
WHERE par.exercici = '2021'
ORDER BY epr.reserva_id, epr.prestacio_id;
--
-- Prestacións Reserves per un Servei Reserva en particular (no té en compte les reserves de extra!!):
--
SELECT epr.*
FROM eco_prestacio_reserva epr
 JOIN eco_servei_reserva_prestacio srp ON epr.id = srp.prestacio_reserva_id
 JOIN eco_servei_reserva_tipus_expedient srte ON srp.servei_reserva_tipus_expedient_id = srte.id
 JOIN eco_servei_reserva esr ON srte.servei_reserva_id = esr.id
WHERE esr.id = 1
  AND (esr.data_inici_proces IS NULL OR epr.rcd_crt_ts >= esr.data_inici_proces)
  AND (esr.data_fi_proces IS NULL OR epr.rcd_crt_ts <= esr.data_fi_proces)
ORDER BY srp.id;
--
-- Reserves Prestacions 2021:
--
SELECT edr.*
FROM eco_dret_reserva edr
 JOIN eco_reserva res ON edr.reserva_id = res.id
 JOIN eco_partida_pressupostaria par ON res.partida_pressupostaria_id = par.id
WHERE par.exercici = '2021'
ORDER BY edr.reserva_id, edr.dret_id;
--
-- Reserves Prestacions per un Servei Reserva en particular (no té en compte les reserves de extra!!):
--
SELECT edr.*
FROM eco_dret_reserva edr
 JOIN eco_servei_reserva_prestacio srp ON edr.id = srp.dret_reserva_id
 JOIN eco_servei_reserva_tipus_expedient srte ON srp.servei_reserva_tipus_expedient_id = srte.id
 JOIN eco_servei_reserva esr ON srte.servei_reserva_id = esr.id
WHERE esr.id = 1
  AND (esr.data_inici_proces IS NULL OR edr.rcd_crt_ts >= esr.data_inici_proces OR esr.tipus_servei_reserva_id = 2)
  AND (esr.data_fi_proces IS NULL OR edr.rcd_crt_ts <= esr.data_fi_proces OR esr.tipus_servei_reserva_id = 2)
ORDER BY srp.id;
----------------------------------------------------------------------
-- Servei Reserva
----------------------------------------------------------------------
-- 
-- Tipus Serveis Reserves:
--
SELECT * FROM eco_tipus_servei_reserva ORDER BY id;
SELECT *
FROM  eco_tipus_servei_reserva te	
	JOIN llistat_valors lv ON te.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id	
ORDER BY te.id;
--
-- Serveis Reserves 2021:
--
SELECT * FROM eco_servei_reserva 
WHERE exercici = 2021 ORDER BY id;
--
-- Serveis Reserves Tipus Expedients 2021:
--
SELECT srte.*
FROM eco_servei_reserva_tipus_expedient srte
 JOIN eco_servei_reserva sr ON srte.servei_reserva_id = sr.id
WHERE sr.exercici = 2021
ORDER BY servei_reserva_id DESC, tipus_expedient_prestacio_id;
--
-- Serveis Reserves Prestacions 2021:
--
SELECT srp.*
FROM eco_servei_reserva_prestacio srp
 JOIN eco_servei_reserva_tipus_expedient srte ON srp.servei_reserva_tipus_expedient_id = srte.id
 JOIN eco_servei_reserva sr ON srte.servei_reserva_id = sr.id
WHERE sr.exercici = 2021
ORDER BY servei_reserva_tipus_expedient_id DESC, prestacio_id;
--
-- Serveis Reserves Prestacions per un Servei Reserva en particular:
--
SELECT srp.*
FROM eco_servei_reserva_prestacio srp
 JOIN eco_servei_reserva_tipus_expedient srte ON srp.servei_reserva_tipus_expedient_id = srte.id
 JOIN eco_servei_reserva sr ON srte.servei_reserva_id = sr.id
WHERE sr.id = 2
ORDER BY servei_reserva_tipus_expedient_id DESC, prestacio_id;
----------------------------------------------------------------------
-- Procéss Reserves Anuals
----------------------------------------------------------------------
--
-- Imports totals reservat a Servei Reserva Prestació al 2021 per 
-- tipus de prestació:
--
SELECT srte.tipus_prestacio_id AS "T.Prestació",
	    TO_CHAR(FLOAT8(SUM(import_ordinaria + import_extraordinaria)), 'FM999999999.00') AS "Import total reservat"
FROM eco_servei_reserva_prestacio srp
 JOIN eco_servei_reserva_tipus_expedient srte ON srp.servei_reserva_tipus_expedient_id = srte.id
 JOIN eco_servei_reserva sr ON srte.servei_reserva_id = sr.id
WHERE sr.exercici = 2021
--WHERE sr.id = 2
--  AND srp.prestacio_id = 605
GROUP BY srte.tipus_prestacio_id
ORDER BY srte.tipus_prestacio_id;
--
-- Import total reservat a Prestacio Reserva al 2021 per tipus 
-- prestació: (ATENCIÓN: esta SQL no debe emplearse para el proceso de incremento y comparar con SRP)
--
SELECT srte.tipus_prestacio_id AS "T.Prestació",
	    TO_CHAR(FLOAT8(SUM(epr.import_reservat)), 'FM999999999.00') AS "Import total reservat"
FROM eco_prestacio_reserva epr
 JOIN eco_servei_reserva_prestacio srp ON srp.prestacio_reserva_id = epr.id
 JOIN eco_servei_reserva_tipus_expedient srte ON srp.servei_reserva_tipus_expedient_id = srte.id
 JOIN eco_servei_reserva sr ON srte.servei_reserva_id = sr.id
WHERE sr.exercici = 2021
GROUP BY srte.tipus_prestacio_id
ORDER BY srte.tipus_prestacio_id;
--
-- Import total reservat a Dret Reserva al 2021 per tipus 
-- prestació: (ATENCIÓN: esta SQL no debe emplearse para el proceso de incremento y comparar con SRP)
--
SELECT etp.id AS "T.Prestació",
	   TO_CHAR(FLOAT8(SUM(edr.import_reservat)), 'FM999999999.00') AS "Import total reservat"
FROM eco_dret_reserva edr
 JOIN eco_reserva res ON edr.reserva_id = res.id
 JOIN eco_partida_pressupostaria par ON res.partida_pressupostaria_id = par.id
 JOIN eco_bossa_pressupostaria bos ON par.bossa_pressupostaria_id = bos.id
 JOIN eco_convocatoria con ON bos.convocatoria_id = con.id
 JOIN eco_tipus_expedient_prestacio tep ON con.tipus_expedient_id = tep.id
 JOIN eco_tipus_prestacio etp ON tep.id = etp.tipus_expedient_prestacio_id
WHERE par.exercici = '2021'
GROUP BY etp.id
ORDER BY etp.id;
----------------------------------------------
-- Rellançar increments reserves
----------------------------------------------
--
-- Purgar i actualitzar registres taules:
--
DELETE FROM eco_servei_reserva_prestacio;
DELETE FROM eco_servei_reserva_tipus_expedient;
UPDATE eco_servei_reserva_increment SET servei_reserva_id = NULL;
--UPDATE eco_servei_reserva_increment SET servei_reserva_id = NULL WHERE tipus_prestacio_id <> 6;
DELETE FROM eco_servei_reserva;


--
-- Prestació 31 - "Prestació per atendre necessitats bàsiques":
--
SELECT * FROM eco_activitat WHERE dret_id = 171 ORDER BY data_efecte_inicial DESC, id DESC;
--DELETE FROM eco_activitat WHERE id = 1495;
--UPDATE eco_activitat SET estat_activitat = 1, arxivat = FALSE WHERE id = 284;
SELECT * FROM eco_efecte_moviment_nomina WHERE dret_id = 171 ORDER BY data_efecte_inici DESC;
--DELETE FROM eco_efecte_moviment_nomina WHERE id = 1447;
SELECT * FROM eco_moviment_detall WHERE nomina_id = 171 ORDER BY data_efecte_inicial DESC;
--DELETE FROM eco_moviment_detall WHERE id = 866;
SELECT * FROM eco_moviment WHERE expedient_id = 51;
--DELETE FROM eco_moviment WHERE id = 789;
--
-- Prestació 928 - "Pensió no contributiva":
--
SELECT * FROM eco_activitat WHERE dret_id = 223 ORDER BY data_efecte_inicial DESC, id DESC, rcd_crt_ts DESC;
--DELETE FROM eco_activitat WHERE id IN (1253, 1254);
--UPDATE eco_activitat SET estat_activitat = 1, arxivat = FALSE WHERE id IN (412, 414);
SELECT * FROM eco_efecte_moviment_nomina WHERE dret_id = 223 ORDER BY data_efecte_inici DESC;
--DELETE FROM eco_efecte_moviment_nomina WHERE id = 1326;
SELECT * FROM eco_moviment_detall WHERE nomina_id = 223 ORDER BY data_efecte_inicial DESC;
--DELETE FROM eco_moviment_detall WHERE id = 745;
SELECT * FROM eco_moviment WHERE expedient_id = 1003;
--DELETE FROM eco_moviment WHERE id = 668;
--
-- Prestació 605 - "Prestació econòmica pel complement de la pensió no contributiva"
--
SELECT * FROM eco_activitat WHERE dret_id = 367 ORDER BY data_efecte_inicial DESC, id DESC, rcd_crt_ts DESC;
--DELETE FROM eco_activitat WHERE id IN (1068);
--UPDATE eco_activitat SET estat_activitat = 1, arxivat = FALSE WHERE id IN (769);
SELECT * FROM eco_efecte_moviment_nomina WHERE dret_id = 367 ORDER BY data_efecte_inici DESC;
--DELETE FROM eco_efecte_moviment_nomina WHERE id = 1202;
SELECT * FROM eco_moviment_detall WHERE nomina_id = 367 ORDER BY data_efecte_inicial DESC;
--DELETE FROM eco_moviment_detall WHERE id = 621;
SELECT * FROM eco_moviment WHERE expedient_id = 680 ORDER BY data_creacio_moviment DESC;
--DELETE FROM eco_moviment WHERE id = 544;

