-----------------------------------------------------------------------------------------------------------------------------------------
-- ESOCIAL BBDD
-- Recopilación de consultas y procedimientos.
-- 
-- Creado: 02/06/2020
-- Última modificación: 02/07/2020



---------------------------------------------------------------------------------------------------------------
-- [04.000] INFORMACION IMPORTES
--      [04.001] TIPUS ESTAT DRET
--      [04.002] ESTAT DRET EXPEDIENTE
--      [04.003] PRESTACIO-RESERVA - FILTRO ID PRESTACIO
--      [04.004] RESERVA - FILTRO ID PRESTACIO
--      [04.005] PARTIDA PRESSUPOSTARIA - FILTRO ID PRESTACIO
--      [04.006] BOSSA PRESSUPOSTARIA - FILTRO ID PRESTACIO
--
---------------------------------------------------------------------------------------------------------------
--
-- [04.001] TIPUS ESTAT DRET:
--
SELECT eted.id, eted.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_estat_dret eted	
    JOIN llistat_valors lv ON eted.llistat_valors_id = lv.id
    JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY codi;

SELECT eted.id, eted.codi, lv.acronim, lvi.descripcio
FROM  tipus_servei_extern eted	
    JOIN llistat_valors lv ON eted.llistat_valors_id = lv.id
    JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
WHERE eted.id
ORDER BY codi;

--
-- [04.002] ESTAT DRET EXPEDIENTE
--
SELECT (CASE WHEN (CASE WHEN pre.dret_id IS NULL THEN 0 ELSE pre.dret_id END) = 0
		THEN 'No' ELSE 'Sí - Id: ' || pre.dret_id || ' Estat: ' || lvi.descripcio END) AS "Disposa de Dret"
FROM expedient_prestacio epr
	JOIN prestacio pre ON pre.expedient_prestacio_id = epr.id
	JOIN eco_dret dre ON pre.dret_id = dre.id
	JOIN eco_tipus_estat_dret eted ON dre.estat_id = eted.id
	JOIN llistat_valors lv ON eted.llistat_valors_id = lv.id
    JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
WHERE --epr.numero_expedient = '00006/2020/1000';
		pre.id = 603;
--
-- [04.003] PRESTACIO-RESERVA - FILTRO ID PRESTACIO
--
SELECT 
    epr.id                     AS "Id Prestació-Reserva",
    epr.reserva_id             AS "Id Reserva",
    epr.data_reserva           AS "Data Reserva",
    epr.import_reservat        AS "Imp. Reservat",
    epr.import_recuperat       AS "Imp. Recuperat"
FROM eco_prestacio_reserva epr
WHERE epr.prestacio_id = 287
ORDER BY epr.id;
--
-- [04.004] RESERVA - FILTRO ID PRESTACIO
--
SELECT 
	res.id                          AS "Id Reserva",
    res.partida_pressupostaria_id   AS "Id Partida Pressupostaria",
    res.data_creacio                AS "Data Creació",
    res.data_modificacio            AS "Data Modificació",
    res.import_total                AS "Imp. Total",
    res.import_reservat             AS "Imp. Reservat",
    res.import_ordenat              AS "Imp. Ordenat",
    res.import_pagat                AS "Imp. Pagat",
    res.import_recuperat            AS "Imp. Recuperat",
    res.import_restant              AS "Imp. Restant",
    res.import_trames               AS "Imp. Tramés" 
FROM eco_reserva res 
WHERE res.id IN (SELECT reserva_id FROM eco_prestacio_reserva epr 
                 WHERE epr.prestacio_id = 287)
ORDER BY res.id;
--
-- [04.005] PARTIDA PRESSUPOSTARIA - FILTRO ID PRESTACIO
--
SELECT 
    epp.id                              AS "Id Partida Pressupostaria",
    epp.bossa_pressupostaria_id         AS "Id Bossa Pressupostaria.",
    epp.exercici                        AS "Exercici",
    epp.ordre_consum                    AS "O. Consum",
    epp.import_total                    AS "Imp. Total",
    epp.import_reservat                 AS "Imp. Reservat",
    epp.import_ordenat                  AS "Imp. Ordenat",
    epp.import_pagat                    AS "Imp. Pagat",
    epp.import_recuperat                AS "Imp. Recuperat",
    epp.import_restant                  AS "Imp. Restant",
    epp.import_trames                   AS "Imp. Tramés",
    epp.import_disponible               AS "Imp. Disponible" 
FROM eco_partida_pressupostaria epp
WHERE epp.id IN (SELECT res.partida_pressupostaria_id FROM eco_reserva res 
                 WHERE res.id IN (SELECT epr.reserva_id FROM eco_prestacio_reserva epr
                                  WHERE epr.prestacio_id = 287))
