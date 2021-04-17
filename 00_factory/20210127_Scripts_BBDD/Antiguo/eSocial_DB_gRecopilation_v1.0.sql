---------------------------------------------------------------------------------------------------------------------
-- eSocial_DB_gRecopilation_v1_0.sql                                                                               
--	Recopilación de sentencias SQL para eSocial                      											   				 
--  						  																					   									 
--																						   						   								 
--  Created by Gregorio Luque Serrano.                                                                             
--  Barcelona, september 28, 2020.                                                                                 
--  						  																					   								    
--  Last update: 10/11/2020  						  															   
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
-- ÍNDICE
---------------------------------------------------------------------------------------------------------------------
--
-- 05. PAGO DE NÒMINA MENSUAL	[10/11/2020 - TERMINAR DE ORGANIZAR]
--
--		05.01. NOMINAS CANDIDATAS NOMINA MENSUAL
--    05.02. NOMINAS PRIMER FILTRO
-- 	05.03. NOMINAS EN CONTROL DE ERRORES
--		05.04. NOMINAS CON PAGOS
--		05.05. NOMINAS SEGUNDO FILTRO
--
-- 06. PRESUPUESTOS Y RESERVAS
--
--		06.01. CONVOCATORIA, BOSSA, PARTIDA I RESERVA PARA UN EJERCICIO
--
-- 07. ACTUACIO NOMINA
--
--		07.01. 
--
-- ANEXO. PROCESSOS DIVERSOS [10/11/2020 - TERMINAR DE ORGANIZAR]
--
--      A.01. CREAR DCR PER NOU ERROR
-- 
--
---------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
--
-- 05. PAGO DE NÒMINA MENSUAL																[10/11/2020 - TERMINAR DE ORGANIZAR]
--		05.01. CONTROL DE ERRORES
--		05.02. ORDENACIO DE PAGAMENTS

--		05.01. NÒMINES CANDIDATES NÒMINA MENSUAL
--    05.02. NÒMINES PRIMER FILTRE
-- 	05.03. NÒMINES EN CONTROL D'ERRORS
--		05.04. NÒMINES AMB PAGAMENTS 
--		05.05. NÒMINES SEGON FILTRE
--					  
---------------------------------------------------------------------------------------------------------------
--
-- [05.01] NÒMINES CANDIDATES NÒMINA MENSUAL
--			  NominaRepository.findByTipusNominaAndDataEfecteFiIsNullAndDataAltaNominaLessThan()
--
SELECT * 
FROM eco_nomina en 
	LEFT JOIN eco_tipus_nomina etn ON en.tipus_nomina_id = etn.id 
WHERE etn.id = 13 
  AND en.data_efecte_fi IS NULL 
  AND en.data_alta_nomina < '2020-10-14'
ORDER BY en.id;
--
-- [05.02] NÒMINES PRIMER FILTRE
--			  buscarActivitatsPerControlErrors()  
SELECT * 
FROM eco_nomina en 
	LEFT JOIN eco_tipus_nomina etn ON en.tipus_nomina_id = etn.id 
WHERE etn.id = 13 
  AND en.data_efecte_fi IS NULL 
  AND en.data_alta_nomina < '2020-10-14'
  AND en.estat_id NOT IN (2, 3)
  AND (EXTRACT(YEAR FROM en.data_efecte_inici) < 2020
   OR (EXTRACT(YEAR FROM en.data_efecte_inici) = 2020 AND EXTRACT(MONTH FROM en.data_efecte_inici) <= 10)) 
  AND (en.data_efecte_fi IS NULL OR en.data_efecte_fi <= '2020-10-14')
ORDER BY en.id;
--
-- [05.03] NÒMINES EN CONTROL D'ERRORS
--			  
SELECT * 
FROM eco_control_errors ece 
WHERE ece.nomina_mensual_historic_id IN (SELECT enmp.id 
													  FROM eco_nomina_mensual_procediment enmp
													  WHERE enmp.nomina_mensual_id = 50)
													  -- AND enmp.estat = 'ORDN')
ORDER BY ece.nomina_id;
--
-- [05.04] NÒMINES AMB PAGAMENTS
--
SELECT eop.* 
FROM eco_ordenacio_pagament eop 
 JOIN eco_nomina en ON eop.nomina_id = en.id
