------------------------------------------------------------------------------------------------
-- VISUALIZADOR DE IMPORTES ECONÓMICOS
-- Script eSocial VIE gls - version 1.4b release 20200319 by DXC
-- 
-- INFO: https://www.postgresqltutorial.com/postgresql-stored-procedures/
------------------------------------------------------------------------------------------------
-------------------------------------------------------
-- Run-time configuration parameters:
-------------------------------------------------------
SET ROLE esocial;
SET search_path TO esocial;
-------------------------------------------------------
-- Precess configuration parameters:
-------------------------------------------------------
CREATE OR REPLACE FUNCTION getExpedients() RETURNS TEXT[] AS $$
DECLARE
	lstNumExpedients CONSTANT TEXT[] := '{00002/2019/89, 00002/2019/173, 00002/2019/192, 00002/2019/68, 00002/2019/38,
										  00002/2018/11, 00002/2018/1, 00002/2019/000, 00001/2020/10}';
BEGIN
	RETURN lstNumExpedients;
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------------------------------------------------------------------------
-- Functions:
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------
-- Function getInformacioBasica()
-------------------------------------------------------
CREATE OR REPLACE FUNCTION getInformacioBasica(numExpedient TEXT, INOUT expedientPrestacioId INTEGER, 
											   INOUT dretId INTEGER, INOUT nominaId INTEGER) AS $$
BEGIN
	SELECT pr.expedient_prestacio_id, pr.dret_id, np.nomina_id 
	INTO expedientPrestacioId, dretId, nominaId
	FROM prestacio pr LEFT JOIN expedient_prestacio ep ON pr.expedient_prestacio_id = ep.id
					  LEFT JOIN eco_nomina_persona np ON ep.persona_id = np.persona_id
	WHERE ep.numero_expedient = numExpedient;
	RETURN;
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Function getRegExpedientPrestacio()
-------------------------------------------------------
CREATE OR REPLACE FUNCTION getRegExpedientPrestacio() 
RETURNS SETOF expedient_prestacio AS 'SELECT * FROM expedient_prestacio;' 
LANGUAGE 'sql';
-------------------------------------------------------
-- Function getRegNomina()
-------------------------------------------------------
CREATE OR REPLACE FUNCTION getRegNomina() 
RETURNS SETOF eco_nomina AS 'SELECT * FROM eco_nomina;' 
LANGUAGE 'sql';
-------------------------------------------------------
-- Function getRegIdentificador()
-------------------------------------------------------
CREATE OR REPLACE FUNCTION getRegIdentificador() 
RETURNS SETOF identificador AS 'SELECT * FROM identificador;' 
LANGUAGE 'sql';
-------------------------------------------------------
-- Function getRegUltimaNominaMensual()
-------------------------------------------------------
CREATE OR REPLACE FUNCTION getRegUltimaNominaMensual() 
RETURNS SETOF eco_nomina_mensual AS 'SELECT * FROM eco_nomina_mensual;' 
LANGUAGE 'sql';
-------------------------------------------------------
-- Function getDescripcioTipusNomina()
-------------------------------------------------------
CREATE OR REPLACE FUNCTION getDescripcioTipusNomina(idTipus INTEGER) 
RETURNS TEXT AS $$
DECLARE
	colDescripcio TEXT;	
BEGIN
	SELECT lvi.descripcio INTO colDescripcio
	FROM eco_tipus_nomina tt	
		JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
		JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
	WHERE tt.id = idTipus;
	RETURN colDescripcio;
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Function getDescripcioEfecte()
-------------------------------------------------------
CREATE OR REPLACE FUNCTION getDescripcioEfecte(idTipus INTEGER) 
RETURNS TEXT AS $$
DECLARE
	colDescripcio TEXT;	
BEGIN
	SELECT lvi.descripcio INTO colDescripcio
	FROM eco_tipus_efecte_nomina tt	
		JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
		JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
	WHERE tt.id = idTipus;
	RETURN colDescripcio;
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Function getDescripcioEstatNomina()
-------------------------------------------------------
CREATE OR REPLACE FUNCTION getDescripcioEstatNomina(idTipus INTEGER) RETURNS TEXT AS $$
DECLARE
	colDescripcio TEXT;	
