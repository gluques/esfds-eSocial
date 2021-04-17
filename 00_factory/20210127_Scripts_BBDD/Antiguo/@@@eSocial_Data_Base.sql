-----------------------------------------------------------------------------------------------------------------------------------------
-- ESOCIAL Data Base
-----------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Genérics base de dades
-------------------------------------------------------------------------------------
-- Seleccionar esquema de treball: 
SET SCHEMA 'esocial';
-------------------------------------------------------------------------------------
-- Prestacions:
-------------------------------------------------------------------------------------
-- Totes les prestacions:
SELECT * FROM prestacio ORDER BY id DESC;
--
-- Tipus de prestació:
SELECT tt.id, tt.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_prestacio tt	
	JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id;
--
-- Determinar el tipus de prestació:
SELECT p.id AS "Prestació", p.expedient_prestacio_id AS "Exp.Pres.",
		 lvi.descripcio || ' (' || p.tipus_prestacio_id || ')' AS "Tipus prestacio",
		 p.data_efecte_inici AS "Data Efecte Inici", p.dret_id AS "Dret"
FROM prestacio p JOIN eco_tipus_prestacio tp ON p.tipus_prestacio_id = tp.id
	JOIN llistat_valors lv ON tp.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
WHERE p.id = 427;

-------------------------------------------------------------------------------------
-- Expedients-Prestacions:
-------------------------------------------------------------------------------------
-- Totss els expedients-prestacions:
SELECT * FROM expedient_prestacio ORDER BY id DESC;
--
-- Un expedient-prestació en particular:
SELECT * FROM expedient_prestacio WHERE id = 66;
-------------------------------------------------------------------------------------
-- Convocatoria:
-------------------------------------------------------------------------------------
-- Totes les convocatories:
SELECT * FROM eco_convocatoria ORDER BY id DESC;
-------------------------------------------------------------------------------------
-- Bossa Pressupostaria:
-------------------------------------------------------------------------------------
-- Totes les bosses pressupostaries:
SELECT * FROM eco_bossa_pressupostaria ORDER BY id DESC;
-------------------------------------------------------------------------------------
-- Partida Pressupostaria:
-------------------------------------------------------------------------------------
-- Totes les partides pressupostaries:
SELECT * FROM eco_partida_pressupostaria ORDER BY id DESC;
-- Tipus estat partida pressupostaria:
SELECT tt.id, tt.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_estat_partida tt	
	JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id;

-------------------------------------------------------------------------------------
-- Nòmina mensual:
-------------------------------------------------------------------------------------
-- Totes les nòmines mensuals:
SELECT * FROM eco_nomina_mensual ORDER BY id DESC;
--
-- Tipus de nòmines mensuals:
SELECT tt.id, tt.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_nomina_mensual tt	
	JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id;
--
-- Nòmnines mensuals de un tipus determinat:
SELECT * FROM eco_nomina_mensual WHERE tipus_nomina_id = 2 ORDER BY id DESC;
-------------------------------------------------------------------------------------
-- Nòmina:
-------------------------------------------------------------------------------------
-- Totes les nòmines:
SELECT * FROM eco_nomina ORDER BY id DESC;
-- Tipus de nòmines:
SELECT tt.id, tt.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_nomina tt	
	JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id;
-- Estats nòmina
SELECT tt.id, tt.codi, lv.acronim, lvi.descripcio
FROM  eco_estat_nomina tt	
	JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id;
-- Nòmines de un tipus determinat:
SELECT * FROM eco_nomina WHERE tipus_nomina_id = 11 ORDER BY id DESC;

SELECT id, data_alta_nomina FROM eco_nomina WHERE id IN (2, 7, 9);

