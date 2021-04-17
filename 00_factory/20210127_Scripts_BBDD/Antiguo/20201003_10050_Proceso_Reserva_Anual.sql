----------------------------------------------------------------------------------------------------------------- 
-- ESOCIAL-10050 - Procés d'actualització de reserves anuals
--
-- [03/11/2020]
-----------------------------------------------------------------------------------------------------------------
SET SCHEMA 'esocial';
--------------------------------------------------------------------------------------------------------------
-- Presupuestos
--------------------------------------------------------------------------------------------------------------
--
-- Estas son las tablas implicadas:
--
SELECT * FROM eco_convocatoria ORDER BY tipus_expedient_id, data_pagament_inici DESC, id;
SELECT * FROM eco_bossa_pressupostaria ORDER BY exercici DESC, convocatoria_id, id;
SELECT * FROM eco_partida_pressupostaria ORDER BY exercici DESC, ordre_consum, id;
SELECT * FROM eco_reserva ORDER BY data_creacio DESC, partida_pressupostaria_id, id;
--
-- Por ejemplo, para el ejercicio 2020, se crearon:
--
SELECT * FROM eco_convocatoria 
WHERE id IN (SELECT convocatoria_id FROM eco_bossa_pressupostaria WHERE exercici = '2020')
ORDER BY tipus_expedient_id, data_pagament_inici DESC, id;

SELECT * FROM eco_bossa_pressupostaria 
WHERE exercici = '2020'
ORDER BY exercici DESC, convocatoria_id, id;

SELECT * FROM eco_partida_pressupostaria 
WHERE exercici = '2020'
ORDER BY exercici DESC, ordre_consum, id;
SELECT * FROM eco_partida_pressupostaria 
WHERE bossa_pressupostaria_id IN (SELECT id FROM eco_bossa_pressupostaria WHERE exercici = '2020')
ORDER BY exercici DESC, ordre_consum, id;

SELECT * FROM eco_reserva 
WHERE partida_pressupostaria_id IN (SELECT id FROM eco_partida_pressupostaria WHERE exercici = '2020')
ORDER BY data_creacio DESC, partida_pressupostaria_id, id;
SELECT * FROM eco_reserva 
WHERE partida_pressupostaria_id IN (SELECT id FROM eco_partida_pressupostaria 
												WHERE bossa_pressupostaria_id IN (SELECT id FROM eco_bossa_pressupostaria 
																							 WHERE exercici = '2020'));
ORDER BY data_creacio DESC, partida_pressupostaria_id, id;
--
-- Si nos fijamos en las convocatorias para el 2020, observaremos que se han creado dos registros para
-- algunos de los tipos de expedientes existentes:
--
SELECT con.id AS "Id Convocatoria",
		 '[' || con.tipus_expedient_id || '] ' || lvi.descripcio AS "T.Expedient",
		 bos.id AS "Id Bossa",
		 bos.import_total AS "Imp.Total Bossa",
		 par.id AS "Id Partida",
		 par.codi_partida AS "Codi Partida",
		 par.import_total AS "Imp.Total Partida",
		 par.ordre_consum AS "Ordre Consum",
		 res.id AS "Id Reserva",
		 res.codi_reserva AS "Codi Reserva",
		 res.import_total AS "Imp.Total Reserva",
		 res."virtual" AS "Virtual",
		 res.data_creacio AS "D.Creació Reserva",
 		 res.data_modificacio AS "D.Modificació Reserva"
FROM eco_convocatoria con
	JOIN eco_bossa_pressupostaria bos ON con.id = bos.convocatoria_id	
	JOIN eco_tipus_expedient_prestacio tex ON con.tipus_expedient_id = tex.id
	JOIN llistat_valors lv ON tex.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
	JOIN eco_partida_pressupostaria par ON bos.id = par.bossa_pressupostaria_id
	JOIN eco_reserva res ON par.id = res.partida_pressupostaria_id
WHERE bos.exercici = '2020'
ORDER BY con.tipus_expedient_id, con.data_pagament_inici DESC, con.id;
--
-- Podemos filtrar la anterior SQL por el tipo de prestación para comprobar que se precisa
-- de estas tablas para un tipo de prestación en particular:
--
SELECT con.id AS "Id Convocatoria",
		 '[' || con.tipus_expedient_id || '] ' || lvi.descripcio AS "T.Expedient",
		 bos.id AS "Id Bossa",
		 bos.import_total AS "Imp.Total Bossa",
		 par.id AS "Id Partida",
		 par.codi_partida AS "Codi Partida",
		 par.import_total AS "Imp.Total Partida",
		 par.ordre_consum AS "Ordre Consum",
		 res.id AS "Id Reserva",
		 res.codi_reserva AS "Codi Reserva",
		 res.import_total AS "Imp.Total Reserva",
		 res."virtual" AS "Virtual",
		 res.data_creacio AS "D.Creació Reserva",
 		 res.data_modificacio AS "D.Modificació Reserva"