ORDER BY epp.id;
--
-- [04.006] BOSSA PRESSUPOSTARIA - FILTRO ID PRESTACIO
--
SELECT 
    ebp.id                              AS "Id Bossa Pressupostaria",
    ebp.convocatoria_id                 AS "Id Convocatoria",
    ebp.exercici                        AS "Exercici",
    ebp.import_total                    AS "Imp. Total",
    ebp.import_reservat                 AS "Imp. Reservat",
    ebp.import_ordenat                  AS "Imp. Ordenat",
    ebp.import_pagat                    AS "Imp. Pagat",
    ebp.import_recuperat                AS "Imp. Recuperat",
    ebp.import_restant                  AS "Imp. Restant"
FROM eco_bossa_pressupostaria ebp
WHERE ebp.id IN (SELECT epp.bossa_pressupostaria_id
                 FROM eco_partida_pressupostaria epp
                 WHERE epp.id IN 
                (SELECT res.partida_pressupostaria_id
                 FROM eco_reserva res 
                 WHERE res.id IN 
                (SELECT epr.reserva_id 
                 FROM eco_prestacio_reserva epr
                 WHERE epr.prestacio_id = 287)))
ORDER BY ebp.id;





--
-- [04.006] PROCESO DE RESOLUCIO - INFORMACION ACTUACION EN NOMINA
--
SELECT 
    emo.expedient_id                                AS "Id Expedient",
    emo.procediment_id                              AS "Id Procediment",
    emo.tramit_id                                   AS "Id Tramit",	
    pre.id                                          AS "Id Prestació",
    emo.id                                          AS "Id Moviment",
    emd.id                                          AS "Id Mov.Detall",	
    dre.id                                          AS "Id Dret",
    dre.nomina_id                                   AS "Id Nòmina",
    pre.tipus_prestacio_id                          AS "T. Prestació",
    eno.tipus_nomina_id                             AS "T. Nòmina",
    lvi.descripcio || ' [' ||	dre.estat_id || ']' AS "Estat Dret",	
    dre.data_efecte_inici                           AS "Dret Inici",
    dre.data_efecte_fi                              AS "Dret Fi",	
    emd.data_efecte_inicial                         AS "M. Det.Inici",
    emd.data_efecte_final                           AS "M. Det.Fi",
    emd.import_moviment                             AS "M. Det.Import",	
    emo.data_creacio_moviment                       AS "Mov. Creació",
    emo.estat_moviment                              AS "Mov. Estat",
    emo.contingut_moviment                          AS "Mov. Contingut"
FROM prestacio pre
    JOIN eco_dret dre ON pre.dret_id = dre.id
    JOIN eco_moviment_detall emd ON dre.nomina_id = emd.nomina_id
    JOIN eco_nomina eno ON emd.nomina_id = eno.id
    JOIN eco_moviment emo ON emd.moviment_id = emo.id
    JOIN eco_tipus_estat_dret eted ON dre.estat_id = eted.id
    JOIN llistat_valors lv ON eted.llistat_valors_id = lv.id
    JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
WHERE pre.id = 287;
--WHERE emd.nomina_id = 16;
--
-- [04.007] PROCESO DE RESOLUCIO - DRET RESERVA
--
SELECT
    edr.id                  AS "Id Dret Reserva",
    edr.dret_id             AS "Id Dret",
    edr.reserva_id          AS "Id Reserva",
    edr.ordre_consum        AS "O. Consum",	
    edr.import_reservat     AS "Imp. Reservat",
    edr.import_ordenat      AS "Imp. Ordenat",
    edr.import_trames       AS "Imp. Tramés",
    edr.import_pagat        AS "Imp. Pagat",
    edr.import_recuperat    AS "Imp. Recuperat",
    edr.import_restant      AS "Imp. Restant"
FROM eco_dret_reserva edr
WHERE dret_id = 16;
--------------------------------------------------------------------------------------
-- [05.000] INFORMACION IMPORTES NOMINA
--      [05.001] PRESTACIO-RESERVA
--      [05.002] RESERVA
--      [05.003] PARTIDA PRESSUPOSTARIA
--      [05.004] BOSSA PRESSUPOSTARIA
--      [05.005] DRET RESERVA
--
--------------------------------------------------------------------------------------
--
-- [05.001] PRESTACIO-RESERVA
--
SELECT DISTINCT
    epr.id                     AS "Id Prestació-Reserva",
    epr.reserva_id             AS "Id Reserva",
    epr.data_reserva           AS "Data Reserva",
    epr.import_reservat        AS "Imp. Reservat",
    epr.import_recuperat       AS "Imp. Recuperat"
FROM eco_prestacio_reserva epr
    JOIN prestacio pre ON epr.prestacio_id = pre.id
    JOIN eco_dret dre ON pre.dret_id = dre.id
    JOIN eco_moviment_detall emd ON dre.nomina_id = emd.nomina_id
    JOIN eco_moviment mov ON emd.moviment_id = mov.id
