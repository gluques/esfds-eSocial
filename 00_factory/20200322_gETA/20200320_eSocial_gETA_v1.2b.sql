---------------------------------------------------------------------------------------------------------------------
--	ECONOMIC TABLE ANALYZER - gETA 1.0 release 20200320															   --	
--  						  																					   --
--	Software for the analysis of economic data from the PostgreSQL eSocial database.							   --
--	Based on eSocial gVIE 4b.																			   		   --	
--																						   						   --	
--  Created by Gregorio Luque Serrano for DXC.	   								   		   © eSocial DXC Software  --
--  Barcelona, March 20, 2020.	   												   		   █║▌│█│║▌║││█║▌║▌║█║▌│█  --
---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------
-- Run-time configuration parameters:
-------------------------------------------------------
SET ROLE esocial;
SET search_path TO esocial;

-------------------------------------------------------
-- Process configuration parameters
-------------------------------------------------------
SET appParam.lstNumExpedients TO '{00001/2019/92, 00001/2019/75, 00001/2019/99, 00001/2019/23, 00006/2020/1009,
								   00002/2020/26, 00002/2020/45, 00002/2020/49, 00002/2020/34}';
								   
SET appParam.version TO '1.0 release 20200320';

---------------------------------------------------------------------------------------------------------
-- Functions:
---------------------------------------------------------------------------------------------------------
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

---------------------------------------------------------------------------------------------------------
-- Procedures:
---------------------------------------------------------------------------------------------------------
-------------------------------------------------------
-- Procedure mostrarLlistaExpedients()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarLlistaExpedients(lstNumExpedients TEXT[]) AS $$
DECLARE
	expedientsPerLinea CONSTANT INTEGER := 4;
	lineExpedients  TEXT := '';
	counter 		INTEGER;
	counterExp 		INTEGER := 1;
BEGIN	
	IF (array_length(lstNumExpedients, 1) > 0) THEN
		lineExpedients := LPAD(lstNumExpedients[1],14,' ');
		FOR counter IN 2..array_length(lstNumExpedients, 1) LOOP			
			IF (counterExp = expedientsPerLinea) THEN
				RAISE NOTICE '      %', lineExpedients;
				lineExpedients := '';
				counterExp:= 0;
			END IF;
			counterExp := counterExp + 1;
			IF (counterExp = 1) THEN
				lineExpedients := LPAD(lstNumExpedients[counter],14,' ');
			ELSE
				lineExpedients := lineExpedients || ', ' || LPAD(lstNumExpedients[counter],14,' ');
			END IF;			
		END LOOP;
		IF (lineExpedients <> '') THEN
			RAISE NOTICE '      %', lineExpedients;
		END IF;
	END IF;
END; $$
LANGUAGE plpgsql;

-------------------------------------------------------
-- Procedure mostrarCapcaleragETA()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarCapcaleragETA() AS $$
DECLARE
	lstNumExpedients TEXT[];