FROM eco_convocatoria con
	JOIN eco_bossa_pressupostaria bos ON con.id = bos.convocatoria_id	
	JOIN eco_tipus_expedient_prestacio tex ON con.tipus_expedient_id = tex.id
	JOIN llistat_valors lv ON tex.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
	JOIN eco_partida_pressupostaria par ON bos.id = par.bossa_pressupostaria_id
	JOIN eco_reserva res ON par.id = res.partida_pressupostaria_id
WHERE bos.exercici = '2020'
  AND con.tipus_expedient_id = 2
ORDER BY con.tipus_expedient_id, con.data_pagament_inici DESC, con.id;
--
-- NOTA: Podemos comprobar que para el tipo 2 (Prestació per al mantenimient de despeses de la llar per a determinats col·lectius)
-- 	   se dispone de dos registros, uno con Importe Total Partida y Reserva 7.300.000 y otra con ambos campos a 0. 
--
-- Así, una primera aproximación al algoritmo de comprobación de la existencia de la convocatoria y los presupuestos sería:
--
--
-- Obtenemos todos los tipos disponibles de expedientes-prestaciones:
--
SELECT etep.id, etep.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_expedient_prestacio etep	
	JOIN llistat_valors lv ON etep.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id	
ORDER BY codi; -- ids = 1, 2, 3, 4, 5, 6
--
-- Para cada uno de los tipos anteriores, determinamos el tipo de nómina asociado:
--
SELECT etep.id AS "Id",
		 (SELECT lvi.descripcio FROM llistat_valors lv 
		  JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		  WHERE etep.llistat_valors_id = lv.id) AS "Tipus Expedient-Prestació",		 
		 etp.tipus_nomina_id AS "Id",
		 (SELECT lvi.descripcio FROM llistat_valors lv 
		  JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		  WHERE etp.llistat_valors_id = lv.id) AS "Tipus Nòmina"
FROM eco_tipus_expedient_prestacio etep
	LEFT JOIN eco_tipus_prestacio etp ON etep.id = etp.tipus_expedient_prestacio_id
ORDER BY etep.id;
--
--  Para cada uno de los tipos de nómina obtenidos con la SQL anterior, determinamos
--  la última nómina ejecutada:
--
SELECT etep.id AS "T.Exp.Pres.",
		 etp.id AS "T.Prestació",
		 etp.tipus_nomina_id AS "T.Nòmina",
		 (SELECT lvi.descripcio FROM llistat_valors lv 
		  JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		  WHERE etep.llistat_valors_id = lv.id) AS "Descripció",
		 (SELECT id FROM eco_nomina_mensual
		  WHERE tipus_nomina_id = etp.tipus_nomina_id
		  ORDER BY data_nomina DESC LIMIT 1) AS "Última Nòm.Mensual",		  
  		 (SELECT data_nomina FROM eco_nomina_mensual
		  WHERE tipus_nomina_id = etp.tipus_nomina_id
		  ORDER BY data_nomina DESC LIMIT 1) AS "Data Nòm.Mensual"
FROM eco_tipus_expedient_prestacio etep
 LEFT JOIN eco_tipus_prestacio etp ON etep.id = etp.tipus_expedient_prestacio_id
ORDER BY etep.id;
--
-- Si para algún tipo de nómina no se obtiene una nómina mensual, se debe entender que el presupuesto es para el año
-- siguiente al actual. CONSULTAR CON RICARD!!!!
--
-- [2020110] En conversaciones con Ricard decidimos crear un end-point para el lanzamiento del proceso de generación
--			    de la reserva de las presetaciones. Él se encargará de crear los registros correspondientes a las tablas
--				 eco_convocatoria, eco_bossa_pressupostaria, eco_partida_pressupostaria i eco_reserva. Cuando se solicité
--				 iniciar el proceso a través del end-point, se recibirá como parámetro el ejercicio para el que se desea
--			    crear la reserva de las prestaciones.
--
-- Así, partiré de una solicitud de generación de las reservas para un ejercicio determinado, por lo que tendré que
-- comprobar que se dispone de esta información antes de iniciar el proceso.
--
-- Siguiendo los pasos descritos en el método "makeReservaPrestacio()", empleado para crear una nueva reserva, y codificado
-- en la clase "PrestacioReservaBusiness", se deberían realizar los siguientes pasos:
--
-- Paso 1: Convocatoria. [convocatoriaRepository.findByTipusExpedientPrestacioIdAndDataTerminiInici()]
--			  Estos registros serían las convocatorias disponibles para el ejercicio indicado.
--
SELECT con.* 
FROM eco_convocatoria con
 JOIN eco_tipus_expedient_prestacio tep ON con.tipus_expedient_id = tep.id