----------------------------------------------------------------------------------------------------
--
-- PartidaPressupostaria.obtenirPartidaPressupostariaPerTipusExpedientIAny()
--
----------------------------------------------------------------------------------------------------
-- 1. Convocatoria:
--
-- 	Ref. final Convocatoria convocatoria = convocatoriaRepository
--					.findByTipusExpedientPrestacioIdAndDataTerminiInici(tipusExpedientId, dataPagamentInici);
--
-- 	tipusExpedientId 	= expedient_prestacio.tipus_expedient_prestacio_id
--		dataPagamentInici	= 01-01-< Any[eco_nomina_mensual.data_nomina] o Any[data_actual]>
----------------------------------------------------------------------------------------------------
SELECT * FROM eco_convocatoria 
WHERE tipus_expedient_id = 3 AND data_pagament_inici = '01/01/2020';
----------------------------------------------------------------------------------------------------
-- 2. LLista de bosses pressupostaries:
--
-- 	Ref. convocatoria.getBossaPressupostariaList()
----------------------------------------------------------------------------------------------------
SELECT * FROM eco_bossa_pressupostaria
WHERE convocatoria_id IN (SELECT id FROM eco_convocatoria WHERE id = 28);
----------------------------------------------------------------------------------------------------
-- 3. LLista de bosses pressupostaries:
--
-- 	Ref. bossaPressupostaria.getPartidaPressupostariaList();
----------------------------------------------------------------------------------------------------
SELECT * FROM eco_partida_pressupostaria
WHERE bossa_pressupostaria_id IN (SELECT id FROM eco_bossa_pressupostaria
											 WHERE convocatoria_id IN (SELECT id FROM eco_convocatoria WHERE id = 28));
----------------------------------------------------------------------------------------------------
-- 4. Partides pressupostaria per any:
--
-- 	Ref. partidaPressupostaria = obtenirPartidaPressupostariaPerAny(partidesPressupostaries, any);
----------------------------------------------------------------------------------------------------
SELECT * FROM eco_partida_pressupostaria
WHERE bossa_pressupostaria_id IN (SELECT id FROM eco_bossa_pressupostaria
											 WHERE convocatoria_id IN (SELECT id FROM eco_convocatoria WHERE id = 28))
 AND exercici = '2020';

SELECT * FROM eco_partida_pressupostaria WHERE id = 32


-----------------------------------------------------------------------------------
-- Expedient a PRE
-----------------------------------------------------------------------------------
SELECT * FROM esocial.expedient_prestacio WHERE id = 66; 
-- persona_id = 501544, numero_expedient = 00002/2019/86, 
SELECT * FROM esocial.procediment_prestacio WHERE expedient_prestacio_id = 170;
-- id = 142
SELECT * FROM esocial.tramit_prestacio WHERE procediment_prestacio_id = 142;
SELECT * FROM esocial.tramit_prestacio WHERE id = 78565; -- id obtenido del JSON de Reserva!!!
-- id = 78565
SELECT * FROM eco_prestacio_reserva WHERE prestacio_id = 140; -- prestacio_id obtenido del JSON de Reserva!!!
-- reserva_id = 31
SELECT * FROM eco_reserva WHERE id = 31;
-- partida_pressupostaria_id = 31
SELECT * FROM eco_partida_pressupostaria WHERE id = 31;
SELECT exercici FROM eco_partida_pressupostaria WHERE id = 31;
SELECT * FROM eco_partida_pressupostaria WHERE exercici = '2020';
SELECT * FROM eco_partida_pressupostaria WHERE rcd_crt_ts >= '01-01-2020';

SELECT * FROM eco_prestacio_reserva WHERE prestacio_id = 140;
SELECT * FROM eco_prestacio_reserva WHERE import_reservat < 0 AND reserva_id <> 31;
-- reserva_id = 26, 29, prestacio_id = 76, (412, 415)
SELECT * FROM eco_prestacio_reserva WHERE prestacio_id = 412;
SELECT * FROM eco_prestacio_reserva WHERE prestacio_id = 415;