BEGIN
	SELECT lvi.descripcio INTO colDescripcio
	FROM eco_estat_nomina tt	
		JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
		JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
	WHERE tt.id = idTipus;
	RETURN colDescripcio;
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Function getDescripcioMotiuEstatNomina()
-------------------------------------------------------
CREATE OR REPLACE FUNCTION getDescripcioMotiuEstatNomina(idTipus INTEGER) RETURNS TEXT AS $$
DECLARE
	colDescripcio TEXT;	
BEGIN
	SELECT lvi.descripcio INTO colDescripcio
	FROM eco_motiu_estat_nomina tt	
		JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
		JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
	WHERE tt.id = idTipus;
	RETURN colDescripcio;
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Function verificarErrorsEfectes()
-------------------------------------------------------
CREATE OR REPLACE FUNCTION verificarErrorsEfectes(numTipusEfectes INTEGER[]) 
RETURNS BOOLEAN AS $$
DECLARE
	existError BOOLEAN := FALSE;	
BEGIN	
	RETURN existError;
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------------------------------------------------------------------------
-- Procedures:
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------
-- Procedure mostrarCapcaleraVIEgls()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarCapcaleraVIEgls() AS $$
BEGIN
	RAISE NOTICE '-----------------------------------------------------------------------------';
	RAISE NOTICE 'Script eSocial VIE gls - 1.0 release 20200318 by DXC';	
	RAISE NOTICE '';
	RAISE NOTICE '  Fecha ejecución: %', (SELECT (TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS')));
	RAISE NOTICE '  Total expedients a processar: %', array_length(getExpedients(), 1);
	RAISE NOTICE '-----------------------------------------------------------------------------';
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Procedure mostrarDadesExpedient()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarDadesExpedient(expedientPrestacioId INTEGER, 
										          dretId INTEGER, nominaId INTEGER) AS $$
DECLARE
	regExpedientPrestacio expedient_prestacio%ROWTYPE;
	regNomina eco_nomina%ROWTYPE;
	regIdentificador identificador%ROWTYPE;
	regNominaMensual eco_nomina_mensual%ROWTYPE;
BEGIN
	SELECT * INTO regExpedientPrestacio FROM getRegExpedientPrestacio() 
	WHERE id = expedientPrestacioId;
	SELECT * INTO regIdentificador FROM getRegIdentificador() 
	WHERE persona_id = regExpedientPrestacio.persona_id;
	SELECT * INTO regNomina FROM getRegNomina() WHERE id = nominaId;
	SELECT * INTO regNominaMensual FROM getRegUltimaNominaMensual() 
	WHERE tipus_nomina_id = regNomina.tipus_nomina_id ORDER BY data_nomina DESC LIMIT 1;
	RAISE NOTICE 'Num.Expedient...........: %', regExpedientPrestacio.numero_expedient;		
	RAISE NOTICE '  Expedient-Prestació...: %', regExpedientPrestacio.id;
	RAISE NOTICE '    Data alta...........: %', regExpedientPrestacio.data_alta;
	RAISE NOTICE '    Data efecte.........: %', regExpedientPrestacio.data_efecte;
	RAISE NOTICE '  Persona...............: %', regExpedientPrestacio.persona_id;	
	RAISE NOTICE '    Identificador.......: ''%''', regIdentificador.valor;
	IF (dretId IS NULL) THEN
		RAISE NOTICE '  Dret..................: No disposa de dret.';
	ELSE 
		RAISE NOTICE '  Dret..................: %', dretId;	
	END IF;
	IF (nominaId IS NULL) THEN 
		RAISE NOTICE '  Nòmina................: No disposa de nòmina.';
	ELSE 
		RAISE NOTICE '  Nòmina................: %', nominaId;		
		RAISE NOTICE '    Alta................: %', regNomina.data_alta_nomina;
		RAISE NOTICE '    Tipus...............: % - ''%''', regNomina.tipus_nomina_id, getDescripcioTipusNomina(regNomina.tipus_nomina_id);	
		RAISE NOTICE '    Primera execució....: %', regNomina.data_primera_execucio;
		RAISE NOTICE '    Efecte inici........: %', regNomina.data_efecte_inici;
		RAISE NOTICE '    Efecte fi...........: %', regNomina.data_efecte_fi;
		RAISE NOTICE '    Estat...............: % - ''%''', regNomina.estat_id, getDescripcioEstatNomina(regNomina.estat_id);	
		RAISE NOTICE '    Motiu estat.........: % - ''%''', regNomina.estat_motiu_id, getDescripcioMotiuEstatNomina(regNomina.estat_motiu_id);	
		RAISE NOTICE '    Data estat..........: %', regNomina.data_estat;
		RAISE NOTICE '  Última nòmina.mensual.: %', regNominaMensual.id;	
		RAISE NOTICE '    Data................: %', regNominaMensual.data_nomina;
		RAISE NOTICE '    Data generació......: %', regNominaMensual.data_inici_generacio;
		RAISE NOTICE '    Estat...............: ''%''', regNominaMensual.estat;
	END IF;
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Procedure mostrarEfectes()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarEfectes(dretId INTEGER) AS $$
DECLARE
	cur_efectes CURSOR(p_idDret INTEGER) FOR
		SELECT * FROM eco_efecte_moviment_nomina WHERE dret_id = p_idDret 
		ORDER BY data_efecte_inici;
	regEfecte eco_efecte_moviment_nomina%ROWTYPE;
	dataFi TEXT;
	importAnterior TEXT;
BEGIN
	RAISE NOTICE '  Efectes:';
	OPEN cur_efectes(dretId);   
	LOOP	
	  FETCH cur_efectes INTO regEfecte;	
	  EXIT WHEN NOT FOUND;
		IF (regEfecte.data_efecte_fi IS NULL) THEN
			dataFi = RPAD('<NULL>', 10, ' ');
		ELSE		
			dataFi = TO_CHAR(regEfecte.data_efecte_fi,'YYYY-MM-DD');
		END IF;		
		IF (regEfecte.import_anterior IS NULL) THEN
			importAnterior = LPAD('<NULL>', 9, ' ');
		ELSE
			IF (regEfecte.import_anterior  = 0) THEN
				importAnterior = LPAD('0.00', 9, ' ');
			ELSE
				importAnterior = LPAD(TO_CHAR(regEfecte.import_anterior, '9999.99'), 9, ' ');			
			END IF;
		END IF;		
		RAISE NOTICE '   % - % - % - % - % - %', 
			TO_CHAR(regEfecte.id, 'fm00000'), 
			TO_CHAR(regEfecte.tipus_id, 'fm00'), 
			TO_CHAR(regEfecte.data_efecte_inici,'YYYY-MM-DD'),
			dataFi,
			LPAD(TO_CHAR(regEfecte.import_actual, '9999.99'), 9, ' '),
			importAnterior;
	END LOOP;
	CLOSE cur_efectes;
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Procedure mostrarSimulacioEfectes()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarSimulacioEfectes(dretId INTEGER) AS $$
DECLARE	
	cur_efectes CURSOR(p_idDret INTEGER, p_dataInici DATE) FOR
		SELECT * FROM eco_efecte_moviment_nomina WHERE dret_id = p_idDret 
		AND TO_CHAR(data_efecte_inici, 'YYYY-MM-DD') = TO_CHAR(p_dataInici, 'YYYY-MM-DD')
		AND tipus_id IN (1, 2, 3, 4, 5, 6, 13, 14, 15, 16, 19, 20)
		ORDER BY data_efecte_inici;
	regEfecte 	 eco_efecte_moviment_nomina%ROWTYPE := NULL;
	regEfecteAnt eco_efecte_moviment_nomina%ROWTYPE := NULL;	
	tipusId			eco_efecte_moviment_nomina.tipus_id%TYPE;
	-- Codificació array "existEfecte":
	--								
	--		Array
	--		Index	Id	Descripció
	--		-----	--	-------------------------------------
	--			1	1	Alta
	--			2	2	Rehabilitació
	--			3	3	Baixa
	--			4	4	Alta diferida
	--			5	5	Continuació alta diferida
	--			6	6	Continuació alta
	--			7	13	Rehabilitació diferida
	--			8	14	Continuació rehabilitació diferida
	--			9	15	Continuació rehabilitació
	--		   10	16	Continuació baixa
	--		   11	19	Modificació
	--		   12	20	Continuació modificació	
	--
	numTipusEfectes		INTEGER[12];
	existError			BOOLEAN; 					
	missatgeError		TEXT;	
	dataInici			DATE;
	dataUltimPeriode	DATE := NULL;
	numTotalEfectos   	INTEGER;
	counter 		  	INTEGER := 0;
	importTotal 	  	DECIMAL := 0;
	importEfecte		DECIMAL;
	listIdsEfectes		TEXT;	
BEGIN
	RAISE NOTICE '  Simulació periodes Efectes:';	
	-- Data efecte inicial:
	SELECT data_efecte_inici INTO dataInici
	FROM eco_efecte_moviment_nomina WHERE dret_id = dretId 
	AND tipus_id IN (1, 2, 3, 4, 5, 6, 13, 14, 15, 16, 19, 20) ORDER BY data_efecte_inici;
	-- Nombre total de Efectes:
	SELECT COUNT(*) INTO numTotalEfectos FROM eco_efecte_moviment_nomina 
	WHERE dret_id = dretId AND tipus_id IN (1, 2, 3, 4, 5, 6, 13, 14, 15, 16, 19, 20);	
	-- Flag error de inchorència
	existError := FALSE;
	-- Iterem els efectes:
	WHILE (counter < numTotalEfectos) OR existError LOOP	  	  
	  -- Iterem tots els efectes trobats per una mateixa data:	
	  regEfecteAnt := NULL;	  
	  OPEN cur_efectes(dretId, dataInici);   
 	  LOOP	
		FETCH cur_efectes INTO regEfecte;	
		EXIT WHEN NOT FOUND;
		counter := counter + 1;				
		IF (dataUltimPeriode IS NOT NULL) THEN
			-- Afegim els períodes fins al inici del següent Efecte:
			WHILE regEfecte.data_efecte_inici > dataUltimPeriode LOOP
				SELECT dataUltimPeriode + (1 * INTERVAL '1 month') INTO dataUltimPeriode;
				RAISE NOTICE '    % - % - [%]',(SELECT TO_CHAR(dataUltimPeriode,'YYYY-MM-DD')),
											   (SELECT LPAD(TO_CHAR(importEfecte, '99999.99'), 9,' ')),
											   listIdsEfectes;
			END LOOP;
			importEfecte := 0;
			listIdsEfectes := '';
			dataUltimPeriode := NULL;
		END IF;		
		tipusId := regEfecte.tipus_id;
		IF (tipusId <> 3 OR tipusId <> 16) THEN
			-- No és Baixa ni Continuació de Baixa:
			IF (regEfecteAnt IS NULL) THEN
				importEfecte := regEfecte.import_actual;
				importTotal := importTotal + importEfecte;
				listIdsEfectes := TO_CHAR(regEfecte.id, 'fm00000');				
			ELSE
				IF (regEfecte.import_actual > regEfecteAnt.import_actual) THEN					
					importEfecte := regEfecte.import_actual;
					importTotal := importTotal + (regEfecte.import_actual - importEfecte);
					listIdsEfectes := listIdsEfectes || ', ' || TO_CHAR(regEfecte.id, 'fm00000');
				END IF;
			END IF;
		END IF;						
		CASE (tipusId)			
			WHEN 1  THEN numTipusEfectes[1]  := numTipusEfectes[1] + 1;  -- Alta
			WHEN 2  THEN numTipusEfectes[2]  := numTipusEfectes[2] + 1;  -- Rehabilitació
			WHEN 3  THEN numTipusEfectes[3]  := numTipusEfectes[3] + 1;  -- Baixa
			WHEN 4  THEN numTipusEfectes[4]  := numTipusEfectes[4] + 1;  -- Alta diferida
			WHEN 5  THEN numTipusEfectes[5]  := numTipusEfectes[5] + 1;  -- Continuació alta diferida
			WHEN 6  THEN numTipusEfectes[6]  := numTipusEfectes[6] + 1;  -- Continuació alta
			WHEN 13 THEN numTipusEfectes[7]  := numTipusEfectes[7] + 1;  -- Rehabilitació diferida
			WHEN 14 THEN numTipusEfectes[8]  := numTipusEfectes[8] + 1;  -- Continuació rehabilitació diferida
			WHEN 15 THEN numTipusEfectes[9]  := numTipusEfectes[9] + 1;  -- Continuació rehabilitació
			WHEN 16 THEN numTipusEfectes[10] := numTipusEfectes[10] + 1; -- Continuació baixa
			WHEN 19 THEN numTipusEfectes[11] := numTipusEfectes[11] + 1; -- Modificació
			WHEN 20 THEN numTipusEfectes[12] := numTipusEfectes[12] + 1; -- Continuació modificació
		END	CASE;	
		regEfecteAnt := regEfecte;		
	  END LOOP;	
	  CLOSE cur_efectes;
	  existError := verificarErrorsEfectes(numTipusEfectes);	  	  
	  IF (regEfecteAnt IS NULL) THEN
		SELECT dataInici + (1 * INTERVAL '1 month') INTO dataInici;
	  ELSE
		RAISE NOTICE '    % - % - [%]',(SELECT TO_CHAR(regEfecteAnt.data_efecte_inici,'YYYY-MM-DD')),
									   (SELECT LPAD(TO_CHAR(importEfecte, '99999.99'), 9,' ')),
									   listIdsEfectes;
		SELECT regEfecteAnt.data_efecte_inici + (1 * INTERVAL '1 month') INTO dataUltimPeriode;
		dataInici := dataUltimPeriode;
	  END IF;	  
	END LOOP;		
	RAISE NOTICE '    Total%: %', REPEAT('.', 6), LPAD(TO_CHAR(importTotal, '99999.99'), 9,' ');
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Procedure mostrarActivitats()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarActivitats(dretId INTEGER) AS $$
DECLARE
	cur_activitats CURSOR(p_idDret INTEGER) FOR
		SELECT * FROM eco_activitat WHERE dret_id = p_idDret ORDER BY data_efecte_inicial;		
	regActivitat eco_activitat%ROWTYPE;
	dataDarreraExecucio	TEXT;
	dataEfecteFinal TEXT;
BEGIN
	RAISE NOTICE '  Activitats:';
	OPEN cur_activitats(dretId);   
	LOOP	
	  FETCH cur_activitats INTO regActivitat;	
	  EXIT WHEN NOT FOUND;
		dataDarreraExecucio := TO_CHAR(regActivitat.data_darrera_execucio,'YYYY-MM-DD');
		IF (dataDarreraExecucio IS NULL) THEN
			dataDarreraExecucio = RPAD('<NULL>', 10, ' ');		
		END IF;
		dataEfecteFinal = TO_CHAR(regActivitat.data_efecte_final,'YYYY-MM-DD');
		IF (dataEfecteFinal IS NULL) THEN
			dataEfecteFinal = RPAD('<NULL>', 10, ' ');
		END IF;
		RAISE NOTICE '   % - % - % - % - % - % - %', TO_CHAR(regActivitat.id, 'fm00000'),
												     regActivitat.estat_activitat,
													 dataDarreraExecucio,
													 TO_CHAR(regActivitat.data_efecte_inicial,'YYYY-MM-DD'),
													 dataEfecteFinal,
													 LPAD(TO_CHAR(regActivitat.quantitat, '9999.99'), 9,' '),
													 TO_CHAR(regActivitat.concepte_id, 'fm00');
	END LOOP;
	CLOSE cur_activitats;
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Procedure mostrarActivitatsDetall()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarActivitatsDetall(nominaId INTEGER) AS $$
DECLARE
	cur_activitatsDetall CURSOR(p_idNomina INTEGER) FOR
		SELECT * FROM eco_activitat_detall WHERE nomina_id = p_idNomina 
		ORDER BY data_efecte, data_execucio;		
	regActivitatDetall eco_activitat_detall%ROWTYPE;
	dataExecucio TEXT;	
BEGIN
	RAISE NOTICE '  Activitats Detall:';
	OPEN cur_activitatsDetall(nominaId);   
	LOOP	
	  FETCH cur_activitatsDetall INTO regActivitatDetall;	
	  EXIT WHEN NOT FOUND;
		dataExecucio := TO_CHAR(regActivitatDetall.data_execucio,'YYYY-MM-DD');
		IF (dataExecucio IS NULL) THEN
			dataExecucio = RPAD('<NULL>', 10, ' ');		
		END IF;		
		RAISE NOTICE '   % - % - % - % - % - % - % - % - %', TO_CHAR(regActivitatDetall.id, 'fm00000'),
													 TO_CHAR(regActivitatDetall.activitat_id, 'fm00000'),
													 dataExecucio,
													 TO_CHAR(regActivitatDetall.data_efecte,'YYYY-MM-DD'),
												     LPAD(TO_CHAR(regActivitatDetall.quantitat, '9999.99'), 9,' '),
													 TO_CHAR(regActivitatDetall.nomina_mensual_id, 'fm000'),
													 TO_CHAR(regActivitatDetall.concepte_id, 'fm00'),
													 regActivitatDetall.pagament_tipus_id, 
													 regActivitatDetall.pagament_modalitat_id;
	END LOOP;
	CLOSE cur_activitatsDetall;
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Procedure mostrarSumImportsActivitats()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarSumImportsActivitats(nominaId INTEGER, dataUltNomina DATE) AS $$
DECLARE	
	importTotal DECIMAL;
	importFins 	DECIMAL;
BEGIN		
	-- Activitat Detall:
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_activitat_detall WHERE nomina_id = nominaId) a1,
		 (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_activitat_detall WHERE nomina_id = nominaId 
		   AND TO_CHAR(data_efecte,'YYYY-MM-DD') <= TO_CHAR(dataUltNomina,'YYYY-MM-DD')) a2;	
	RAISE NOTICE '   Activitat Detall.....: % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
													LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' ');	
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Procedure mostrarSumImportsDretsTeorics()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarSumImportsDretsTeorics(dretId INTEGER, dataUltNomina DATE) AS $$
DECLARE	
	importTotal DECIMAL;
	importFins 	DECIMAL;