WHERE con.data_termini_inici = '2020-01-01 00:00'
ORDER BY con.tipus_expedient_id;
--
-- Paso 2: Bosses. [bossaPressupostariaRepository.findByConvocatoriaIdAndImportRestantGreaterThanOrderByCodiAsc()]
--			  A partir del Id de las Convocatories obtenidas buscamos las Bosses asociadas.
--
SELECT con.tipus_expedient_id AS "T.Expedient", 
		 bos.*
FROM eco_bossa_pressupostaria bos
 JOIN eco_convocatoria con ON bos.convocatoria_id = con.id
 JOIN eco_tipus_expedient_prestacio tep ON con.tipus_expedient_id = tep.id
WHERE con.data_termini_inici = '2020-01-01 00:00'
  AND bos.import_restant > 0
ORDER BY con.tipus_expedient_id;
--
-- Paso 3: Partides. [partidaPressupostariaRepository.findAllByBossaPressupostariaAndImportRestantMajorZeroOrderByOrdreConsum()]
--			  A partir del Id de las Bosses buscamos las Partides asocidas.
--			  Es posible obtener más de una Bossa para una Convocatoria y Tipus Expedient-Prestacio en particular. Cuando esto ocurra,
--			  para obtener las Partides, podemos emplear los datos de cualquiera de las Bosses obtenidas.
--
SELECT con.tipus_expedient_id AS "T.Expedient",
		 con.id AS "Id Convocatoria",	 
		 par.*
FROM eco_partida_pressupostaria par
 JOIN eco_bossa_pressupostaria bos ON par.bossa_pressupostaria_id = bos.id
 JOIN eco_convocatoria con ON bos.convocatoria_id = con.id
 JOIN eco_tipus_expedient_prestacio tep ON con.tipus_expedient_id = tep.id
WHERE con.data_termini_inici = '2020-01-01 00:00'
  AND bos.import_restant > 0
  AND par.import_restant > 0
  AND par.actuacio_gestio_id = 1
ORDER BY con.tipus_expedient_id;
--
-- Paso 4: Reserves. [reservaRepository.findAllByPartidaPressupostariaAndAmbitAndImportRestantMajorZeroOrderByCodiReserva()] 
-- 		  A partir del Id de las Partides buscamos las Reserves asociadas.
--			  Es posible obtener más de una Partida para una Bossa, Convocatoria y Tipus Expedient-Prestacio en particular. Cuando 
-- 		  esto ocurra, para obtener las Reserves, podemos emplear los datos de cualquiera de las Partides obtenidas.
SELECT con.tipus_expedient_id AS "T.Expedient",
		 con.id AS "Id Convocatoria",
		 bos.id AS "Id Bossa",
		 res.*
FROM eco_reserva res
 JOIN eco_partida_pressupostaria par ON res.partida_pressupostaria_id = par.id
 JOIN eco_bossa_pressupostaria bos ON par.bossa_pressupostaria_id = bos.id
 JOIN eco_convocatoria con ON bos.convocatoria_id = con.id
 JOIN eco_tipus_expedient_prestacio tep ON con.tipus_expedient_id = tep.id
WHERE con.data_termini_inici = '2021-01-01 00:00'
  AND bos.import_restant > 0
  AND par.import_restant > 0
  AND par.actuacio_gestio_id = 1
  AND res.import_restant > 0
ORDER BY con.tipus_expedient_id;
--
-- Teniendo en cuenta todo lo anterior, una vez recibamos la solicitud de generación de reservas para cada una de las
-- prestaciones, realizaremos las siguientes validaciones:
--
-- Obtenemos los Tipos d'Expedient Prestació que disponen de los registros de "presupuestos" necesarios para 
--	realizar la reserva del ejercicio indicado:
--
SELECT tep.id AS "T.Expedient",
		 res.id AS "Reserva" 
FROM eco_tipus_expedient_prestacio tep
 JOIN eco_convocatoria con ON tep.id = con.tipus_expedient_id
 JOIN eco_bossa_pressupostaria bos ON con.id = bos.convocatoria_id
 JOIN eco_partida_pressupostaria par ON bos.id = par.bossa_pressupostaria_id
 JOIN eco_reserva res ON par.id = res.partida_pressupostaria_id
WHERE con.data_termini_inici = '2020-01-01 00:00'
  AND bos.import_restant > 0
  AND par.import_restant > 0
  AND par.actuacio_gestio_id = 1
  AND res.import_restant > 0
