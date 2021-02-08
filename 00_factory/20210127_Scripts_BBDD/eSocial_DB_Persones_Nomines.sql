---------------------------------------------------------------------------------------------------------------------
--  eSocial_DB_Quadre_Nomina.sql                                                                               
--	Recopilación de sentencias SQL asociadas a las Persones y las Nòmines.
-- 
--  Created by Gregorio Luque Serrano.                                                                             
--  Barcelona, January 28, 2020.                                                                                 
--  						  																					   								    
--  Last update: 19/01/2021
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--
-- INFORMACIO PERSONES I NOMINES
--
--    01. TIPUS IDENTIFICADORS
--    02. TIPUS ESTAT DRET
--    03. TIPUS ESTAT NOMINA
--    04. PERSONES AMB MES D'UN IDENTIFICADOR
--    05. PERSONES AMB MÉS D'UNA NÒMINA
--    06. INFORMACIO PERSONES AMB I SENSE NOMINA
--	  07. NOMINES EXISTENTS D'UN TIPUS I EN UN ESTAT EN PARTICULAR
--
---------------------------------------------------------------------------------------------------------------
--
-- [01] TIPUS IDENTIFICADORS
--
SELECT ti.id, ti.codi, lv.acronim, lvi.descripcio
FROM tipus_identificador ti	
	JOIN llistat_valors lv ON ti.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY ti.codi;
--
-- [02] TIPUS ESTAT DRET
--
SELECT eted.id, eted.codi, lv.acronim, lvi.descripcio
FROM eco_tipus_estat_dret eted	
	JOIN llistat_valors lv ON eted.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY eted.codi;
--
-- [03] TIPUS ESTAT NOMINA
--
SELECT een.id, een.codi, lv.acronim, lvi.descripcio
FROM eco_estat_nomina een	
	JOIN llistat_valors lv ON een.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY een.codi;
--
-- [04] PERSONES AMB MES D'UN IDENTIFICADOR 
--
SELECT ide.persona_id, COUNT(*) total FROM identificador ide 
GROUP BY ide.persona_id HAVING COUNT(*) > 1 ORDER BY ide.persona_id;
--
-- [05] PERSONES AMB MÉS D'UNA NÒMINA
--
SELECT enp.persona_id, COUNT(*) total FROM eco_nomina_persona enp
GROUP BY enp.persona_id HAVING COUNT(*) > 1 ORDER BY enp.persona_id;
--
-- [06] INFORMACIO PERSONES AMB I SENSE NOMINA
--
SELECT 
    per.id                                              AS "Id Persona",	
    per.actiu                                           AS "Actiu",
    per.nom || ' ' || per.cognom1 || ' ' || per.cognom2 AS "Nom i cognoms",	
    ide.valor                                           AS "Identificador",
    enp.nomina_id                                       AS "Id Nòmina",	
    (SELECT lvi.descripcio FROM eco_estat_nomina etn
     JOIN llistat_valors lv
        ON etn.llistat_valors_id = lv.id
     JOIN llistat_valors_idioma lvi
        ON lv.id = lvi.llistat_valors_id
     WHERE etn.id = ecn.estat_id)
    || ' [' || ecn.estat_id || ']'                      AS "Estat",
    lvi.descripcio || ' [' || etn.id || ']'             AS "T.Nòmina",
    ecn.data_alta_nomina                                AS "Alta",
    ecn.data_efecte_inici                               AS "Efecte Inici",
    ecn.data_efecte_fi                                  AS "Efecte Fi",	
    enp.dades_bancaries_id                              AS "Id Bancaries",
    dab.iban                                            AS "IBAN"
FROM persona per
	LEFT JOIN identificador ide ON ide.persona_id = per.id
	LEFT JOIN eco_nomina_persona enp ON enp.persona_id = per.id
	LEFT JOIN dades_bancaries dab ON enp.dades_bancaries_id = dab.id
	LEFT JOIN eco_nomina ecn ON enp.nomina_id = ecn.id
	LEFT JOIN eco_tipus_nomina etn ON etn.id = ecn.tipus_nomina_id
	LEFT JOIN llistat_valors lv ON etn.llistat_valors_id = lv.id
	left JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
WHERE enp.nomina_id IS NOT NULL
--WHERE enp.nomina_id IS NULL
--WHERE enp.persona_id = 501191
--WHERE enp.nomina_id = 1
ORDER BY per.id;
--
-- [07] NOMINES EXISTENTS D'UN TIPUS I EN UN ESTAT EN PARTICULAR
--
SELECT 
    per.id                                              AS "Id Persona",	
    per.actiu                                           AS "Actiu",
    per.nom || ' ' || per.cognom1 || ' ' || per.cognom2 AS "Nom i cognoms",	
    ide.valor                                           AS "Identificador",
    enp.nomina_id                                       AS "Id Nòmina",	
    (SELECT lvi.descripcio FROM eco_estat_nomina etn
     JOIN llistat_valors lv
        ON etn.llistat_valors_id = lv.id
     JOIN llistat_valors_idioma lvi
        ON lv.id = lvi.llistat_valors_id
     WHERE etn.id = ecn.estat_id)
    || ' [' || ecn.estat_id || ']'                      AS "Estat",
    lvi.descripcio || ' [' || etn.id || ']'             AS "T.Nòmina",
    ecn.data_alta_nomina                                AS "Alta",
    ecn.data_efecte_inici                               AS "Efecte Inici",
    ecn.data_efecte_fi                                  AS "Efecte Fi",	
    enp.dades_bancaries_id                              AS "Id Bancaries",
    dab.iban                                            AS "IBAN"
FROM persona per
	LEFT JOIN identificador ide ON ide.persona_id = per.id
	LEFT JOIN eco_nomina_persona enp ON enp.persona_id = per.id
	LEFT JOIN dades_bancaries dab ON enp.dades_bancaries_id = dab.id
	LEFT JOIN eco_nomina ecn ON enp.nomina_id = ecn.id
	LEFT JOIN eco_tipus_nomina etn ON etn.id = ecn.tipus_nomina_id
	LEFT JOIN llistat_valors lv ON etn.llistat_valors_id = lv.id
	left JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
WHERE enp.nomina_id IS NOT NULL
  AND etn.id = 2
  AND ecn.estat_id = 1
ORDER BY per.id;