BEGIN
	lstNumExpedients = current_setting('appParam.lstNumExpedients')::TEXT[];
	RAISE NOTICE '-----------------------------------------------------------------------------';
	RAISE NOTICE ' Script eSocial gETA %', current_setting('appParam.version')::TEXT;	
	RAISE NOTICE '';
	RAISE NOTICE '  Data d''execució.......: %', (SELECT (TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS')));
	RAISE NOTICE '  Expedients a processar: %', array_length(lstNumExpedients, 1);
	RAISE NOTICE '';
	CALL mostrarLlistaExpedients(lstNumExpedients);
	RAISE NOTICE '';
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
		ORDER BY data_efecte_inici, moviment_detall_id;
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
		RAISE NOTICE '   % - % - % - % - % - % - %', 
			TO_CHAR(regEfecte.id, 'fm00000'), 
			TO_CHAR(regEfecte.moviment_detall_id, 'fm00000'), 
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
CREATE OR REPLACE PROCEDURE mostrarSimulacioEfectes(dretId INTEGER, nominaId INTEGER, INOUT importTotal DECIMAL) AS $$
DECLARE	
	cur_efectes CURSOR(p_idDret INTEGER, p_dataInici DATE) FOR
		SELECT * FROM eco_efecte_moviment_nomina WHERE dret_id = p_idDret 
		AND TO_CHAR(data_efecte_inici, 'YYYY-MM-DD') = TO_CHAR(p_dataInici, 'YYYY-MM-DD')
		AND tipus_id IN (1, 2, 3, 4, 5, 6, 13, 14, 15, 16, 19, 20)
		ORDER BY data_efecte_inici, moviment_detall_id;
	regEfecte 	 	 eco_efecte_moviment_nomina%ROWTYPE := NULL;
	regEfecteAnt 	 eco_efecte_moviment_nomina%ROWTYPE := NULL;
	regUltEfecte 	 eco_efecte_moviment_nomina%ROWTYPE := NULL;
	tipusId		 	 eco_efecte_moviment_nomina.tipus_id%TYPE;
	regNomina		 eco_nomina%ROWTYPE;
	regNominaMensual eco_nomina_mensual%ROWTYPE;
	counter 		 INTEGER;
	dataIniciPeriode DATE;
	dataSegPeriode	 TEXT;
	numTotalEfectos  INTEGER;	
	importUltEfecte	 DECIMAL;
	listIdsEfectes	 TEXT;	
	existError		 BOOLEAN;
BEGIN
	RAISE NOTICE '  Simulació periodes Efectes:';	
	-- Nombre total de Efectes:
	SELECT COUNT(*) INTO numTotalEfectos FROM eco_efecte_moviment_nomina 
	WHERE dret_id = dretId AND tipus_id IN (1, 2, 3, 4, 5, 6, 13, 14, 15, 16, 19, 20);
	IF (numTotalEfectos > 0) THEN
		-- Data efecte inicial:
		SELECT TO_CHAR(data_efecte_inici,'YYYY-MM-DD') INTO dataIniciPeriode
		FROM eco_efecte_moviment_nomina WHERE dret_id = dretId 
		AND tipus_id IN (1, 2, 3, 4, 5, 6, 13, 14, 15, 16, 19, 20) 
		ORDER BY data_efecte_inici LIMIT 1;
		-- Iterem tots els efectes:
		counter := 0;
		importTotal := 0;
		existError  := FALSE; 		
		WHILE (counter < numTotalEfectos) AND NOT existError LOOP
			-- Iterem tots els efectes trobats per una mateixa data conjuntament:	
			regEfecteAnt := NULL;
			OPEN cur_efectes(dretId, dataIniciPeriode);   
			LOOP	
				FETCH cur_efectes INTO regEfecte;	
				EXIT WHEN NOT FOUND;
				counter := counter + 1;	
				-- Comprovem l'últim Efecte processat:
				IF (NOT(regUltEfecte IS NULL)) THEN					
					dataSegPeriode := TO_CHAR(regUltEfecte.data_efecte_fi,'YYYY-MM-DD');
					-- Comprovem la data fi d'últim Efecte:
					IF (dataSegPeriode IS NULL) THEN						
						-- Afegim els períodes fins al inici del següent Efecte:
						SELECT TO_CHAR((regUltEfecte.data_efecte_inici + (1 * INTERVAL '1 month')),'YYYY-MM-DD') 
						INTO dataSegPeriode;												
						WHILE TO_CHAR(regEfecte.data_efecte_inici,'YYYY-MM-DD') > dataSegPeriode LOOP							
							RAISE NOTICE '    % - % - [%]',dataSegPeriode,
														   LPAD(TO_CHAR(importUltEfecte, '99999.99'), 9,' '),
														   listIdsEfectes;
							importTotal := importTotal + importUltEfecte;
							SELECT TO_CHAR(((TO_DATE(dataSegPeriode,'YYYY-MM-DD')) + (1 * INTERVAL '1 month')),'YYYY-MM-DD') 
							INTO dataSegPeriode;
						END LOOP;						
					ELSE
						-- Afegim els períodes fins al fi del anterior Efecte:
						SELECT TO_CHAR(regUltEfecte.data_efecte_inici + (1 * INTERVAL '1 month'),'YYYY-MM-DD') 
						INTO dataSegPeriode;
						WHILE TO_CHAR(regUltEfecte.data_efecte_fi,'YYYY-MM-DD') >= dataSegPeriode LOOP							
							RAISE NOTICE '    % - % - [%]',dataSegPeriode,
														   LPAD(TO_CHAR(importUltEfecte, '99999.99'), 9,' '),
														   listIdsEfectes;
							importTotal := importTotal + importUltEfecte;
							SELECT TO_CHAR(((TO_DATE(dataSegPeriode,'YYYY-MM-DD')) + (1 * INTERVAL '1 month')),'YYYY-MM-DD') 
							INTO dataSegPeriode;
						END LOOP;
						-- Comprovem la continuïtat temporal dels efectes:							
						IF (TO_CHAR(regEfecte.data_efecte_inici,'YYYY-MM-DD') <> dataSegPeriode) THEN
							RAISE NOTICE '    ERROR...............: l''efecte % no té continuïtat temporal amb l''efecte %',
										  regUltEfecte.id, regEfecte.id;
							existError := TRUE;						
						END IF;
					END IF;					
					regUltEfecte := NULL;
					importUltEfecte := 0;
					listIdsEfectes := '';										
				END IF;	
				IF (NOT existError) THEN
					tipusId := regEfecte.tipus_id;
					IF (tipusId = 3 OR tipusId = 16) THEN
						-- És Baixa o Continuació de Baixa:
						importUltEfecte := 0;					
					ELSE
						-- No és Baixa ni Continuació de Baixa:
						IF (regEfecteAnt IS NULL) THEN
							-- És el primer Efecte del període:
							importUltEfecte := regEfecte.import_actual;
							importTotal := importTotal + regEfecte.import_actual;						
						ELSE
							-- No es el primer Efecte del període; comprovem els imports:
							IF (regEfecte.import_actual <> regEfecteAnt.import_actual) THEN
								IF (regEfecte.import_actual > regEfecteAnt.import_actual) THEN
									importTotal := importTotal + (regEfecte.import_actual - regEfecteAnt.import_actual);
								ELSE 
									importTotal := importTotal - (regEfecteAnt.import_actual - regEfecte.import_actual);
								END IF;
								importUltEfecte := regEfecte.import_actual;
							END IF;
						END IF;
					END IF;
					IF (regEfecteAnt IS NULL) THEN
						listIdsEfectes := TO_CHAR(regEfecte.id, 'fm00000');
					ELSE
						listIdsEfectes := listIdsEfectes || ', ' || TO_CHAR(regEfecte.id, 'fm00000');
					END IF;				
					regEfecteAnt := regEfecte;
				END IF;
			END LOOP;
			CLOSE cur_efectes;
			IF (NOT(regEfecteAnt IS NULL)) THEN
				RAISE NOTICE '    % - % - [%]',TO_CHAR(regEfecteAnt.data_efecte_inici,'YYYY-MM-DD'),
											   LPAD(TO_CHAR(importUltEfecte, '99999.99'), 9,' '),
											   listIdsEfectes;		
				regUltEfecte := regEfecteAnt;					
			END IF;
			SELECT dataIniciPeriode + (1 * INTERVAL '1 month') INTO dataIniciPeriode;			
		END LOOP;
		IF (NOT existError) THEN
			-- Comprovem si cal completar períodes fins l'última nòmina mensual:
			SELECT * INTO regNomina FROM getRegNomina() WHERE id = nominaId;
			SELECT * INTO regNominaMensual FROM getRegUltimaNominaMensual() 
			WHERE tipus_nomina_id = regNomina.tipus_nomina_id ORDER BY data_nomina DESC LIMIT 1;			
			dataSegPeriode := TO_CHAR(regUltEfecte.data_efecte_inici,'YYYY-MM-DD');			
			IF (TO_CHAR(regNominaMensual.data_nomina,'YYYY-MM-DD') > dataSegPeriode) THEN											
				WHILE TO_CHAR(regNominaMensual.data_nomina,'YYYY-MM-DD') > dataSegPeriode LOOP										
					SELECT TO_CHAR(((TO_DATE(dataSegPeriode,'YYYY-MM-DD')) + (1 * INTERVAL '1 month')),'YYYY-MM-DD') 
					INTO dataSegPeriode;										
					RAISE NOTICE '    % - % - [%]',dataSegPeriode,
												   LPAD(TO_CHAR(importUltEfecte, '99999.99'), 9,' '),
												   listIdsEfectes;
					importTotal := importTotal + importUltEfecte;
				END LOOP;				
			END IF;			
			RAISE NOTICE '    Total%: %', REPEAT('.', 6), LPAD(TO_CHAR(importTotal, '99999.99'), 9,' ');
		END IF;
	ELSE
		RAISE NOTICE '    ERROR...............: l''expedient no disposa de cap efecte.';
		existError := TRUE;		
	END IF;	
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
CREATE OR REPLACE PROCEDURE mostrarSumImportsActivitats(nominaId INTEGER, dataUltNomina TIMESTAMP, importEfectesSimulats DECIMAL) AS $$
DECLARE	
	importTotal DECIMAL;
	importFins 	DECIMAL;
	diferencia	TEXT;
BEGIN		
	-- Activitat Detall:
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_activitat_detall WHERE nomina_id = nominaId) a1,
		 (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_activitat_detall WHERE nomina_id = nominaId 
		   AND TO_CHAR(data_efecte,'YYYY-MM-DD') <= TO_CHAR(dataUltNomina,'YYYY-MM-DD')) a2;	
	IF (importFins - importEfectesSimulats = 0) THEN
		diferencia := LPAD('0.00', 11, ' ');
	ELSE 
		diferencia := LPAD(TO_CHAR(importFins - importEfectesSimulats, '9999999.99'), 11, ' ');
	END IF;
	RAISE NOTICE '   Activitat Detall.....: % - % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
														LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' '),
														diferencia;	