WHERE eop.nomina_mensual_id = 50
ORDER BY eop.nomina_id;
--
-- [05.05] NÒMINES SEGON FILTRE
--			  NominaRepository.findByTipusNominaAndWithoutErrorsAndNotPaid()
--
SELECT * 
FROM eco_nomina en 
WHERE en.tipus_nomina_id = 13
  AND en.id NOT IN (SELECT en1.id 
  						  FROM eco_ordenacio_pagament eop 
							 JOIN eco_nomina en1 ON eop.nomina_id = en1.id
  						  WHERE eop.nomina_mensual_id = 55)
  AND (SELECT COUNT(ece.id)
  		 FROM eco_control_errors ece 
			JOIN eco_nomina en2 ON ece.nomina_id = en2.id
  		 WHERE en2.id = en.id 
			AND ece.nomina_mensual_historic_id = (SELECT enmp.id 
															  FROM eco_nomina_mensual_procediment enmp
															  WHERE enmp.nomina_mensual_id = 55 
															    AND enmp.estat = 'ORDN')) = 0
ORDER BY en.id;
---------------------------------------------------------------------------------------------------------------
--
-- 06. PRESUPUESTOS Y RESERVAS
--
--		06.01. CONVOCATORIA, BOSSA, PARTIDA I RESERVA PARA UN EJERCICIO
--					  
---------------------------------------------------------------------------------------------------------------
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

--DELETE FROM eco_reserva WHERE id IN (37, 38);
--DELETE FROM eco_partida_pressupostaria WHERE id IN (37, 38);
--DELETE FROM eco_bossa_pressupostaria WHERE id = 31;
--DELETE FROM eco_convocatoria WHERE id = 31;

---------------------------------------------------------------------------------------------------------------
--
-- 07. ACTUACIO NOMINA
--
--		07.01. LLISTAT D'ERRORS
--					  
---------------------------------------------------------------------------------------------------------------
--
-- [07.01] LLISTAT D'ERRORS
--
-- 00078 - NOMINA_MENSUAL_EN_PROCES_CODI
--			  OperacioNominaAbstract.executarOperacioNomina()
--			  GestioActuacioNominaBusiness.crearResolucioEconomicaAmbEfectes()
--			  ReservaProjeccioBusiness.callPrestacioReservaAndSimulacio()
--			  ResolucioEconomicaBusiness.makeResolucioEconomica()
--			  
-- 00079 - EFECTES_NOMINA_INCOHERENTS
--			  OperacioNominaAbstract.executarOperacioNomina()
--			  GestioActuacioNominaBusiness.validarEfectesNominaPerPrestacio()
--			  GestioActuacioNominaBusiness.validarResolucioPeriode()
--
-- 00080 - NO_EXISTEIX_PARTIDA_PER_EXERCICI
--			  OperacioNominaAbstract.executarOperacioNomina()
--			  ReservaProjeccioBusiness.callPrestacioReservaAndSimulacio()
--
--	00084 - NO_COINCIDEIX_PARTIDA_PRESSUPOSTARIA_PROPOSTA_AMB_RESOLUCIO
--			  OperacioNominaAbstract.executarOperacioNomina()
--			  GestioActuacioNominaBusiness.preparacioEconomica()
--