ORDER BY con.tipus_expedient_id;
--
-- Para cada uno de los Tipus d'Expedient Prestació obtenidos, comprobamos que el EXERCICI indicado sea 
--	mayor que el año de la última nómina mensual existente para el Tipus de Prestació asociada. Si es 
--	es mayor, podrá crearse la reserva, y en caso contrario, no. Si no existe ninguna nómina mensual,
--	tendría que asegurarme que no se haya creado la reserva ya realizando otras comprobaciones.
--
SELECT tep.id AS "T.Expedient",		 
		 (SELECT id FROM eco_nomina_mensual
		  WHERE tipus_nomina_id = etp.tipus_nomina_id
		  ORDER BY data_nomina DESC LIMIT 1) AS "Última Nòm.Mensual",		  
  		 (SELECT data_nomina FROM eco_nomina_mensual
		  WHERE tipus_nomina_id = etp.tipus_nomina_id
		  ORDER BY data_nomina DESC LIMIT 1) AS "Data Nòm.Mensual",
		 (SELECT estat FROM eco_nomina_mensual
		  WHERE tipus_nomina_id = etp.tipus_nomina_id
		  ORDER BY data_nomina DESC LIMIT 1) AS "Estat Nòm.Mensual" 		  
FROM eco_tipus_expedient_prestacio tep
 JOIN eco_tipus_prestacio etp ON tep.id = etp.tipus_expedient_prestacio_id
ORDER BY tep.id;
--
-- Para aquellos Tipus d'Expedient Prestació que no dispongan de nómina mensual, comprobaré si existe
--	alguna Prestació Reserva asociada. Si existiera, querría decir que ya se realizó una reserva 
--	para ese EXERCICI anteriormente y no podría realizarse la nueva reserva, en caso contrario, sí.
--
SELECT COUNT(*) = 0 AS "Realizar reserva"
FROM eco_prestacio_reserva
WHERE reserva_id = 35;
--
-- Podemos integrar las tres comprobaciones en una sola SQL que nos permitirá obtener los Ids de los
-- Tipus d'Expedient Prestació para los que será posible realizar la nueva reserva.
--
-- [DEFINITIVA] SQL para realizar la valización 
-- 
-- [12/11 - Anulo esta validación por una nueva expuesta más adelante]
-- 
SELECT tep.id AS "T.Expedient" 
FROM eco_tipus_expedient_prestacio tep
 JOIN eco_convocatoria con ON tep.id = con.tipus_expedient_id
 JOIN eco_bossa_pressupostaria bos ON con.id = bos.convocatoria_id
 JOIN eco_partida_pressupostaria par ON bos.id = par.bossa_pressupostaria_id
 JOIN eco_reserva res ON par.id = res.partida_pressupostaria_id
WHERE con.data_termini_inici = '2021-01-01 00:00'
  AND bos.import_restant > 0
  AND par.import_restant > 0
  AND par.actuacio_gestio_id = 1
  AND res.import_restant > 0
  AND res.id NOT IN (SELECT DISTINCT reserva_id FROM eco_prestacio_reserva)
ORDER BY con.tipus_expedient_id;
--
-- NOTA: Si la consulta no retorna ningún registro, se retornará una mensaje de error "No es posible crear ninguna reserva. 
--			Compruebe que se dispone de los registros de presupuestos necesarios para cada uno de los tipos de expedientes y
--			el ejercicio indicado, asi como que no se haya realizada la reserva con anterioridad para cada uno de ellos".
--			Si la consulta retorna registros, se procederá a realizar la reserva para cada uno de los Tipus d'Expedient Prestació
--			obtenidos.
--
--------------------------------------------------------------------------------------------------------------
-- Tablas trazabilidad
--------------------------------------------------------------------------------------------------------------
--
-- Ver "eSocial-SQL-000000781-DES-J10050-GLS.sql" en ".\00 - Código\20201126_00_Script_DCR".
-- Fichero de rollback ".\00 - Código\20201126_02_Script_Rollback.sql"
-- 
-- Comprobar resultados:
--
SELECT * FROM llistat_valors_agrupacions WHERE id = 1147;
SELECT * FROM llistat_valors_agrupacions_idioma WHERE id = 1157;
SELECT * FROM llistat_valors WHERE id = 12451;
SELECT * FROM llistat_valors_idioma WHERE llistat_valors_id = 12451;
SELECT * FROM eco_tipus_servei_reserva;
SELECT * FROM cataleg_taules WHERE id = 419;
SELECT * FROM eco_servei_reserva;
SELECT * FROM eco_servei_reserva_tipus_expedient;
SELECT * FROM eco_servei_reserva_prestacio;
SELECT * FROM registre_scripts WHERE script = 'eSocial-SQL-000000781-DES-J10050-GLS';
--
-- Listado de todos los tipos de servicios de reserva disponibles:
-- 
SELECT *
FROM  eco_tipus_servei_reserva te	
	JOIN llistat_valors lv ON te.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY te.id;
--
-- Notas:
--
--		Cuando creamos una reserva para una prestación modificamos las tablas "eco_prestacio_reserva"
--		y "eco_dret_reserva":
--
SELECT * FROM eco_prestacio_reserva;
SELECT * FROM eco_dret_reserva;
--
--		a) Con "eco_prestacio_reserva.prestacio_id" podemos determinar "prestacio.id".
--		b) Con "eco_dret_reserva.dret_id" podemos determinar "eco_dret.id".
--		c) Ambas disponen de "reserva_id" con el que podemos determinar "eco_reserva.id".
--
-- 	Así, si dispongo de "eco_reserva.id", ¿puedo obtener el resto de información de presupuestos?
--
SELECT con.id AS "Convocatoria",
		 bos.id AS "Bossa",
		 par.id AS "Partida",
		 res.id AS "Reserva"