-----------------------------------------------------------------------------------
-- Datos Excel PRE nomina id = 3
-----------------------------------------------------------------------------------
-- eco_nomina
SELECT * FROM eco_nomina WHERE id = 3; -- id obtenido del JSON de respuesta Reserva
-- eco_nomina_persona
SELECT * FROM eco_nomina_persona WHERE nomina_id = 3; -- persona_id = 501348
-- identificador
SELECT * FROM identificador WHERE persona_id = 501348;
-- expedient_prestacio
SELECT * FROM esocial.expedient_prestacio WHERE id = 66; -- id obtenido del JSON de Reserva
-- procediment_prestacio
SELECT * FROM esocial.procediment_prestacio WHERE expedient_prestacio_id = 66; -- id = 46
-- tramit_prestacio
SELECT * FROM esocial.tramit_prestacio WHERE procediment_prestacio_id = 46 ORDER BY id DESC;
SELECT * FROM esocial.tramit_prestacio WHERE id = 64294; -- id obtenido del JSON de Reserva!!!
-- eco_prestacio_reserva 
SELECT * FROM eco_prestacio_reserva WHERE prestacio_id = 46; -- reserva_id = 13, 29
-- eco_reserva
SELECT * FROM eco_partida_pressupostaria WHERE id IN (13, 29); -- bossa_pressupostaria_id = 13, 27
-- eco_bossa_pressupostaria
SELECT * FROM eco_bossa_pressupostaria WHERE id IN (13, 27);
-- eco_reserva
SELECT * FROM eco_reserva WHERE partida_pressupostaria_id IN (13, 29);
-- eco_dret_reserva
SELECT * FROM eco_dret_reserva WHERE reserva_id IN (13,29);
-- eco_dret
SELECT * FROM eco_dret WHERE nomina_id = 3; -- id = 3
-- eco_moviment
SELECT * FROM eco_moviment WHERE expedient_id = 66; -- id = 3, procediment_id = 46, tramit_id = 4950
-- eco_moviment_detall
SELECT * FROM eco_moviment_detall WHERE moviment_id = 3; -- id = 3
-- eco_efecte_moviment_nomina
SELECT * FROM eco_efecte_moviment_nomina WHERE moviment_detall_id = 3;
SELECT * FROM eco_efecte_moviment_nomina WHERE dret_id = 3;
-- eco_activitat 
SELECT * FROM eco_activitat WHERE dret_id = 3 AND moviment_id = 3;
-- eco_dret_teoric
SELECT * FROM eco_dret_teoric WHERE dret_id = 3 ORDER BY data_efecte;
-- eco_dret_teoric_detall
SELECT * FROM eco_dret_teoric_detall WHERE dret_id = 3;
-- eco_activitat_detall
SELECT * FROM eco_activitat_detall WHERE nomina_id = 3;


SELECT * FROM esocial.eco_efecte_moviment_nomina WHERE id = 261;
SELECT * FROM esocial.eco_efecte_moviment_nomina WHERE moviment_detall_id = 138;

----------------------------------------------------------------------------------------
-- PRE: Efectes nómines amb modificacions de import 03/2020
----------------------------------------------------------------------------------------
-- 100, 221, 223, 225, 227, 229, 231, 233, 235, 237, 239, 241, 243, 245, 247, 256, 258, 260
/*
EfecteMovimentNomina efecte = efecteMovimentNominaRepository.findById(activitat.getIdEfecteMovimentNomina());
List<DretTeoricDetall> dretTeoricDetall = dretTeoricDetallRepository.findByDretOrderByDataEfecteDesc(efecte.getDret());
if ((dretTeoricDetall != null) && (dretTeoricDetall.size() > 1)) {
	DretTeoricDetall ultimDretTeoricDetall = dretTeoricDetall.get(0);
	DretTeoricDetall peniltimDretTeoricDetall = dretTeoricDetall.get(1);
	if (ultimDretTeoricDetall.getQuantitat().equals(peniltimDretTeoricDetall.getQuantitat())) {
		esModificacio = false;
	}
}
*/
SELECT id, dret_id, tipus_id, import_anterior, import_actual, diferencial 
FROM esocial.eco_efecte_moviment_nomina
WHERE id IN (100, 221, 223, 225, 227, 229, 231, 233, 235, 237, 239, 241, 243, 245, 247, 256, 258, 260)
ORDER BY id DESC;

SELECT * 
FROM esocial.eco_dret_teoric_detall
WHERE dret_id IN (64,82,81,27,84,15,1,88,77,38,80,90,6,54,19,65,86,49)
  AND data_efecte <= '2020-03-01'
ORDER BY dret_id, data_efecte DESC;

SELECT *
FROM esocial.eco_efecte_moviment_nomina
WHERE dret_id = 90
ORDER BY data_efecte_inici DESC;

SELECT * FROM eco_nomina_mensual ORDER BY data_nomina DESC;

-----------------------------------------------------------------------
-- Tipus estat Activitat
-----------------------------------------------------------------------
SELECT tt.id, tt.codi, lv.acronim, lvi.descripcio
FROM  tipus_activitat_estat tt	
	JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id;
-----------------------------------------------------------------------
-- Tipus motiu activitat
-----------------------------------------------------------------------
SELECT tt.id, tt.codi, lv.acronim, lvi.descripcio
FROM eco_motiu_activitat tt	
	JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id;