--------------------------------------------------------------------------------------
-- ANEXO. PROCESSOS DIVERSOS							  [10/11/2020 - TERMINAR DE ORGANIZAR]
--
--      A.01. CREAR DCR PER NOU ERROR
--
--------------------------------------------------------------------------------------
--
-- [A.01] CREAR DCR PER NOU ERROR
--			 
--			[IMPORTANTE] Totes les consultes descrites s'han de fer en entorn DEV.
--
-- [A.01.01] TIPUS ERROR 
--           Taula on es registren els nous errors, per la qual cosa haurem de crear
--			    un nou registre en aquesta taula:
--
--					INSERT INTO tipus_error (id, codi, Llistat_valors_id, tipologia_id)
--				
--				Nota: El "id" s'autogenera. 
--						Per derminar el valor de "codi" consultar	[A.01.02]. 
--						Per determinar el valor de "tipologia_id", consultar [A.01.03]. 
--						Per determinar el valor de "Llistat_valors_id", consultar [A.01.4].
--
SELECT * FROM tipus_error;
SELECT * FROM tipus_error te WHERE id = 251;
--
-- [A.01.02] TIPUS ERROR: CODI 
--           Mitjançant la següent SQL obtindrem l'últim registre creat que disposi d'una longitud
--				 de 5 dígits a la taula de Tipus Error; el nostre nou codi serà el valor de la columna 
--				 "codi" d'aquest registre sumant-li un. Per exemple, si ens retorna "00250", el nostre 
--				 codi serà: "tipus_error.codi = '00251'".
--
SELECT *
FROM  tipus_error te	
	JOIN llistat_valors lv ON te.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
WHERE length(te.codi) = 5
ORDER BY codi DESC LIMIT 1;
--
-- [A.01.03] TIPUS TIPOLOGIA ERROR
--           Taula on s'emmagatzemen totes les tipologies possibles d'errors.
--				 Tendremos que consultar esta tabla para informar el campo 
--				 "tipus_error.tipologia_id", que en este caso será tipo "Error",
--				 por lo que informaremos el campo con el valor "3".
-- 
SELECT tte.id, tte.codi, lv.acronim, lvi.descripcio
FROM  tipus_tipologia_error tte	
	JOIN llistat_valors lv ON tte.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY tte.codi;
--
-- [A.01.04] LLISTAT DE VALORS 
--				 Mitjançant aquesta taula associarem el nostre nou tipus d'error a un missatge en 
--				 particular i el vincularem a una agrupació de tipus de missatges en concret. Això 
--				 vol dir que haurem de crear un nou registre en aquesta taula:
--
--					INSERT INTO llistat_valors (id, llistat_valors_agrupacions_id, acronim, pare)
--
--				Nota: El "id" s'autogenera 
--  				   El valor de "acronim" serà el valor de "tipus_error.codi".
--						Per derminar el valor de "llistat_valors_agrupacions_id", consultar [A.01.07].
--						El valor de "pare" és per defecte NULL. 
--
SELECT * FROM llistat_valors;
SELECT * FROM llistat_valors
WHERE id = (SELECT llistat_valors_id FROM tipus_error WHERE id = 251);
--
-- [A.01.05] LLISTAT DE VALORS IDIOMA: MISSATGE D'ERROR 
--				 En aquesta taula és on es registra el missatge associat al nostre nou error,
--				 de manera que també haurem de crear un registre.
--
--					INSERT INTO llistat_valors_idioma (id, llistat_valors_id, idioma_id, descripcio)
--
--				Nota: el "id" s'autogenera, "llistat_valors_id" es correspon amb "llistat_valors.id",
--						el valor de "idioma_id" s'ha de determinar consultant [A.01.05] i el valor 
--						de "descripcio" serà el missatge associat al nostre nou error.
--
SELECT * FROM llistat_valors_idioma;

SELECT lvi.* FROM llistat_valors_idioma lvi
 JOIN llistat_valors lv ON lvi.llistat_valors_id = lv.id
 JOIN tipus_error te	ON lv.id = te.llistat_valors_id
WHERE te.id = 251;
--
-- [A.01.06] IDIOMA
--				 En aquesta taula es troba la llista d'idiomes disponibles per als nostres missatges.
--				 Tendremos que consultar esta tabla para determinar el idioma de nuestro mensaje, que 
--				 por defecto será Català, por lo que informaremos "llistat_valors_idioma.idioma_id"
--				 con el valor "1".
--
SELECT * FROM idioma;
--
-- [A.01.07] LLISTAT DE VALORS AGRUPACIONS I LLISTAT DE VALORS AGRUPACIONS IDIOMA
--			    En aquestes taules es defineixen els diferents grups de missatges i l'idioma
--				 associat als mateixos. Tendremos que consultarlas para determinar a qué tipo
--				 de agrupación pertenece nuestro nuevo mensaje. En el caso de los errores,
--				 por defecto establecemos para "llistat_valors.llistat_valors_agrupacions_id" 
--				 el valor "1058", pues se trata de la agrupación descrita como "Tipus Error".
--
SELECT * FROM llistat_valors_agrupacions; 
SELECT * FROM llistat_valors_agrupacions_idioma;