BEGIN		
	-- Imports Dret Teòrics:
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_dret_teoric WHERE dret_id = dretId) a1,
		 (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
	      FROM eco_dret_teoric WHERE dret_id = dretId 
		   AND TO_CHAR(data_efecte,'YYYY-MM-DD') <= TO_CHAR(dataUltNomina,'YYYY-MM-DD')) a2;
	RAISE NOTICE '   Dret Teòric..........: % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
													LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' ');
	-- Imports Dret Teòrics Detall:
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_dret_teoric_detall WHERE dret_id = dretId) a1,
		 (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_dret_teoric_detall WHERE dret_id = dretId 
		   AND TO_CHAR(data_efecte,'YYYY-MM-DD') <= TO_CHAR(dataUltNomina,'YYYY-MM-DD')) a2;
	RAISE NOTICE '   Dret Teòric Detall...: % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
													LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' ');
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Procedure mostrarSumImportsDretsTeorics()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarSumImportsPercebuts(nominaId INTEGER, dataUltNomina DATE) AS $$
DECLARE	
	importTotal DECIMAL;
	importFins 	DECIMAL;
BEGIN		
	-- Imports Percebuts:
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(import_percebut, 0)) AS DECIMAL),2)
		  FROM eco_percebut WHERE nomina_id = nominaId) a1,
		 (SELECT ROUND(CAST(SUM(COALESCE(import_percebut, 0)) AS DECIMAL),2)
		  FROM eco_percebut WHERE nomina_id = nominaId 
		   AND TO_CHAR(data_efecte,'YYYY-MM-DD') <= TO_CHAR(dataUltNomina,'YYYY-MM-DD')) a2;	
	RAISE NOTICE '   Percebut.............: % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
													LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' ');
	-- Imports Percebuts Detall:
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_percebut_detall WHERE nomina_id = nominaId) a1,
		  (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		   FROM eco_percebut_detall	WHERE nomina_id = nominaId 
		    AND TO_CHAR(data_efecte,'YYYY-MM-DD') <= TO_CHAR(dataUltNomina,'YYYY-MM-DD')) a2;
	RAISE NOTICE '   Percebut Detall......: % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
													LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' ');
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Procedure mostrarSumImportsOrdenacioPagament()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarSumImportsOrdenacioPagament(nominaId INTEGER, ultimaNomMensualId INTEGER) AS $$
DECLARE	
	importTotal DECIMAL;
	importFins 	DECIMAL;