-----------------------------------------------------------------------
-- Tipus de pagament modalitat
-----------------------------------------------------------------------
SELECT tt.id, tt.codi, lv.acronim, lvi.descripcio
FROM tipus_pagament_modalitat tt	
	JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id;
-----------------------------------------------------------------------
-- Tipus pagament tipus
-----------------------------------------------------------------------	
SELECT tt.id, tt.codi, lv.acronim, lvi.descripcio
FROM tipus_pagament_tipus tt	
	JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id;


		
SELECT * FROM eco_activitat WHERE motiu_id = 2;
SELECT * FROM eco_nomina_mensual ORDER BY id DESC;
SELECT * FROM eco_activitat_detall WHERE nomina_mensual_id = 17;

select distinct nomina1_.id as id1_81_,
nomina1_.ambit_territorial_id as ambit_t11_81_,
nomina1_.data_alta_nomina as data_alt2_81_,
nomina1_.data_efecte_fi as data_efe3_81_,
nomina1_.data_efecte_inici as data_efe4_81_,
nomina1_.data_estat as data_est5_81_,
nomina1_.data_primera_execucio as data_pri6_81_,
nomina1_.estat_motiu_id as estat_m12_81_,
nomina1_.opt_lck_ctl as opt_lck_7_81_,
nomina1_.rcd_crt_nm as rcd_crt_8_81_,
nomina1_.rcd_crt_ts as rcd_crt_9_81_,
nomina1_.simulat as simulat10_81_,
nomina1_.estat_id as estat_i13_81_,
nomina1_.tipus_nomina_id as tipus_n14_81_
from eco_activitat_detall activitatd0_
inner join eco_nomina nomina1_ on activitatd0_.nomina_id=nomina1_.id
where activitatd0_.nomina_mensual_id=18
and (activitatd0_.nomina_id not in  (select activitatd2_.nomina_id
from eco_activitat_detall activitatd2_
where activitatd2_.nomina_mensual_id=16))

SELECT * FROM eco_nomina_mensual WHERE tipus_nomina_id = 2 ORDER BY id DESC;

SELECT * FROM eco_nomina_mensual 
WHERE tipus_nomina_id = 2 AND tipus_nomina_mensual_id = 1 AND data_nomina < '2020-03-01'
ORDER BY id DESC LIMIT 1;


------------------------------------------------------------------------------------------------------------------------------
-- Expendients 208
------------------------------------------------------------------------------------------------------------------------------
-- Tipues expedient-prestació:
SELECT tt.id, tt.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_expedient_prestacio tt	
	JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id;
-- Prestació
SELECT * FROM prestacio;
SELECT * FROM solicitud;
SELECT * FROM procediment_prestacio;
SELECT * FROM registre_expedient_prestacio;
-- Prestació per atendre necessitats bàsiques (3)
SELECT * FROM expedient_prestacio WHERE id = 389; -- 00002/2019/208 - 501819 - 2019-06-18 12:29:00.476
SELECT * FROM expedient_prestacio WHERE id = 402; -- 00002/2019/217 - 501850 - 2019-07-01 13:06:47.434 

-- Persona i nòmina:
SELECT * FROM persona WHERE id = 501819;
SELECT * FROM persona WHERE id = 501850;

-- Nòmina:
SELECT * FROM eco_nomina_persona WHERE persona_id = 501819;
SELECT * FROM eco_nomina_persona WHERE persona_id = 501850;

SELECT * FROM eco_nomina WHERE id = 95;