SELECT * FROM llistat_valors_agrupacions WHERE id = 1058; 
SELECT * FROM llistat_valors_agrupacions_idioma WHERE llistat_valors_agrupacions_id = 1058;

SELECT lva.* FROM llistat_valors_agrupacions lva
 JOIN llistat_valors lv ON lva.id = lv.llistat_valors_agrupacions_id
 JOIN tipus_error te	ON lv.id = te.llistat_valors_id
WHERE te.id = 251;

SELECT lvai.* FROM llistat_valors_agrupacions_idioma lvai
 JOIN llistat_valors_agrupacions lva ON lvai.llistat_valors_agrupacions_id = lva.id
 JOIN llistat_valors lv ON lva.id = lv.llistat_valors_agrupacions_id
 JOIN tipus_error te	ON lv.id = te.llistat_valors_id
WHERE te.id = 251;
--
-- [A.01.07] GENERACIO DE SCRIPTS
-- 			 Mitjançant el projecte "generador-scripts" generarem el DCR per a la creació d'el nou error.
--
--		Paso 1: Edita fitxer "/generador-scripts/inputFiles/jsonInputFile.json" i substituir el seu contingut
--				  pel següent, a continuació, hem de reemplaçar cada un dels paràmetres pels de l'
--				  nou error:
--
--					"usuario" i "tipustasca" no cal modificar-los.
--					"tasca": el codi de la tasca del JIRA.
--					"lldv": indica que es tracta de creació de registres de tipus llista de valors.
--					"description": aquesta és la descripció que s'emmagatzema en "registre_scripts".
--					"agrupacio": es correspon amb "llistat_valors_agrupacions.acronim".
--					"ca": es correspon amb "llistat_valors_agrupacions_idioma.descripcio".
--					"tipusde": es el nom de la taula afectada, en aquest cas, "tipus_error".
--					"valor": es correspon amb "tipus_error.codi".
--					"ca": es correspon amb "llistat_valors_idioma.descripcio".
--					"pare": es correspon amb "llistat_valors.pare"
/*
{
    "usuari":"GLS",
    "tasca":"9113",
    "tipustasca":"DES",
    "Scripts":
     [
        {
           "type":"lldv",
           "description":"Alta ERROR_EFECTE_BAIXA_PERIODE_INCORRECTE",
           "agrupacions":
           [                                 
                  {
                  "agrupacio":"TERRR",
                  "ca":"Tipus Error",
                  "tipusde": "tipus_error",
                  "valors":
                        [
                               { "valor":"00254","ca":"El període corresponent a l'efecte de baixa no és correcte o no s'ha informat.","pare":null}
                            
                        ]
                  }
           ]
        }
    ]            
}

*/
--		Paso 2: Creamos la carpeta "outputfiles" dentro de la raíz del proyecto y lo ejecutamos.
--				  Si todo es correcto, se nos habrá creado el script DCR en la carpeta creada.
--
/*
		INSERT INTO llistat_valors (id,llistat_valors_agrupacions_id, acronim, pare) 
        VALUES (12403,1058,'00254',null);

		INSERT INTO llistat_valors_idioma (llistat_valors_id,idioma_id,descripcio) 
        VALUES (12403,1,'El període corresponent a l''efecte de baixa no és correcte o no s''ha informat.');

		INSERT INTO tipus_error(id, llistat_valors_id, codi, tipologia_id) 
        VALUES	(254, 12403,'00254', 3);
        
   	NOTA: el campo "tipologia_id" lo he añadido manualmente pues el generador de script no lo adminte!!!
*/
--
-- [A.01.08] DATOS TIPUS ERROR EXISTENT
--	
SELECT ter.codi AS "Codi", 
		 ter.tipologia_id AS "Tipología",
		 lv.id AS "Id L.Valors", 		  
		 lv.acronim AS "Acronim", 
		 lvi.idioma_id AS "Idioma", 
		 lvi.descripcio AS "Descripció",
		 lva.id AS "Id Agrupació",
		 lva.acronim AS "Acronim Agrup.", 
		 lvai.idioma_id AS "Idioma Agrup.",
		 lvai.descripcio AS "Descripció Agrup."