END; $$
LANGUAGE plpgsql;

-------------------------------------------------------
-- Procedure mostrarSumImportsDretsTeorics()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarSumImportsDretsTeorics(dretId INTEGER, dataUltNomina TIMESTAMP, importEfectesSimulats DECIMAL) AS $$
DECLARE	
	importTotal DECIMAL;
	importFins 	DECIMAL;
	diferencia	TEXT;
BEGIN		
	-- Imports Dret Teòrics:
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_dret_teoric WHERE dret_id = dretId) a1,
		 (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
	      FROM eco_dret_teoric WHERE dret_id = dretId 
		   AND TO_CHAR(data_efecte,'YYYY-MM-DD') <= TO_CHAR(dataUltNomina,'YYYY-MM-DD')) a2;
	IF (importFins - importEfectesSimulats = 0) THEN
		diferencia := LPAD('0.00', 11, ' ');
	ELSE 
		diferencia := LPAD(TO_CHAR(importFins - importEfectesSimulats, '9999999.99'), 11, ' ');
	END IF;
	RAISE NOTICE '   Dret Teòric..........: % - % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
														LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' '),
														diferencia;
	-- Imports Dret Teòrics Detall:
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_dret_teoric_detall WHERE dret_id = dretId) a1,
		 (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_dret_teoric_detall WHERE dret_id = dretId 
		   AND TO_CHAR(data_efecte,'YYYY-MM-DD') <= TO_CHAR(dataUltNomina,'YYYY-MM-DD')) a2;
	IF (importFins - importEfectesSimulats = 0) THEN
		diferencia := LPAD('0.00', 11, ' ');
	ELSE 
		diferencia := LPAD(TO_CHAR(importFins - importEfectesSimulats, '9999999.99'), 11, ' ');
	END IF;
	RAISE NOTICE '   Dret Teòric Detall...: % - % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
														LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' '),
														diferencia;