-----------------------------------------------------------------------------------
-- Datos Excel para 
-----------------------------------------------------------------------------------
-- eco_nomina
SELECT * FROM eco_nomina WHERE id = 3; -- id obtenido del JSON de respuesta Reserva
-- eco_nomina_persona
SELECT * FROM eco_nomina_persona WHERE nomina_id = 3; -- persona_id = 501348
-- identificador
SELECT * FROM identificador WHERE persona_id = 501348;
-- expedient_prestacio
SELECT * FROM esocial.expedient_prestacio WHERE id = 66; -- id obtenido del JSON de Reserva
-- procediment_prestacio
SELECT * FROM esocial.procediment_prestacio WHERE expedient_prestacio_id = 66; -- id = 46
-- tramit_prestacio
SELECT * FROM esocial.tramit_prestacio WHERE procediment_prestacio_id = 46 ORDER BY id DESC;
SELECT * FROM esocial.tramit_prestacio WHERE id = 64294; -- id obtenido del JSON de Reserva!!!
-- eco_prestacio_reserva 
SELECT * FROM eco_prestacio_reserva WHERE prestacio_id = 46; -- reserva_id = 13, 29
-- eco_reserva
SELECT * FROM eco_partida_pressupostaria WHERE id IN (13, 29); -- bossa_pressupostaria_id = 13, 27
-- eco_bossa_pressupostaria
SELECT * FROM eco_bossa_pressupostaria WHERE id IN (13, 27);
-- eco_reserva
SELECT * FROM eco_reserva WHERE partida_pressupostaria_id IN (13, 27);
-- eco_dret_reserva
SELECT * FROM eco_dret_reserva WHERE reserva_id IN (13,29);
-- eco_dret
SELECT * FROM eco_dret WHERE nomina_id = 3; -- id = 3
-- eco_moviment
SELECT * FROM eco_moviment WHERE expedient_id = 66; -- id = 3, procediment_id = 46, tramit_id = 4950
-- eco_moviment_detall
SELECT * FROM eco_moviment_detall WHERE moviment_id = 3; -- id = 3
-- eco_efecte_moviment_nomina
SELECT * FROM eco_efecte_moviment_nomina WHERE moviment_detall_id = 3;
-- eco_activitat 
SELECT * FROM eco_activitat WHERE dret_id = 3 AND moviment_id = 3;
-- eco_dret_teoric
SELECT * FROM eco_dret_teoric WHERE dret_id = 3 ORDER BY data_efecte;
-- eco_dret_teoric_detall
SELECT * FROM eco_dret_teoric_detall WHERE dret_id = 3;
-- eco_activitat_detall
SELECT * FROM eco_activitat_detall WHERE nomina_id = 3;
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------
-- Script arrodoniment 
------------------------------------------------------------------
SELECT table_name, column_name FROM information_schema.columns
WHERE table_schema = 'esocial' 
  AND table_name LIKE 'eco%'
  AND data_type = 'double precision';


SELECT * FROM expedient_prestacio WHERE id = 241;
SELECT * FROM persona WHERE id = 501600;
SELECT * FROM eco_nomina_persona WHERE persona_id = 501600;

SELECT * FROM eco_nomina WHERE id = 3;

-------------------------------------------------------------------
-- Expeciente Girona 9/10
-------------------------------------------------------------------
SELECT * FROM esocial.expedient_prestacio WHERE id = 66; 
-- Id expedient del JSON de Reserva
-- retorna "00001/2019/9"
-- persona = 501348
SELECT * FROM identificador WHERE persona_id = 501348;
-- 38383569L
SELECT * FROM esocial.expedient_prestacio WHERE numero_expedient = '00001/2019/10';
-- persona 501352
SELECT * FROM identificador WHERE persona_id = 501352;
--37292252Y

-------------------------------------------------------------------
-- Expeciente "00002/2019/86"
-------------------------------------------------------------------
SELECT * FROM expedient_prestacio WHERE id = 170; -- "00002/2019/86" - 2019-03-11 13:16:31.796 - 501544
SELECT * FROM identificador WHERE id = 501544; -- 49781046F
SELECT * FROM eco_nomina_persona WHERE persona_id = 501544; -- No existe!
SELECT * FROM procediment_prestacio WHERE id = 142; -- "00002/2019/86"
SELECT * FROM registre_expedient_prestacio WHERE expedient_prestacio_id = 170;
SELECT * FROM prestacio WHERE expedient_prestacio_id = 170; -- id = 140
SELECT * FROM eco_prestacio_reserva WHERE prestacio_id = 140;
SELECT SUM(import_reservat) FROM eco_prestacio_reserva WHERE prestacio_id = 140;
--11080.149999999998
-------------------------------------------------------------------
-- Expeciente "00002/2019/208"
-------------------------------------------------------------------
SELECT * FROM expedient_prestacio WHERE id = 389; -- "00002/2019/208" - 2019-06-18 12:29:00.476 - 501819
SELECT * FROM identificador WHERE id = 501819; -- 38690162E
SELECT * FROM eco_nomina_persona WHERE persona_id = 501819; -- No existe!
SELECT * FROM procediment_prestacio WHERE id = 317; -- "00002/2019/208"
SELECT * FROM registre_expedient_prestacio WHERE expedient_prestacio_id = 389;
SELECT * FROM prestacio WHERE expedient_prestacio_id = 389; -- id = 315
SELECT * FROM eco_prestacio_reserva WHERE prestacio_id = 315;