FROM tipus_error ter
 JOIN llistat_valors lv ON ter.llistat_valors_id = lv.id
 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
 JOIN llistat_valors_agrupacions lva ON llistat_valors_agrupacions_id = lva.id
 JOIN llistat_valors_agrupacions_idioma lvai ON lva.id = lvai.llistat_valors_agrupacions_id
WHERE ter.id = 251;

--
-- eco_tipus_error_nomina [ORGANIZAR]
-- 
SELECT ten.codi AS "Codi",
		 lv.id AS "Id L.Valors", 		  
		 lv.acronim AS "Acronim", 
		 lvi.idioma_id AS "Idioma", 
		 lvi.descripcio AS "Descripció",
		 lva.id AS "Id Agrupació",
		 lva.acronim AS "Acronim Agrup.", 
		 lvai.idioma_id AS "Idioma Agrup.",
		 lvai.descripcio AS "Descripció Agrup."
FROM eco_tipus_error_nomina ten
 JOIN llistat_valors lv ON ten.llistat_valors_id = lv.id
 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
 JOIN llistat_valors_agrupacions lva ON llistat_valors_agrupacions_id = lva.id
 JOIN llistat_valors_agrupacions_idioma lvai ON lva.id = lvai.llistat_valors_agrupacions_id
WHERE ten.id = 32;



SELECT ten.codi AS "Codi",
		 lvi.descripcio AS "Descripció"
FROM eco_tipus_error_nomina ten
 JOIN llistat_valors lv ON ten.llistat_valors_id = lv.id
 JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
 JOIN llistat_valors_agrupacions lva ON llistat_valors_agrupacions_id = lva.id
 JOIN llistat_valors_agrupacions_idioma lvai ON lva.id = lvai.llistat_valors_agrupacions_id
WHERE ten.id = 32;


SELECT * FROM eco_control_errors
WHERE expedient_id IN (5590,1047,5491,5597)
ORDER BY id;

SELECT * FROM eco_dret_reserva 
WHERE dret_id IN (399,416,379,402)
ORDER BY dret_id, id;

SELECT * FROM eco_activitat_detall 
WHERE nomina_id IN (399,416,379,402)
ORDER BY nomina_id, id;




---------------------------------
-- PENDIENTE DE ORDENAR
---------------------------------
--
-- Se codifica:
--
--		NominaRepository.findByTipusNominaAndDataEfecteFiIsNullAndDataAltaNominaLessThan(TipusNomina tipusNomina,
--																													LocalDateTime dataIniciGeneracio)
-- Parámetros:
--
--		(1) tipusNomina			--> eco_nomina_mensual.tipus_nomina_id
--		(2) dataIniciGeneracio 	--> eco_nomina_mensual.data_inici_generacio
--
-- Se emplea:
--
-- 	[Caso 01] Al hacer clic sobre el botón "Iniciar el Control d'Errors:
--
--				- NominaMensualController.crearNominaMensual() 
--				- NominaMensualBusiness.crearNominaMensual()
--				- ControlErrorsAsinThreadBusiness.run()
--				- ControlErrorsBusiness.executaControlerrors()
--				- ControlErrorsBusiness.comprovarNominaSenseActivitat()
--
SELECT nom.*
FROM eco_nomina nom 
	LEFT OUTER JOIN eco_tipus_nomina etn ON nom.tipus_nomina_id = etn.id 
WHERE etn.id = 13 
  AND nom.data_efecte_fi IS NULL 
  AND nom.data_alta_nomina < '2020-10-20T17:30:23.385'       
ORDER BY nom.id;


--
-- Buscar el ID de un tipus d'error a partir de una parte de su descripción:
--
SELECT te.id, te.codi, lv.acronim, lvi.descripcio
FROM  eco_tipus_error_nomina te	
	JOIN llistat_valors lv ON te.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
WHERE POSITION('ordre de pagament es major' IN lvi.descripcio) > 0
ORDER BY te.codi;