BEGIN		
	-- Imports Ordenacions Pagament:
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_ordenacio_pagament WHERE nomina_id = nominaId) a1,
		 (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_ordenacio_pagament WHERE nomina_id = nominaId 
		   AND nomina_mensual_id <= ultimaNomMensualId) a2;	
	RAISE NOTICE '   Ordenació Pagament...: % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
													LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' ');
	-- Imports Ordenacions Pagament Detall:	
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_ordenacio_pagament_detall WHERE nomina_id = nominaId) a1,
		 (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_ordenacio_pagament_detall WHERE nomina_id = nominaId 		  
		   AND nomina_mensual_id <= ultimaNomMensualId) sumaFinsData;		
	RAISE NOTICE '   Ord.Pagament Detall..: % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
													LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' ');
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Procedure mostrarSumImportsLiquidats()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarSumImportsLiquidats(nominaId INTEGER, dataUltNomina DATE) AS $$
DECLARE	
	importTotal DECIMAL;
	importFins 	DECIMAL;
BEGIN		
	-- Liquidats:
	SELECT *
	FROM (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_liquidat WHERE dret_id = nominaId) a1,
		 (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_liquidat	WHERE dret_id = nominaId 
		   AND TO_CHAR(data_efecte,'YYYY-MM-DD') <= TO_CHAR(dataUltNomina,'YYYY-MM-DD')) a2;		
	RAISE NOTICE '   Liquidat.............: % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
													LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' ');	
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Procedure mostrarSumImportsTaules()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarTotalsImportsTaules(dretId INTEGER, nominaId INTEGER) AS $$
DECLARE
	regNomina		 eco_nomina%ROWTYPE;
	regNominaMensual eco_nomina_mensual%ROWTYPE;
