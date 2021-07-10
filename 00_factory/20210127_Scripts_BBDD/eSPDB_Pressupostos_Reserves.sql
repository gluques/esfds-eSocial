---------------------------------------------------------------------------------------------------------------------
--  eSPDB_Pressupostos_Reserves.sql
--	Recull de sentències SQL associades als pressupostos i reserves.
-- 
--  Created by gluques. 
--  Barcelona, July 8, 2021
--  						  																					   								    
--  Last update: 08/07/2021
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
-- PRESSUPOSTOS I RESERVES
--
--  [01] CONVOCATORIA, BOSSA, PARTIDA I RESERVA PER UN EXERCICI
--  [02] 
--  [03] 
--  [04] 
--  [05] 
--  
---------------------------------------------------------------------------------------------------------------------
SET SCHEMA 'esocial';
--
-- [06.01] CONVOCATORIA, BOSSA, PARTIDA I RESERVA PER UN EXERCICI
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
WHERE bos.exercici = '2021'
ORDER BY con.tipus_expedient_id, con.data_pagament_inici DESC, con.id;



-------------------------------------------
-- Sin organizar
-------------------------------------------

--
-- EXEMPLE DE CREACIO DE PRESSUPOSTOS PER UN TIPUS D'EXPEDIENT:
-- "Prestació econòmica sotmesa al nivell d'ingressos de la unitat familiar per a famílies 
--  en què ha tingut lloc un naixement, una adopció, una tutela o un acolliment [5]"
--
INSERT INTO eco_convocatoria (opt_lck_ctl,rcd_crt_nm,rcd_crt_ts,tipus_expedient_id,virtual,data_pagament_inici,data_pagament_fi,data_termini_inici,data_termini_fi) 
  VALUES (0, 'ECONOMICS', current_timestamp, 5, '0','2021-01-01 00:00:00.000',null,'2021-01-01 00:00:00.000',null);

INSERT INTO eco_bossa_pressupostaria (opt_lck_ctl, rcd_crt_nm, rcd_crt_ts, convocatoria_id, import_total,import_reservat,import_ordenat,import_pagat,import_recuperat,import_restant,exercici,import_trames,codi) 
  VALUES (0, 'ECONOMICS', current_timestamp, (SELECT id FROM eco_convocatoria where tipus_expedient_id = 5 and data_pagament_inici = '2021-01-01 00:00:00.000'), 40000000, 0, 0, 0, 0, 40000000, '2021', 0, '001');

INSERT INTO eco_partida_pressupostaria (opt_lck_ctl,rcd_crt_nm,rcd_crt_ts,bossa_pressupostaria_id,ambit_partida_pressupostaria_id,exercici,codi_partida,import_total,import_reservat,import_ordenat,import_pagat,import_recuperat,import_restant,tipus_estat_partida_id,import_trames,percentatge_reserves,ordre_consum,prorrogat,import_disponible, actuacio_gestio_id)
  VALUES (0, 'ECONOMICS', current_timestamp,(SELECT id FROM eco_bossa_pressupostaria where convocatoria_id = (SELECT id FROM eco_convocatoria where tipus_expedient_id = 5 and data_pagament_inici = '2021-01-01 00:00:00.000') and codi = '001'), 1,'2021','BE 13 D/480.0017/317', 40000000, 0,0,0,0,40000000,1,0,100,1,'0',40000000, 1);

INSERT INTO eco_partida_pressupostaria (opt_lck_ctl,rcd_crt_nm,rcd_crt_ts,bossa_pressupostaria_id,ambit_partida_pressupostaria_id,exercici,codi_partida,import_total,import_reservat,import_ordenat,import_pagat,import_recuperat,import_restant,tipus_estat_partida_id,import_trames,percentatge_reserves,ordre_consum,prorrogat,import_disponible, actuacio_gestio_id)
  VALUES (0, 'ECONOMICS', current_timestamp,(SELECT id FROM eco_bossa_pressupostaria where convocatoria_id = (SELECT id FROM eco_convocatoria where tipus_expedient_id = 5 and data_pagament_inici = '2021-01-01 00:00:00.000') and codi = '001'), 1,'2021','BE 13 D/480.0017/317', 0, 0,0,0,0,0,1,0,100,1,'0',0, 2);

INSERT INTO eco_reserva(opt_lck_ctl,rcd_crt_nm,rcd_crt_ts,partida_pressupostaria_id,ambit_territorial_id,codi_reserva,virtual,import_total,import_reservat,import_ordenat,import_pagat,import_recuperat,import_restant,import_trames,percentatge_partida, data_creacio, usuari_creacio)
  VALUES (0, 'ECONOMICS', current_timestamp, (SELECT id FROM eco_partida_pressupostaria where actuacio_gestio_id = 1 AND bossa_pressupostaria_id = (SELECT id FROM eco_bossa_pressupostaria where convocatoria_id = (SELECT id FROM eco_convocatoria where tipus_expedient_id = 5 and data_pagament_inici = '2021-01-01 00:00:00.000'))),7, '001', '0', 40000000, 0, 0, 0, 0, 40000000, 0, 100,  current_timestamp, 'ECONOMICS');
       
INSERT INTO eco_reserva(opt_lck_ctl,rcd_crt_nm,rcd_crt_ts,partida_pressupostaria_id,ambit_territorial_id,codi_reserva,virtual,import_total,import_reservat,import_ordenat,import_pagat,import_recuperat,import_restant,import_trames,percentatge_partida, data_creacio, usuari_creacio)
  VALUES (0, 'ECONOMICS', current_timestamp, (SELECT id FROM eco_partida_pressupostaria where actuacio_gestio_id = 2 AND bossa_pressupostaria_id = (SELECT id FROM eco_bossa_pressupostaria where convocatoria_id = (SELECT id FROM eco_convocatoria where tipus_expedient_id = 5 and data_pagament_inici = '2021-01-01 00:00:00.000'))),7, '001', '0', 0, 0, 0, 0, 0, 0, 0, 100,  current_timestamp, 'ECONOMICS'); 
  
  