FROM eco_convocatoria con
	JOIN eco_bossa_pressupostaria bos ON con.id = bos.convocatoria_id
	JOIN eco_partida_pressupostaria par ON bos.id = par.bossa_pressupostaria_id
	JOIN eco_reserva res ON par.id = res.partida_pressupostaria_id
WHERE res.id = 33;
--
--    En conclusión, para determinar los parámetros empleados para una reserva determinada
--    únicamente necesitamos el id de la reserva empleado.
--
--------------------------------------------------------------------------------------------------------------
-- Nueva lógica de validación
--------------------------------------------------------------------------------------------------------------
--
-- En apartados anteriores se considero la siguiente SQL para la validación:
-- 
SELECT tep.id AS "T.Expedient" 
FROM eco_tipus_expedient_prestacio tep
 JOIN eco_convocatoria con ON tep.id = con.tipus_expedient_id
 JOIN eco_bossa_pressupostaria bos ON con.id = bos.convocatoria_id
 JOIN eco_partida_pressupostaria par ON bos.id = par.bossa_pressupostaria_id
 JOIN eco_reserva res ON par.id = res.partida_pressupostaria_id
WHERE con.data_termini_inici = '2020-01-01 00:00'
  AND bos.import_restant > 0
  AND par.import_restant > 0
  AND par.actuacio_gestio_id = 1
  AND res.import_restant > 0
  AND res.id NOT IN (SELECT DISTINCT reserva_id FROM eco_prestacio_reserva)
ORDER BY con.tipus_expedient_id;
--
-- Sin embargo, ahora debemos realizar la reserva para aquellas prestaciones que no dispongan de 
-- la misma para el exercici indicado, independientemente que existan otras prestaciones que ya 
-- dispongan de reserva para el mimos; esta es la diferencia ahora con respecto a la anterior
-- validación.
--
-- Teniendo en cuenta lo anterior:
--
-- [07] Determinar si existen los presupuestos para los tipos de prestaciones ------ [DEFINITIVA]
--      disponibles y el ejercicio indicado: 
-- 
-- 	  TipusPrestacioRepository.getIdTipusPrestacioPerReservaAnual()
--
SELECT tpr.id AS "T.Prestació"
FROM eco_tipus_prestacio tpr
 JOIN eco_tipus_expedient_prestacio tep ON tpr.tipus_expedient_prestacio_id = tep.id
 JOIN eco_convocatoria con ON tep.id = con.tipus_expedient_id
 JOIN eco_bossa_pressupostaria bos ON con.id = bos.convocatoria_id
 JOIN eco_partida_pressupostaria par ON bos.id = par.bossa_pressupostaria_id
 JOIN eco_reserva res ON par.id = res.partida_pressupostaria_id
WHERE con.data_termini_inici = '2020-01-01 00:00'
  AND bos.import_restant > 0
  AND par.import_restant > 0
  AND par.actuacio_gestio_id = 1
  AND res.import_restant > 0
ORDER BY con.tipus_expedient_id;
------------------------------------------------------------------------------------ [DEFINITIVA]
--
-- No se requiere más comprobación. Al iterar cada uno de los tipos obtenidos, determinaré si existen
-- nóminas para realizar reserva o no.
--
--------------------------------------------------------------------------------------------------------------
-- Obtención de los datos a procesar
--------------------------------------------------------------------------------------------------------------
--
-- A través de la consulta de validación obtendremos los identificadores de los Tipos de Expedientes para los 
-- que tendremos que realizar la reserva. 
--
--
-- Tipus Prestació Vs. Tipus Nòmina:
--
SELECT etp.id AS "T.Prestació",		 
		 etn.id AS "T.Nòmina"
FROM eco_tipus_prestacio etp
	JOIN eco_tipus_prestacio_tipus_nomina etptn ON etp.id = etptn.tipus_prestacio_id AND etp.tipus_nomina_id = etptn.tipus_nomina_id
	JOIN eco_tipus_nomina etn ON etptn.tipus_nomina_id = etn.id
ORDER BY etp.id;
--
-- Prestaciones con dret filtradas por tipo de prestación:
--
SELECT pre.*
FROM prestacio pre
 JOIN eco_tipus_prestacio tpr ON pre.tipus_prestacio_id = tpr.id
WHERE pre.dret_id IS NOT NULL
  AND pre.tipus_prestacio_id IN (1, 3, 6, 8);