WHERE emd.nomina_id = 16
ORDER BY epr.id;
--
-- [05.002] RESERVA
--
SELECT 
	res.id                          AS "Id Reserva",
    res.partida_pressupostaria_id   AS "Id Partida Pressupostaria",
    res.data_creacio                AS "Data Creació",
    res.data_modificacio            AS "Data Modificació",
    res.import_total                AS "Imp. Total",
    res.import_reservat             AS "Imp. Reservat",
    res.import_ordenat              AS "Imp. Ordenat",
    res.import_pagat                AS "Imp. Pagat",
    res.import_recuperat            AS "Imp. Recuperat",
    res.import_restant              AS "Imp. Restant",
    res.import_trames               AS "Imp. Tramés" 
FROM eco_reserva res 
WHERE res.id IN (SELECT DISTINCT epr.reserva_id
				 FROM eco_prestacio_reserva epr
				   JOIN prestacio pre ON epr.prestacio_id = pre.id
				   JOIN eco_dret dre ON pre.dret_id = dre.id
				   JOIN eco_moviment_detall emd ON dre.nomina_id = emd.nomina_id
				   JOIN eco_moviment mov ON emd.moviment_id = mov.id
				 WHERE emd.nomina_id = 16)
ORDER BY res.id;	
--
-- [05.003] PARTIDA PRESSUPOSTARIA
--
SELECT 
    epp.id                              AS "Id Partida Pressupostaria",
    epp.bossa_pressupostaria_id         AS "Id Bossa Pressupostaria.",
    epp.exercici						AS "Exercici",
    epp.ordre_consum                    AS "O. Consum",
    epp.import_total                    AS "Imp. Total",
    epp.import_reservat                 AS "Imp. Reservat",
    epp.import_ordenat                  AS "Imp. Ordenat",
    epp.import_pagat                    AS "Imp. Pagat",
    epp.import_recuperat                AS "Imp. Recuperat",
    epp.import_restant                  AS "Imp. Restant",
    epp.import_trames                   AS "Imp. Tramés",
    epp.import_disponible               AS "Imp. Disponible" 
FROM eco_partida_pressupostaria epp
WHERE epp.id IN (SELECT res.partida_pressupostaria_id
				 FROM eco_reserva res 
				 WHERE res.id IN 
				(SELECT DISTINCT epr.reserva_id
				 FROM eco_prestacio_reserva epr
				   JOIN prestacio pre ON epr.prestacio_id = pre.id
				   JOIN eco_dret dre ON pre.dret_id = dre.id
				   JOIN eco_moviment_detall emd ON dre.nomina_id = emd.nomina_id
				   JOIN eco_moviment mov ON emd.moviment_id = mov.id
				 WHERE emd.nomina_id = 16))
ORDER BY epp.id;
--
-- [05.004] BOSSA PRESSUPOSTARIA
--
SELECT 
    ebp.id                              AS "Id Bossa Pressupostaria",
    ebp.convocatoria_id                 AS "Id Convocatoria",
    ebp.exercici                        AS "Exercici",
    ebp.import_total                    AS "Imp. Total",
    ebp.import_reservat                 AS "Imp. Reservat",
    ebp.import_ordenat                  AS "Imp. Ordenat",
    ebp.import_pagat                    AS "Imp. Pagat",
    ebp.import_recuperat                AS "Imp. Recuperat",
    ebp.import_restant                  AS "Imp. Restant"
FROM eco_bossa_pressupostaria ebp
WHERE ebp.id IN (SELECT epp.bossa_pressupostaria_id
				 FROM eco_partida_pressupostaria epp
				 WHERE epp.id IN 
				(SELECT res.partida_pressupostaria_id
				 FROM eco_reserva res 
				 WHERE res.id IN 
				(SELECT DISTINCT epr.reserva_id
				 FROM eco_prestacio_reserva epr
				   JOIN prestacio pre ON epr.prestacio_id = pre.id
				   JOIN eco_dret dre ON pre.dret_id = dre.id
				   JOIN eco_moviment_detall emd ON dre.nomina_id = emd.nomina_id
				   JOIN eco_moviment mov ON emd.moviment_id = mov.id
				 WHERE emd.nomina_id = 16)))
ORDER BY ebp.id;
--
-- [05.005] DRET RESERVA
--
SELECT DISTINCT
    edr.id                  AS "Id Dret Reserva",
    edr.dret_id             AS "Id Dret",
    edr.reserva_id          AS "Id Reserva",
    edr.ordre_consum        AS "O. Consum",	
    edr.import_reservat     AS "Imp. Reservat",
    edr.import_ordenat      AS "Imp. Ordenat",
    edr.import_trames       AS "Imp. Tramés",
    edr.import_pagat        AS "Imp. Pagat",
    edr.import_recuperat    AS "Imp. Recuperat",
    edr.import_restant      AS "Imp. Restant"
FROM eco_dret_reserva edr
	JOIN eco_dret dre ON edr.dret_id = dre.id
	JOIN eco_moviment_detall emd ON dre.nomina_id = emd.nomina_id
	JOIN eco_moviment mov ON emd.moviment_id = mov.id
WHERE emd.nomina_id = 16;



