END; $$
LANGUAGE plpgsql;

-------------------------------------------------------
-- Procedure mostrarSumImportsDretsTeorics()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarSumImportsPercebuts(nominaId INTEGER, dataUltNomina TIMESTAMP, importEfectesSimulats DECIMAL) AS $$
DECLARE	
	importTotal DECIMAL;
	importFins 	DECIMAL;
	diferencia	TEXT;
BEGIN		
	-- Imports Percebuts:
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(import_percebut, 0)) AS DECIMAL),2)
		  FROM eco_percebut WHERE nomina_id = nominaId) a1,
		 (SELECT ROUND(CAST(SUM(COALESCE(import_percebut, 0)) AS DECIMAL),2)
		  FROM eco_percebut WHERE nomina_id = nominaId 
		   AND TO_CHAR(data_efecte,'YYYY-MM-DD') <= TO_CHAR(dataUltNomina,'YYYY-MM-DD')) a2;	
	IF (importFins - importEfectesSimulats = 0) THEN
		diferencia := LPAD('0.00', 11, ' ');
	ELSE 
		diferencia := LPAD(TO_CHAR(importFins - importEfectesSimulats, '9999999.99'), 11, ' ');
	END IF;
	RAISE NOTICE '   Percebut.............: % - % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
														LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' '),
														diferencia;
	-- Imports Percebuts Detall:
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_percebut_detall WHERE nomina_id = nominaId) a1,
		  (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		   FROM eco_percebut_detall	WHERE nomina_id = nominaId 
		    AND TO_CHAR(data_efecte,'YYYY-MM-DD') <= TO_CHAR(dataUltNomina,'YYYY-MM-DD')) a2;
	IF (importFins - importEfectesSimulats = 0) THEN
		diferencia := LPAD('0.00', 11, ' ');
	ELSE 
		diferencia := LPAD(TO_CHAR(importFins - importEfectesSimulats, '9999999.99'), 11, ' ');
	END IF;
	RAISE NOTICE '   Percebut Detall......: % - % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
														LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' '),
														diferencia;