-------------------------------------------------------------------
-- Expeciente "00002/2019/217"
-------------------------------------------------------------------
SELECT * FROM expedient_prestacio WHERE id = 402; -- "00002/2019/217" - 2019-07-01 13:03:44.115 - 501850
SELECT * FROM identificador WHERE id = 501850; -- Y1161086Z
SELECT * FROM eco_nomina_persona WHERE persona_id = 501850; -- No existe!
SELECT * FROM procediment_prestacio WHERE id = 333; -- "00002/2019/217"
SELECT * FROM registre_expedient_prestacio WHERE expedient_prestacio_id = 402;
SELECT * FROM prestacio WHERE expedient_prestacio_id = 402; -- id = 328
SELECT * FROM eco_prestacio_reserva WHERE prestacio_id = 328;

-------------------------------------------------------------------
-- Expeciente "00002/2019/359"
-------------------------------------------------------------------
SELECT * FROM expedient_prestacio WHERE numero_expedient = '00002/2019/359'; -- id = 567, persona = 502300, 2019-12-09 13:48:22
SELECT * FROM prestacio WHERE expedient_prestacio_id = 567; -- id = 492
SELECT * FROM eco_prestacio_reserva WHERE prestacio_id = 492; -- id (477,478), reserva_id = 31
SELECT * FROM eco_reserva WHERE id = 31;
SELECT * FROM procediment_prestacio WHERE clau_interna = '00002/2019/359'; -- id = 571
-- Desde la app: 
-- 	expedient: 567
--		prodediment: 571
--		tramit: 72742
-- 	prestacio: 462
SELECT * FROM tramit_prestacio_crida_externa_his WHERE tramit_prestacio_id = 72742;
-- Entrada:
/*
{
  "expedientId" : 567,
  "procedimentId" : 571,
  "tramitId" : 72742,
  "dataAltaNomina" : null,
  "prestacions" : [ {
    "prestacioId" : 492,
    "periodes" : null,
    "resolucioPeriodes" : [ {
      "dataEfecteInicial" : "01/03/2020 00:00",
      "dataEfecteFinal" : null,
      "conceptes" : [ {
        "codiConcepte" : "00001",
        "quantitat" : 541.86
      } ],
      "efectesNomina" : null
    } ]
  } ]
}
*/
-- Salida:
/*
{
  "ciutadaId" : 502300,
  "expedientId" : 567,
  "procedimentId" : 571,
  "tramitId" : 72742,
  "nominaId" : null,
  "prestacions" : [ {
    "prestacioId" : 492,
    "periodes" : null,
    "resolucioPeriodes" : [ {
      "dataEfecteInicial" : "01/03/2020 00:00",
      "dataEfecteFinal" : null,
      "conceptes" : [ {
        "codiConcepte" : "00001",
        "quantitat" : 541.86
      } ],
      "efectesNomina" : [ {
        "dataEfecteInicial" : "01/03/2020 00:00",
        "dataEfecteFinal" : "01/03/2020 00:00",
        "codiTipusEfecteNomina" : "1",
        "codiTipusActivitatConcepte" : "00001"
      }, {
        "dataEfecteInicial" : "01/04/2020 00:00",
        "dataEfecteFinal" : null,
        "codiTipusEfecteNomina" : "6",
        "codiTipusActivitatConcepte" : "00001"
      } ]
    } ]
  } ],
  "resultat" : true,
  "codiResultat" : null,
  "properaLiquidacio" : null,
  "errors" : null,
  "importTotal" : 5418.599999999999
}
*/

SELECT * FROM identificador WHERE id = 502300; -- No existe
SELECT * FROM eco_nomina_persona WHERE persona_id = 502300; -- No existe!