-- 302 prestaciones
--
-- Nóminas:
--
SELECT * FROM eco_nomina;
-- 302 nóminas.
SELECT nom.*
FROM eco_nomina nom
WHERE nom.tipus_nomina_id IN (2, 12, 13, 11)
  AND nom.estat_id IN (1, 3);
-- 300 nóminas.
-- 
-- Derechos:
--
SELECT dre.*
FROM eco_dret dre,
	  eco_nomina nom
WHERE dre.nomina_id = nom.id
  AND nom.tipus_nomina_id IN (2, 12, 13, 11)
  AND nom.estat_id IN (1, 3)
ORDER BY dre.id;
-- 300 derechos.
--
-- [08] La siguiente SQL permite obtener las prestaciones que disponen de una ------ [DEFINITIVA]
--		  nómina en estado de Alta o Suspesa para cada uno de los tipos de 
--		  prestación indicados:
--
-- 	  PrestacioRepository.getPrestacionsNominaAltaSuspesa()
--
SELECT pre.*
FROM prestacio pre,
     eco_tipus_prestacio tpr,
     eco_dret dre,
     eco_tipus_prestacio_tipus_nomina tptn,
     eco_nomina nom
WHERE pre.tipus_prestacio_id = tpr.id
  AND pre.tipus_prestacio_id IN (1, 3, 6, 8)
  AND pre.dret_id = dre.id
  AND dre.nomina_id = nom.id
  AND tptn.tipus_prestacio_id = tpr.id
  AND tptn.tipus_nomina_id = nom.tipus_nomina_id
  AND nom.estat_id IN (1, 3)
ORDER BY pre.id;
-- 300 prestaciones.
------------------------------------------------------------------------------------ [DEFINITIVA]
--
--	La siguiente SQL presenta el número de nóminas en estado de Alta y Suspensió por tipos:
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
-- T.Expedient	T.Prestació	T.Nomina Total Nòmines
-- ----------- ----------- -------- -------------
-- 1	         6	         13	      121
-- 2	         1	         2	      40
-- 3	         8	         11	      181
-- 4	         3	         12	      25    
--
-- Ahora que disponemos de las prestaciones con nóminas activas y candidatas a crear la reserva,
-- tenemos que determinar si ya existe una reserva para ese ejercicio y prestación, en cuyo 
-- caso no debemos realizar la reserva.
--
-- [09] Permite determinar si una prestación en particular dispone de reservas ----- [DEFINITIVA]
--      para el ejercicio indicado.
--
-- 	  PrestacioReservaRepository.disposaReservesExercici()
--
SELECT CASE WHEN COUNT(prv.*) > 0 THEN TRUE ELSE FALSE END 
FROM eco_prestacio_reserva prv
 JOIN eco_reserva res ON prv.reserva_id = res.id
 JOIN eco_partida_pressupostaria par ON res.partida_pressupostaria_id = par.id
 JOIN eco_bossa_pressupostaria bos ON par.bossa_pressupostaria_id = bos.id
 JOIN eco_convocatoria con ON bos.convocatoria_id = con.id
WHERE con.data_termini_inici = '2019-01-01 00:00'  
  AND prv.prestacio_id = 1;
------------------------------------------------------------------------------------ [DEFINITIVA]
--
-- Para cada una de las prestaciones que no dispongan de reserva para el ejercicio indicado
-- debemos buscar sus actividades y comprobar si es necesario realizar reservas.
--
--
-- Tipus Motiu Activitat:
--
SELECT mac.id, mac.codi, lv.acronim, lvi.descripcio
FROM eco_motiu_activitat mac	
	JOIN llistat_valors lv ON mac.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY mac.codi;
--
-- [10] La siguiente SQL permite recuperar las actividades activas de una ---------- [DEFINITIVA]
--      prestación:
--
-- 	  ActivitatRepository.getActivitatsPerReservaAnual()
--
SELECT act.*
FROM eco_activitat act
 JOIN eco_dret dre ON act.dret_id = dre.id
 JOIN prestacio pre ON dre.id = pre.dret_id
WHERE act.estat_activitat = '1'
  AND act.motiu_id = 1
  AND (EXTRACT(YEAR FROM act.data_efecte_inicial) <= 2019)
  AND (act.data_efecte_final IS NULL 
   OR  EXTRACT(YEAR FROM act.data_efecte_final) >= 2019)
  AND pre.id = 94
ORDER BY act.data_efecte_inicial;
------------------------------------------------------------------------------------ [DEFINITIVA]

--
-- [02] Primero debemos obtener los Drets asociados a la Nòmina. 
-- La tabla "eco_dret" dispone del campo "nomina_id", pero su PK es "id", por lo que 
-- se permite disponer de más de un Dret para una Nòmina en particular!!!!
--
SELECT dre.id, nom.id 
FROM eco_dret dre
JOIN eco_nomina nom ON dre.nomina_id = nom.id
ORDER BY dre.id, nom.id;
--
-- [03] Una vez disponemos de los identificadores de los Drets de la Nòmina, obtenemos
--		  las Activitats activas:
--
SELECT act.*
FROM eco_activitat act
JOIN eco_dret dre ON act.dret_id = dre.id
JOIN eco_nomina nom ON dre.nomina_id = nom.id
WHERE nom.id = 169
  AND act.estat_activitat = '1';