END; $$
LANGUAGE plpgsql;

-------------------------------------------------------
-- Procedure mostrarSumImportsOrdenacioPagament()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarSumImportsOrdenacioPagament(nominaId INTEGER, ultimaNomMensualId INTEGER, importEfectesSimulats DECIMAL) AS $$
DECLARE	
	importTotal DECIMAL;
	importFins 	DECIMAL;
	diferencia	TEXT;
BEGIN		
	-- Imports Ordenacions Pagament:
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_ordenacio_pagament WHERE nomina_id = nominaId) a1,
		 (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_ordenacio_pagament WHERE nomina_id = nominaId 
		   AND nomina_mensual_id <= ultimaNomMensualId) a2;
	IF (importFins - importEfectesSimulats = 0) THEN
		diferencia := LPAD('0.00', 11, ' ');
	ELSE 
		diferencia := LPAD(TO_CHAR(importFins - importEfectesSimulats, '9999999.99'), 11, ' ');
	END IF;
	RAISE NOTICE '   Ordenació Pagament...: % - % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
														LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' '),
														diferencia;
	-- Imports Ordenacions Pagament Detall:	
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_ordenacio_pagament_detall WHERE nomina_id = nominaId) a1,
		 (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_ordenacio_pagament_detall WHERE nomina_id = nominaId 		  
		   AND nomina_mensual_id <= ultimaNomMensualId) sumaFinsData;
	IF (importFins - importEfectesSimulats = 0) THEN
		diferencia := LPAD('0.00', 11, ' ');
	ELSE 
		diferencia := LPAD(TO_CHAR(importFins - importEfectesSimulats, '9999999.99'), 11, ' ');
	END IF;
	RAISE NOTICE '   Ord.Pagament Detall..: % - % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
														LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' '),
														diferencia;
END; $$
LANGUAGE plpgsql;

-------------------------------------------------------
-- Procedure mostrarSumImportsLiquidats()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarSumImportsLiquidats(nominaId INTEGER, dataUltNomina TIMESTAMP, importEfectesSimulats DECIMAL) AS $$
DECLARE	
	importTotal DECIMAL;
	importFins 	DECIMAL;
	diferencia	TEXT;