-------------------------------------------------------------------
-- Expeciente "00002/2019/15"
-------------------------------------------------------------------
SELECT * FROM expedient_prestacio WHERE persona_id = 501342; -- "00002/2019/15", id = 61
SELECT * FROM prestacio WHERE expedient_prestacio_id = 61; -- id = 41, dret_id = 33
SELECT * FROM eco_prestacio_reserva WHERE prestacio_id = 41; -- id (119,120, 244), prestacio_id = 41, reserva_id = (26,31)
SELECT SUM(import_reservat) FROM eco_prestacio_reserva WHERE prestacio_id = 41; -- 1504.7999999999997
SELECT * FROM eco_reserva WHERE id IN (26, 31);
SELECT * FROM procediment_prestacio WHERE clau_interna = '00002/2019/15'; -- id = 41
SELECT * FROM eco_nomina WHERE id = 33;
SELECT * FROM eco_dret_reserva WHERE dret_id = 33;
SELECT * FROM tramit_prestacio_crida_externa_his WHERE tramit_prestacio_id =27520; -- Alta nómina, obtenido de las evidencias!!
SELECT * FROM eco_dret_teoric_detall WHERE dret_id = 33;
SELECT * FROM eco_dret_teoric WHERE dret_id = 33;

SELECT * FROM eco_reserva WHERE id IN (26, 31);
SELECT * FROM eco_partida_pressupostaria WHERE id IN (26, 31);

SELECT * FROM eco_efecte_moviment_nomina WHERE dret_id = 33
SELECT * FROM eco_activitat WHERE dret_id = 33;
SELECT * FROM eco_activitat_detall WHERE nomina_id = 33 ORDER BY data_efecte DESC;

SELECT * FROM eco_activitat_detall 
WHERE nomina_id = 33 AND rcd_crt_ts >= '2020-02-27' AND rcd_crt_ts < '2020-02-28'
ORDER BY data_efecte DESC;

SELECT * FROM eco_activitat_detall WHERE nomina_id = 33 AND rcd_crt_ts >= '2019-11-08' AND rcd_crt_ts < '2019-11-09';
SELECT * FROM eco_activitat_detall WHERE nomina_id = 33 AND rcd_crt_ts >= '2019-12-04' AND rcd_crt_ts < '2019-12-05';
SELECT * FROM eco_activitat_detall WHERE nomina_id = 33 AND rcd_crt_ts >= '2020-02-12' AND rcd_crt_ts < '2020-02-13';
SELECT * FROM eco_activitat_detall WHERE nomina_id = 33 AND rcd_crt_ts >= '2020-01-20' AND rcd_crt_ts < '2020-01-21';

SELECT DISTINCT rcd_crt_ts FROM eco_activitat_detall WHERE nomina_id = 33;

SELECT * FROM eco_dret_teoric WHERE dret_id = 33 ORDER BY data_efecte;
SELECT * FROM eco_dret_teoric_detall WHERE dret_id = 33 ORDER BY data_efecte

SELECT * FROM eco_activitat_detall WHERE nomina_id = 33 ORDER BY data_efecte;

-- Quadre activitat detall
select activitatd0_.id as col_0_0_, 
		 activitatd0_.nomina_id as col_1_0_, 
		 activitatd0_.data_efecte as col_2_0_, 
		 activitatd0_.quantitat as col_3_0_, 
		 activitatd0_.pagament_tipus_id as col_4_0_, 
		 efectemovi4_.id as col_5_0_, 
		 efectemovi4_.tipus_id as col_6_0_, 
		 efectemovi4_.import_actual as col_7_0_, 
		 efectemovi4_.import_anterior as col_8_0_, 
		 activitat1_.tipus_incidencia_id as col_9_0_ 
from eco_activitat_detall activitatd0_ 
	inner join eco_activitat activitat1_ on activitatd0_.activitat_id=activitat1_.id 
	inner join eco_moviment moviment2_ on activitat1_.moviment_id=moviment2_.id 
	inner join eco_moviment_detall movimentde3_ on moviment2_.id=movimentde3_.moviment_id 
	cross join eco_efecte_moviment_nomina efectemovi4_ 
where movimentde3_.id=efectemovi4_.moviment_detall_id 
  and activitatd0_.nomina_mensual_id=19 
  and efectemovi4_.data_efecte_inici<='2020-03-01T00:00' 
  and (efectemovi4_.data_efecte_fi is null or efectemovi4_.data_efecte_fi>=activitatd0_.data_efecte) 
  and efectemovi4_.data_efecte_inici<=activitatd0_.data_efecte
  AND activitatd0_.nomina_id = 33;
  