--
-- La anterior SQL Retorna toda la Activitat activa para una Nòmina en particular, lo que incluye tanto la 
-- Modalitat Ordinària como la Extraordinària. Dado que antes de realizar la reserva de las actividades de
-- Extraordinària se debe llamar a Corticon, el procesamiento de ambas modalidades deberá realizarse de 
-- forma independiente.
--
-- Por otro lado tengo que decidir qué es mejor, si obtener todas las nóminas y actividades en una sola consulta o 
-- ejecutar una consulta por tipo de prestación, por nómina, etc. Antes de decidirlo, voy a realizar unas consultas
-- para evaluar el volumen de datos aproximado.

--
--	b) Número de Activitats a procesar por Tipo de Expediente:
--
SELECT tep.id AS "T.Expedient",
		 nom.tipus_nomina_id AS "T.Nomina",
		 COUNT(act.*) AS "Total Activitats"
FROM eco_activitat act
JOIN eco_dret dre ON act.dret_id = dre.id	 
JOIN eco_nomina nom ON dre.nomina_id = nom.id
JOIN eco_tipus_prestacio_tipus_nomina tptn ON nom.tipus_nomina_id = tptn.tipus_nomina_id
JOIN eco_tipus_prestacio tpr ON tptn.tipus_prestacio_id = tpr.id
JOIN eco_tipus_expedient_prestacio tep ON tpr.tipus_expedient_prestacio_id = tep.id
WHERE tep.id IN (1, 2, 3, 4)
  AND nom.estat_id IN (1, 3)