BEGIN		
	-- Liquidats:
	SELECT * INTO importTotal, importFins
	FROM (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_liquidat WHERE dret_id = nominaId) a1,
		 (SELECT ROUND(CAST(SUM(COALESCE(quantitat, 0)) AS DECIMAL),2)
		  FROM eco_liquidat	WHERE dret_id = nominaId 
		   AND TO_CHAR(data_efecte,'YYYY-MM-DD') <= TO_CHAR(dataUltNomina,'YYYY-MM-DD')) a2;
	IF (importFins - importEfectesSimulats = 0) THEN
		diferencia := LPAD('0.00', 11, ' ');
	ELSE 
		diferencia := LPAD(TO_CHAR(importFins - importEfectesSimulats, '9999999.99'), 11, ' ');
	END IF;
	RAISE NOTICE '   Liquidat.............: % - % - %', LPAD(TO_CHAR(importTotal, '9999999.99'), 11, ' '),
														LPAD(TO_CHAR(importFins, '9999999.99'), 11, ' '),
														diferencia;	
END; $$
LANGUAGE plpgsql;

-------------------------------------------------------
-- Procedure mostrarSumImportsTaules()
-------------------------------------------------------
CREATE OR REPLACE PROCEDURE mostrarTotalsImportsTaules(dretId INTEGER, nominaId INTEGER, importEfectesSimulats DECIMAL) AS $$
DECLARE
	regNomina		 eco_nomina%ROWTYPE;
	regNominaMensual eco_nomina_mensual%ROWTYPE;
BEGIN	
	SELECT * INTO regNomina FROM getRegNomina() WHERE id = nominaId;
	SELECT * INTO regNominaMensual FROM getRegUltimaNominaMensual() 
	WHERE tipus_nomina_id = regNomina.tipus_nomina_id ORDER BY data_nomina DESC LIMIT 1;	
	RAISE NOTICE '  Totals imports taules:';
	CALL mostrarSumImportsActivitats(nominaId, regNominaMensual.data_nomina, importEfectesSimulats);
	CALL mostrarSumImportsDretsTeorics(dretId, regNominaMensual.data_nomina, importEfectesSimulats);
	CALL mostrarSumImportsPercebuts(nominaId, regNominaMensual.data_nomina, importEfectesSimulats);
	CALL mostrarSumImportsOrdenacioPagament(nominaId, regNominaMensual.id, importEfectesSimulats);
	CALL mostrarSumImportsLiquidats(nominaId, regNominaMensual.data_nomina, importEfectesSimulats);
END; $$
LANGUAGE plpgsql;

-------------------------------------------------------
-- Procedure main block gETA
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
	importEfectesSimulats   DECIMAL;
BEGIN 		
	CALL mostrarCapcaleragETA();
	lstNumExpedients := current_setting('appParam.lstNumExpedients')::TEXT[];	
	FOR counter IN 1..array_length(lstNumExpedients, 1) LOOP		
		SELECT * INTO expedientPrestacioId, dretId, nominaId 
		FROM getInformacioBasica(lstNumExpedients[counter], NULL, NULL, NULL);
		IF (expedientPrestacioId IS NOT NULL) THEN
			CALL mostrarDadesExpedient(expedientPrestacioId, dretId, nominaId);
			IF (dretID IS NOT NULL) THEN
				CALL mostrarEfectes(dretId);
				CALL mostrarSimulacioEfectes(dretId, nominaId, importEfectesSimulats);
				CALL mostrarActivitats(dretId);
				CALL mostrarActivitatsDetall(nominaId);
				CALL mostrarTotalsImportsTaules(dretId, nominaId, importEfectesSimulats);
			END IF;
		ELSE
			RAISE NOTICE 'Num.Expedient...........: %', lstNumExpedients[counter];		
			RAISE NOTICE '  Informació............: ATENCIÓ! L''Expedient indicat no existeix.';
		END IF;
		RAISE NOTICE '-----------------------------------------------------------------------------';
	END LOOP;		
END $$;