BEGIN	
	SELECT * INTO regNomina FROM getRegNomina() WHERE id = nominaId;
	SELECT * INTO regNominaMensual FROM getRegUltimaNominaMensual() 
	WHERE tipus_nomina_id = regNomina.tipus_nomina_id ORDER BY data_nomina DESC LIMIT 1;	
	RAISE NOTICE '  Totals imports taules:';
	CALL mostrarSumImportsActivitats(nominaId, regNominaMensual.data_nomina);
	CALL mostrarSumImportsDretsTeorics(dretId, regNominaMensual.data_nomina);
	CALL mostrarSumImportsPercebuts(nominaId, regNominaMensual.data_nomina);
	CALL mostrarSumImportsOrdenacioPagament(nominaId, regNominaMensual.id);
	CALL mostrarSumImportsLiquidats(nominaId, regNominaMensual.data_nomina);
END; $$
LANGUAGE plpgsql;
-------------------------------------------------------
-- Procedure main block VIEgls
-------------------------------------------------------
DO $$ 
DECLARE  	
	-- Parameters:	
	generateCSVFiles CONSTANT BOOLEAN := FALSE;
	basePathCSVFiles CONSTANT TEXT 	  := 'C:/gluques/';
	-- Variables:
	lstNumExpedients 		TEXT[];
	expedientPrestacioId	INTEGER;
	dretId 					INTEGER;	
	nominaId 				INTEGER;		
BEGIN 		
	CALL mostrarCapcaleraVIEgls();
	lstNumExpedients := getExpedients();
	FOR counter IN 1..array_length(lstNumExpedients, 1) LOOP		
		SELECT * INTO expedientPrestacioId, dretId, nominaId 
		FROM getInformacioBasica(lstNumExpedients[counter], NULL, NULL, NULL);
		IF (expedientPrestacioId IS NOT NULL) THEN
			CALL mostrarDadesExpedient(expedientPrestacioId, dretId, nominaId);
			IF (dretID IS NOT NULL) THEN
				CALL mostrarEfectes(dretId);
				CALL mostrarSimulacioEfectes(dretId);
				CALL mostrarActivitats(dretId);
				CALL mostrarActivitatsDetall(nominaId);
				CALL mostrarTotalsImportsTaules(dretId, nominaId);
			END IF;
		ELSE
			RAISE NOTICE 'Num.Expedient...........: %', lstNumExpedients[counter];		
			RAISE NOTICE '  Informació............: ATENCIÓ! L''Expedient indicat no existeix.';
		END IF;
		RAISE NOTICE '-----------------------------------------------------------------------------';
	END LOOP;		
END $$;