GROUP BY tep.id, nom.tipus_nomina_id
ORDER BY tep.id;
/*
	T.Expedient	T.Nomina	   Total Activitats
	----------- --------    ----------------
	1	         13	         217
	2	         2	         40
	3	         11	         373
	4	         12	         8
*/
SELECT tep.id AS "T.Expedient",
		 tptn.tipus_nomina_id AS "T.Nomina",
		 (SELECT COUNT(nom.*) 
 		  FROM eco_nomina nom
		 ) AS "Total Nòmines"
		 (SELECT COUNT(
		 	FROM eco_activitat act
			JOIN eco_dret dre ON act.dret_id = dre.id	 
			JOIN eco_nomina nom ON dre.nomina_id = nom.id
		 ) 
FROM eco_tipus_prestacio_tipus_nomina tptn
 JOIN eco_tipus_prestacio tpr ON tptn.tipus_prestacio_id = tpr.id
 JOIN eco_tipus_expedient_prestacio tep ON tpr.tipus_expedient_prestacio_id = tep.id
ORDER BY tep.id;
--------------------------------------------------------------------------------------------------------------
-- Obtención de las actividades de liquidación
--------------------------------------------------------------------------------------------------------------
--
-- Activitats de liquidación para abonar en el 2021:
--
SELECT act.* 
FROM eco_activitat act
WHERE act.estat_activitat = '1'
  AND act.motiu_id = 1
  AND act.liquidacio = true
  AND act.pagament_modalitat_id = 2
  AND (EXTRACT(YEAR FROM act.data_efecte_inicial) <= 2021)
  AND (act.data_efecte_final IS NULL 
   OR  EXTRACT(YEAR FROM act.data_efecte_final) >= 2021)	
ORDER BY act.data_efecte_inicial;
--
-- Activitat, Dret, Nòmina, Prestació y Tipus Prestació de liquidación:
--
SELECT act.id AS "Activitat", 
		 act.quantitat AS "Quantitat",
		 act.data_efecte_inicial AS "D.Inicial",
	    dre.id AS "Dret", 
		 nom.id AS "Nòmina",
		 pre.id AS "Prestació",
		 tpr.id AS "T.Prestació"
FROM eco_activitat act
JOIN eco_dret dre ON act.dret_id = dre.id
JOIN eco_nomina nom ON dre.nomina_id = nom.id
JOIN prestacio pre ON  dre.id = pre.dret_id
JOIN eco_tipus_prestacio tpr ON pre.tipus_prestacio_id = tpr.id
WHERE act.estat_activitat = '1'
  AND act.motiu_id = 1
  AND act.liquidacio = TRUE
  AND act.pagament_modalitat_id = 2
  AND (EXTRACT(YEAR FROM act.data_efecte_inicial) <= 2021)
  AND (act.data_efecte_final IS NULL 
   OR  EXTRACT(YEAR FROM act.data_efecte_final) >= 2021)
ORDER BY act.id;
--
-- Prestació asociada a la nómina
--
SELECT * FROM eco_activitat WHERE id = 831;
SELECT * FROM prestacio WHERE 
SELECT * FROM eco_prestacio_reserva
SELECT * FROM eco_dret_reserva




--------- PRUEBAS:

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
-- T.Expedient	T.Prestació	T.Nomina Total Nòmines
-- ----------- ----------- -------- -------------
-- 1	         6	         13	      121
-- 2	         1	         2	      40
-- 3	         8	         11	      181
-- 4	         3	         12	      25   

--
-- Resultats procés reserva anual:
--
SELECT con.tipus_expedient_id AS "T.Expedient",
		 tpr.id AS "T.Prestació",
		 bos.exercici AS "Exercici",
		 con.id AS "Id Convocatoria",
		 bos.id AS "Id Bossa",	    
		 par.id AS "Id Partida",
		 res.id AS "Id Reserva",
		 res.import_total AS "R.Imp.Total",
		 res.import_reservat AS "R.Imp.Reservat",
		 res.import_restant AS "R.Imp.Restant",
		 (res.import_total - (res.import_reservat + res.import_restant)) AS "T - (Rv + Rt)",
		 (SELECT ROUND(SUM(srp.import_ordinaria + srp.import_extraordinaria)::NUMERIC,2)
		  FROM eco_servei_reserva_prestacio srp
		  JOIN eco_servei_reserva_tipus_expedient srte ON srp.servei_reserva_tipus_expedient_id = srte.id
		  WHERE srte.reserva_id = res.id) AS "T.Reserva Anual",
		 (SELECT ROUND(SUM(epr.import_reservat)::NUMERIC,2)
		  FROM eco_prestacio_reserva epr WHERE epr.reserva_id = res.id) AS "PR.T.Reservat",
  		 (SELECT ROUND(SUM(edr.import_reservat)::NUMERIC,2)
		  FROM eco_dret_reserva edr WHERE edr.reserva_id = res.id) AS "DR.T.Reservat"
FROM eco_reserva res
 JOIN eco_partida_pressupostaria par ON res.partida_pressupostaria_id = par.id
 JOIN eco_bossa_pressupostaria bos ON par.bossa_pressupostaria_id = bos.id
 JOIN eco_convocatoria con ON bos.convocatoria_id = con.id
 JOIN eco_tipus_expedient_prestacio tep ON con.tipus_expedient_id = tep.id
 JOIN eco_tipus_prestacio tpr ON tep.id = tpr.tipus_expedient_prestacio_id
WHERE con.data_termini_inici = '2021-01-01 00:00'
  --AND bos.import_restant > 0
  --AND par.import_restant > 0
  --AND par.actuacio_gestio_id = 1
  --AND res.import_restant > 0
ORDER BY con.tipus_expedient_id;

--
-- DELETE PRESSUPOST:
--
-- eco_dret_reserva
SELECT * FROM eco_dret_reserva
WHERE reserva_id IN (SELECT id FROM eco_reserva 
					  	   WHERE partida_pressupostaria_id IN (SELECT id FROM eco_partida_pressupostaria WHERE exercici = '2021'));
DELETE FROM eco_dret_reserva
WHERE reserva_id IN (SELECT id FROM eco_reserva 
					  	   WHERE partida_pressupostaria_id IN (SELECT id FROM eco_partida_pressupostaria WHERE exercici = '2021'));
-- eco_prestacio_reserva
SELECT * FROM eco_prestacio_reserva
WHERE reserva_id IN (SELECT id FROM eco_reserva 
					  	   WHERE partida_pressupostaria_id IN (SELECT id FROM eco_partida_pressupostaria WHERE exercici = '2021'));
DELETE FROM eco_prestacio_reserva
WHERE reserva_id IN (SELECT id FROM eco_reserva 
					  	   WHERE partida_pressupostaria_id IN (SELECT id FROM eco_partida_pressupostaria WHERE exercici = '2021'));					  	   
-- eco_reserva
SELECT * FROM eco_reserva 
WHERE partida_pressupostaria_id IN (SELECT id FROM eco_partida_pressupostaria WHERE exercici = '2021');
DELETE FROM eco_reserva 
WHERE partida_pressupostaria_id IN (SELECT id FROM eco_partida_pressupostaria WHERE exercici = '2021');
-- eco_partida_pressupostaria
SELECT * FROM eco_partida_pressupostaria WHERE exercici = '2021';
DELETE FROM eco_partida_pressupostaria WHERE exercici = '2021';
-- eco_bossa_pressupostaria
SELECT * FROM eco_bossa_pressupostaria WHERE exercici = '2021';
DELETE FROM eco_bossa_pressupostaria WHERE exercici = '2021';
-- eco_convocatoria
SELECT * FROM eco_convocatoria where data_pagament_inici = '2021-01-01 00:00:00.000';
DELETE FROM eco_convocatoria where data_pagament_inici = '2021-01-01 00:00:00.000';




