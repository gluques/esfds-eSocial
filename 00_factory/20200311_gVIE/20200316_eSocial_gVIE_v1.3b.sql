------------------------------------------------------------------------------------------------
-- VISUALIZADOR DE IMPORTES ECONÓMICOS
-- Script eSocial VIE gls - version 1.3b release 20200318 by DXC
--
-- Notas:
--
--   [1] Para la ejecución en entorno PRO, se debe comentar la línea 9.
------------------------------------------------------------------------------------------------
SET ROLE esocial;
SET search_path TO esocial;
DO $$
DECLARE 
	-- Paràmetres:
	--numExpedients TEXT[] := '{00001/2019/92, 00001/2019/75, 00001/2019/99, 00001/2019/23, 00006/2020/1009,
	--						  00002/2020/26, 00002/2020/45, 00002/2020/49, 00002/2020/34}';

	numExpedients TEXT[] := '{00002/2019/219}'; 
                              
	basePathFitxers TEXT := 'C:/gluques/';
	generateCSV BOOLEAN := FALSE;	
	-- Cursors:
	cur_dades CURSOR(p_idNomina INTEGER, p_idDret INTEGER, p_dataUltimaNomMensual eco_nomina_mensual.data_nomina%TYPE) FOR
		SELECT * FROM 
			(SELECT COALESCE(SUM(quantitat), 0) AS "Act. Detall" FROM eco_activitat_detall WHERE nomina_id = p_idNomina) a1,
			(SELECT COALESCE(SUM(quantitat), 0) AS "Dre.Tèoric Detall" FROM eco_dret_teoric_detall WHERE dret_id = p_idDret AND data_efecte <= p_dataUltimaNomMensual) a2,
			(SELECT COALESCE(SUM(quantitat), 0) AS "Dre.Tèoric" FROM eco_dret_teoric WHERE dret_id = p_idDret AND data_efecte <= p_dataUltimaNomMensual) a3,
			(SELECT COALESCE(SUM(quantitat), 0) AS "Liquidat" FROM eco_liquidat WHERE dret_id = p_idDret) a4,
			(SELECT COALESCE(SUM(import_percebut), 0) AS "Percebut" FROM eco_percebut WHERE nomina_id = p_idNomina) a5,
			(SELECT COALESCE(SUM(quantitat), 0) AS "Percebut Detall" FROM eco_percebut_detall WHERE nomina_id = p_idNomina) a6,
			(SELECT COALESCE(SUM(quantitat), 0) AS "Ord. Pagament" FROM eco_ordenacio_pagament WHERE nomina_id = p_idNomina) a7,
			(SELECT COALESCE(SUM(quantitat), 0) AS "Ord. Pagament Detall" FROM eco_ordenacio_pagament_detall WHERE nomina_id = p_idNomina) a8;		
	cur_efectes CURSOR(p_idDret INTEGER) FOR
		SELECT * FROM eco_efecte_moviment_nomina WHERE dret_id = p_idDret ORDER BY data_efecte_inici, data_efecte_fi;
	cur_activitats CURSOR(p_idNomina INTEGER) FOR
		SELECT DISTINCT ea.id, ea.data_darrera_execucio, ea.quantitat, ea.data_efecte_inicial, 
						ea.data_efecte_final, ea.estat_activitat
		FROM eco_activitat ea 
			JOIN eco_activitat_detall ead ON ea.id = ead.activitat_id 
		WHERE ead.nomina_id = p_idNomina ORDER BY ea.id;
	cur_act_detall CURSOR(p_idNomina INTEGER) FOR
		SELECT id, data_efecte, pagament_tipus_id, quantitat 			
			FROM eco_activitat_detall WHERE nomina_id = p_idNomina ORDER BY data_efecte;
	-- Fila taula:
	regEfecteMovNom 		eco_efecte_moviment_nomina%ROWTYPE;	
	-- Columna taula:
	colValorIdentificador 	identificador.valor%TYPE;		
	colTipusNomina 			eco_nomina.tipus_nomina_id%TYPE;
	colAltaNomina			eco_nomina.data_alta_nomina%TYPE;	
	colPriExecucioNomina	eco_nomina.data_primera_execucio%TYPE;
	colEfecteIniNommina		eco_nomina.data_efecte_inici%TYPE;
	colDescripTipNomina		llistat_valors_idioma.descripcio%TYPE;
	colIdNomMensual			eco_nomina_mensual.id%TYPE;
	colDataUltimaNomMensual eco_nomina_mensual.data_nomina%TYPE;
	colIdEfecteAnt			eco_efecte_moviment_nomina.id%TYPE;
	colTipusEfecteAnt  		eco_efecte_moviment_nomina.tipus_id%TYPE;
	colImportEfecteAnt 		eco_efecte_moviment_nomina.import_actual%TYPE;
	colIniciEfecteAnt  		eco_efecte_moviment_nomina.data_efecte_inici%TYPE;
	colIdAct				eco_activitat.id%TYPE;
	colDarreraExeAct		eco_activitat.data_darrera_execucio%TYPE;	
	colEfecteIniAct			eco_activitat.data_efecte_inicial%TYPE;
	colEfecteFinAct			eco_activitat.data_efecte_final%TYPE;
	colEstatAct				eco_activitat.estat_activitat%TYPE;	
	colIdActDetall			eco_activitat_detall.id%TYPE;	
	colEfecteActDetall		eco_activitat_detall.data_efecte%TYPE;
	colTipusPagaActDetall	eco_activitat_detall.pagament_tipus_id%TYPE;		
	-- Variables:	
	prestacioId 			INTEGER;
	dretId 					INTEGER;
	personaId 				INTEGER;
	nominaId 				INTEGER;
	descTipusNom			TEXT;
	quantitatAct			DECIMAL;
	estatAct				INTEGER;
	quantitatActDetall		DECIMAL;
	impTotalActDet 			DECIMAL;
	impTotalDreTeoric 		DECIMAL;
	impTotaDreTeoricDet 	DECIMAL;
	impTotalLiquidat 		DECIMAL;
	impTotalPercebut 		DECIMAL;
	impTotalPercebutDet 	DECIMAL;
	impTotalOrdPagament 	DECIMAL;
	impTotalOrdPagamentDet 	DECIMAL;
	impTotalEfectes 		DECIMAL;
	lstExpedientsErronis	TEXT := '';
	sumaImportsTaules		DECIMAL;
	importMitjatTaules 		DECIMAL;
	taulesCorrectes			BOOLEAN := TRUE;
	totalExpAmbErrors		INTEGER;	
	pathFitxerCSV			TEXT;
	selectFitxerCSV			TEXT;
	copyFitxerCSV			TEXT;
	nominaExecutada			BOOLEAN := FALSE;
	numTaulesImportMitjat	INTEGER := 8;
BEGIN			
	RAISE NOTICE '-----------------------------------------------------------------------------';
	RAISE NOTICE 'Script eSocial gVIE 1.3b release 20200616 by DXC';	
	RAISE NOTICE '';
	RAISE NOTICE '  Fecha ejecución: %', (SELECT (TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS')));
	RAISE NOTICE '  Total expedients a processar: %', array_length(numExpedients, 1);
	RAISE NOTICE '-----------------------------------------------------------------------------';
	totalExpAmbErrors := 0;
	FOR counter IN 1..array_length(numExpedients,1) LOOP	
		-- Expedient Prestació:
		SELECT pr.id, pr.dret_id, ep.persona_id, np.nomina_id 
		INTO prestacioId, dretId, personaId, nominaId
		FROM prestacio pr LEFT JOIN expedient_prestacio ep ON pr.expedient_prestacio_id = ep.id
						  LEFT JOIN eco_nomina_persona np ON ep.persona_id = np.persona_id
		WHERE ep.numero_expedient = numExpedients[counter];		
		-- Identificador:
		SELECT valor INTO colValorIdentificador FROM identificador WHERE persona_id = personaId;		
		-- Nòmina:
		SELECT tipus_nomina_id, data_alta_nomina, data_primera_execucio, data_efecte_inici 
			INTO colTipusNomina, colAltaNomina, colPriExecucioNomina, colEfecteIniNommina 
		FROM eco_nomina WHERE id = nominaId;				
		IF (colPriExecucioNomina IS NULL) THEN
			nominaExecutada := FALSE;
		ELSE
			nominaExecutada := TRUE;
		END IF;
		-- Tipus nòmina:
		SELECT lvi.descripcio INTO colDescripTipNomina
		FROM eco_tipus_nomina tt	
			JOIN llistat_valors lv ON tt.llistat_valors_id = lv.id
			JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
		WHERE tt.id = colTipusNomina;				
		-- Nòmina Mensual:
		SELECT id, data_nomina INTO colIdNomMensual, colDataUltimaNomMensual FROM eco_nomina_mensual 
			WHERE tipus_nomina_id = colTipusNomina ORDER BY data_nomina DESC LIMIT 1; 
		-- Resum dades:
		RAISE NOTICE 'Num.Expedient...........: %', numExpedients[counter];		
		RAISE NOTICE '  Prestació.............: %', prestacioId;
		RAISE NOTICE '  Dret..................: %', dretId;
		RAISE NOTICE '  Persona...............: %', personaId;	
		RAISE NOTICE '   Identificador........: %', colValorIdentificador;
		RAISE NOTICE '  Nòmina................: %', nominaId;
		RAISE NOTICE '   Tipus................: % - ''%''', colTipusNomina, colDescripTipNomina;
		RAISE NOTICE '   Alta.................: %', colAltaNomina;
		RAISE NOTICE '   Primera execució.....: %', colPriExecucioNomina;
		RAISE NOTICE '   Efecte inici.........: %', colEfecteIniNommina;
		RAISE NOTICE '  Última nòmina.mensual.: %', colIdNomMensual;
		RAISE NOTICE '   Data.................: %', colDataUltimaNomMensual;
		-- Càlcul dels períodes amb els Efectes:		
		RAISE NOTICE '  Periodes Efectes:';	
		colIniciEfecteAnt := NULL;
		impTotalEfectes := 0;
		taulesCorrectes := TRUE;
		OPEN cur_efectes(dretId);   
		LOOP	
		  FETCH cur_efectes INTO regEfecteMovNom;	
		  EXIT WHEN NOT FOUND;		  
			IF (colIniciEfecteAnt IS NOT NULL) THEN				
				SELECT colIniciEfecteAnt + (1 * INTERVAL '1 month') INTO colIniciEfecteAnt;								
				WHILE regEfecteMovNom.data_efecte_inici > colIniciEfecteAnt LOOP				
					RAISE NOTICE '   % - % - % - %', (SELECT TO_CHAR(colIdEfecteAnt, 'fm00000')), 
													 (SELECT TO_CHAR(colTipusEfecteAnt, 'fm00')), 
													 (TO_CHAR(colIniciEfecteAnt,'YYYY-MM-DD')), 
													 (SELECT LPAD(TO_CHAR(colImportEfecteAnt, '9999.99'), 9,''));
					IF (colTipusEfecteAnt <> 17 AND colTipusEfecteAnt <> 18 AND
						TO_CHAR(colIniciEfecteAnt,'YYYY-MM-DD') <= TO_CHAR(colDataUltimaNomMensual,'YYYY-MM-DD')) THEN
						impTotalEfectes := impTotalEfectes + colImportEfecteAnt;
					END IF;
					SELECT colIniciEfecteAnt + (1 * INTERVAL '1 month') INTO colIniciEfecteAnt;
				END LOOP;				
			END IF;						
			colIdEfecteAnt := regEfecteMovNom.id;
			colTipusEfecteAnt := regEfecteMovNom.tipus_id;
			colIniciEfecteAnt := regEfecteMovNom.data_efecte_inici;
			colImportEfecteAnt := regEfecteMovNom.import_actual;
			IF (colTipusEfecteAnt <> 17 AND colTipusEfecteAnt <> 18 AND
				TO_CHAR(colIniciEfecteAnt,'YYYY-MM-DD') <= TO_CHAR(colDataUltimaNomMensual,'YYYY-MM-DD')) THEN
				impTotalEfectes := impTotalEfectes + colImportEfecteAnt;
			END IF;			
			RAISE NOTICE '   % - % - % - %', (SELECT TO_CHAR(colIdEfecteAnt, 'fm00000')), 
											 (SELECT TO_CHAR(colTipusEfecteAnt, 'fm00')), 
											 (TO_CHAR(colIniciEfecteAnt,'YYYY-MM-DD')), 
											 (SELECT LPAD(TO_CHAR(colImportEfecteAnt, '9999.99'), 9,''));
		END LOOP;
		CLOSE cur_efectes;		
		-- Càlcul de la resta de períodes fent servir la data de l'última nòmina mensual:
		SELECT TO_CHAR(colDataUltimaNomMensual,'YYYY-MM-DD') INTO colDataUltimaNomMensual;
		IF (colDataUltimaNomMensual > colIniciEfecteAnt) THEN
			WHILE(colIniciEfecteAnt < colDataUltimaNomMensual) LOOP
				SELECT colIniciEfecteAnt + (1 * INTERVAL '1 month') INTO colIniciEfecteAnt;					
				RAISE NOTICE '   % - % - % - %', (SELECT TO_CHAR(colIdEfecteAnt, 'fm00000')), 
												 (SELECT TO_CHAR(colTipusEfecteAnt, 'fm00')), 
												 (TO_CHAR(colIniciEfecteAnt,'YYYY-MM-DD')), 
												 (SELECT LPAD(TO_CHAR(colImportEfecteAnt, '9999.99'), 9,''));
				IF (colTipusEfecteAnt <> 17 AND colTipusEfecteAnt <> 18 AND
					TO_CHAR(colIniciEfecteAnt,'YYYY-MM-DD') <= TO_CHAR(colDataUltimaNomMensual,'YYYY-MM-DD')) THEN								 
					impTotalEfectes := impTotalEfectes + colImportEfecteAnt;
				END IF;				
			END LOOP;
		END IF;
		-- Activitats:
		RAISE NOTICE '  Activitat:';	
		OPEN cur_activitats(nominaId);   
		LOOP	
		  FETCH cur_activitats INTO colIdAct, colDarreraExeAct, quantitatAct, colEfecteIniAct, 
									colEfecteFinAct, estatAct;
		  EXIT WHEN NOT FOUND;
			SELECT ROUND(quantitatAct, 2) INTO quantitatAct;
		  	RAISE NOTICE '   % - % - % - % - % - %', (SELECT TO_CHAR(colIdAct, 'fm00000')),
													 (SELECT TO_CHAR(estatAct, 'fm00')),
													 (TO_CHAR(colDarreraExeAct,'YYYY-MM-DD')), 
													 (SELECT LPAD(TO_CHAR(quantitatAct, '9999.99'), 9,'')),
													 (TO_CHAR(colEfecteIniAct,'YYYY-MM-DD')), 
													 (TO_CHAR(colEfecteFinAct,'YYYY-MM-DD'));
		END LOOP;
		CLOSE cur_activitats;		
		-- Activitats Detall:
		RAISE NOTICE '  Activitat Detall:';	
		OPEN cur_act_detall(nominaId);   
		LOOP	
		  FETCH cur_act_detall INTO colIdActDetall, colEfecteActDetall, colTipusPagaActDetall, 
									quantitatActDetall;	
		  EXIT WHEN NOT FOUND;
			SELECT ROUND(quantitatActDetall, 2) INTO quantitatActDetall;
			RAISE NOTICE '   % - % - % - %', (SELECT TO_CHAR(colIdActDetall, 'fm00000')), 
											 (SELECT TO_CHAR(colTipusPagaActDetall, 'fm00')), 
											 (TO_CHAR(colEfecteActDetall,'YYYY-MM-DD')),
											 (SELECT LPAD(TO_CHAR(quantitatActDetall, '9999.99'), 9,''));
		END LOOP;
		CLOSE cur_act_detall;		
		-- Càlcul dels imports de les taules econòmiques:
		RAISE NOTICE '  Imports taules:';	
		OPEN cur_dades(nominaId, dretId, colDataUltimaNomMensual);
		FETCH cur_dades INTO impTotalActDet, impTotaDreTeoricDet, impTotalDreTeoric, impTotalLiquidat, 
							 impTotalPercebut, impTotalPercebutDet, impTotalOrdPagament, impTotalOrdPagamentDet;
		CLOSE cur_dades;
		SELECT ROUND(impTotalActDet,2) INTO impTotalActDet;
		SELECT ROUND(impTotalDreTeoric,2) INTO impTotalDreTeoric;
		SELECT ROUND(impTotaDreTeoricDet,2) INTO impTotaDreTeoricDet;
		SELECT ROUND(impTotalLiquidat,2) INTO impTotalLiquidat;
		SELECT ROUND(impTotalPercebut,2) INTO impTotalPercebut;
		SELECT ROUND(impTotalPercebutDet,2) INTO impTotalPercebutDet;
		SELECT ROUND(impTotalOrdPagament,2) INTO impTotalOrdPagament;
		SELECT ROUND(impTotalOrdPagamentDet,2) INTO impTotalOrdPagamentDet;
		RAISE NOTICE '   Act.Detall...........: %', impTotalActDet;
		RAISE NOTICE '   Dre.Tèoric...........: %', impTotalDreTeoric;
		RAISE NOTICE '   Dre.Tèoric Detall....: %', impTotaDreTeoricDet;		
		RAISE NOTICE '   Liquidat.............: %', impTotalLiquidat;
		RAISE NOTICE '   Percebut.............: %', impTotalPercebut;
		RAISE NOTICE '   Percebut Detall......: %', impTotalPercebutDet;
		RAISE NOTICE '   Ord.Pagament.........: %', impTotalOrdPagament;
		RAISE NOTICE '   Ord.Pagament Detall..: %', impTotalOrdPagamentDet;				
		-- Resultat del anàlisis:
		SELECT ROUND(impTotalEfectes, 2) INTO impTotalEfectes;
		RAISE NOTICE 'Resultat del anàlisis:';		
		RAISE NOTICE '  Import efectes calculats.......: %', impTotalEfectes;
		IF (NOT nominaExecutada) THEN
			numTaulesImportMitjat := 0;
			IF (impTotalActDet > 0) THEN numTaulesImportMitjat := numTaulesImportMitjat + 1; END IF;
			IF (impTotalDreTeoric > 0) THEN numTaulesImportMitjat := numTaulesImportMitjat + 1; END IF;
			IF (impTotaDreTeoricDet > 0) THEN numTaulesImportMitjat := numTaulesImportMitjat + 1; END IF;
			IF (impTotalLiquidat > 0) THEN numTaulesImportMitjat := numTaulesImportMitjat + 1; END IF;
			IF (impTotalPercebut > 0) THEN numTaulesImportMitjat := numTaulesImportMitjat + 1; END IF;
			IF (impTotalPercebutDet > 0) THEN numTaulesImportMitjat := numTaulesImportMitjat + 1; END IF;
			IF (impTotalOrdPagament > 0) THEN numTaulesImportMitjat := numTaulesImportMitjat + 1; END IF;
			IF (impTotalOrdPagamentDet > 0) THEN numTaulesImportMitjat := numTaulesImportMitjat + 1; END IF;
			IF (numTaulesImportMitjat = 0) THEN numTaulesImportMitjat := 1; END IF;
		ELSE 
			numTaulesImportMitjat := 8;
		END IF;
		sumaImportsTaules := ((impTotalActDet + impTotalDreTeoric + impTotaDreTeoricDet + impTotalLiquidat + 
							   impTotalPercebut + impTotalPercebutDet + impTotalOrdPagament + 
							   impTotalOrdPagamentDet));
		importMitjatTaules :=  (sumaImportsTaules / numTaulesImportMitjat);
		SELECT ROUND(importMitjatTaules, 2) INTO importMitjatTaules;
		RAISE NOTICE '  Import mitjà taules............: %', importMitjatTaules;		
		IF (SELECT TO_CHAR(impTotalActDet,'9999.99') <> (SELECT TO_CHAR(importMitjatTaules,'9999.99'))) THEN taulesCorrectes := FALSE; END IF;		
		IF (SELECT TO_CHAR(impTotalDreTeoric,'9999.99') <> (SELECT TO_CHAR(importMitjatTaules,'9999.99'))) THEN taulesCorrectes := FALSE; END IF;		
		IF (SELECT TO_CHAR(impTotaDreTeoricDet,'9999.99') <> (SELECT TO_CHAR(importMitjatTaules,'9999.99'))) THEN taulesCorrectes := FALSE; END IF;		
		IF (SELECT TO_CHAR(impTotalLiquidat,'9999.99') <> (SELECT TO_CHAR(importMitjatTaules,'9999.99'))) THEN taulesCorrectes := FALSE; END IF;		
		IF (SELECT TO_CHAR(impTotalPercebut,'9999.99') <> (SELECT TO_CHAR(importMitjatTaules,'9999.99'))) THEN taulesCorrectes := FALSE; END IF;
		IF (SELECT TO_CHAR(impTotalPercebutDet,'9999.99') <> (SELECT TO_CHAR(importMitjatTaules,'9999.99'))) THEN taulesCorrectes := FALSE; END IF;		
		IF (SELECT TO_CHAR(impTotalOrdPagament,'9999.99') <> (SELECT TO_CHAR(importMitjatTaules,'9999.99'))) THEN taulesCorrectes := FALSE; END IF;
		IF (SELECT TO_CHAR(impTotalOrdPagamentDet,'9999.99') <> (SELECT TO_CHAR(importMitjatTaules,'9999.99'))) THEN taulesCorrectes := FALSE; END IF;	
		IF ((SELECT TO_CHAR(importMitjatTaules,'9999.99')) <> (SELECT TO_CHAR(impTotalEfectes,'9999.99')) AND NOT(taulesCorrectes)) THEN		
			RAISE NOTICE '  Resultat.......................: Imports expedient % amb ERRORS', numExpedients[counter];
			if (lstExpedientsErronis = '') THEN
				lstExpedientsErronis = numExpedients[counter];
			ELSE 
				lstExpedientsErronis = lstExpedientsErronis || ',' || numExpedients[counter];
			END IF;					
			totalExpAmbErrors := totalExpAmbErrors + 1;			
			RAISE NOTICE '  Taules incorrectes:';
			IF (impTotalActDet <> impTotalEfectes AND NOT(nominaExecutada)) THEN				
				RAISE NOTICE '   %: %', (SELECT RPAD('eco_activitat_detall', 30, '.')), (impTotalActDet - impTotalEfectes);
				IF (generateCSV) THEN
					SELECT basePathFitxers || REPLACE(numExpedients[counter] || '_Activitat_Detall','/','_') INTO pathFitxerCSV;				
					SELECT (pathFitxerCSV || '_' || TO_CHAR(NOW(),'YYYY-MM-DD') || '.csv') INTO pathFitxerCSV;				
					SELECT ('SELECT *') INTO selectFitxerCSV;
					SELECT (selectFitxerCSV || ' FROM eco_activitat_detall WHERE nomina_id = ' || nominaId || ' ORDER BY data_efecte') INTO selectFitxerCSV;						
					SELECT ('COPY (' || selectFitxerCSV || ') TO ''' || pathFitxerCSV || ''' DELIMITER '';'' CSV HEADER') INTO copyFitxerCSV;												
					EXECUTE copyFitxerCSV;
				END IF;
			END IF;
			IF (impTotalDreTeoric <> impTotalEfectes AND nominaExecutada) THEN				
				RAISE NOTICE '   %: %', (SELECT RPAD('eco_dret_teoric', 30, '.')), (impTotalDreTeoric - impTotalEfectes);
				IF (generateCSV) THEN
					SELECT basePathFitxers || REPLACE(numExpedients[counter] || '_Dret_Teoric','/','_') INTO pathFitxerCSV;				
					SELECT (pathFitxerCSV || '_' || TO_CHAR(NOW(),'YYYY-MM-DD') || '.csv') INTO pathFitxerCSV;				
					SELECT ('SELECT id, opt_lck_ctl, rcd_crt_nm, rcd_crt_ts, REPLACE(TO_CHAR(quantitat,''9999.99''),''.'','','') AS quantitat, 
							dret_id, data_efecte, data_execucio') INTO selectFitxerCSV;
					SELECT (selectFitxerCSV || ' FROM eco_dret_teoric WHERE dret_id = ' || dretId || ' ORDER BY data_efecte') INTO selectFitxerCSV;						
					SELECT ('COPY (' || selectFitxerCSV || ') TO ''' || pathFitxerCSV || ''' DELIMITER '';'' CSV HEADER') INTO copyFitxerCSV;												
					EXECUTE copyFitxerCSV;
				END IF;
			END IF;
			IF (impTotaDreTeoricDet <> impTotalEfectes AND nominaExecutada) THEN
				RAISE NOTICE '   %: %', (SELECT RPAD('eco_dret_teoric_detall', 30, '.')), (impTotaDreTeoricDet - impTotalEfectes);
				IF (generateCSV) THEN
					SELECT basePathFitxers || REPLACE(numExpedients[counter] || '_Dret_Teoric_Detall','/','_') INTO pathFitxerCSV;				
					SELECT (pathFitxerCSV || '_' || TO_CHAR(NOW(),'YYYY-MM-DD') || '.csv') INTO pathFitxerCSV;				
					SELECT ('SELECT id,	dret_id, efecte_moviment_id, data_efecte, REPLACE(TO_CHAR(quantitat,''9999.99''),''.'','','') AS quantitat, 
							concepte_id, modalitat_pagament_id, tipus_pagament_id') INTO selectFitxerCSV;
					SELECT (selectFitxerCSV || ' FROM eco_dret_teoric_detall WHERE dret_id = ' || dretId || ' ORDER BY data_efecte') INTO selectFitxerCSV;						
					SELECT ('COPY (' || selectFitxerCSV || ') TO ''' || pathFitxerCSV || ''' DELIMITER '';'' CSV HEADER') INTO copyFitxerCSV;												
					EXECUTE copyFitxerCSV;
				END IF;
			END IF;
			IF (impTotalLiquidat <> impTotalEfectes AND nominaExecutada) THEN				
				RAISE NOTICE '   %: %', (SELECT RPAD('eco_liquidat', 30, '.')), (impTotalLiquidat - impTotalEfectes);
				IF (generateCSV) THEN
					SELECT basePathFitxers || REPLACE(numExpedients[counter] || '_Liquidat','/','_') INTO pathFitxerCSV;				
					SELECT (pathFitxerCSV || '_' || TO_CHAR(NOW(),'YYYY-MM-DD') || '.csv') INTO pathFitxerCSV;				
					SELECT ('SELECT *') INTO selectFitxerCSV;
					SELECT (selectFitxerCSV || ' FROM eco_liquidat WHERE dret_id = ' || dretId || ' ORDER BY data_periode') INTO selectFitxerCSV;						
					SELECT ('COPY (' || selectFitxerCSV || ') TO ''' || pathFitxerCSV || ''' DELIMITER '';'' CSV HEADER') INTO copyFitxerCSV;												
					EXECUTE copyFitxerCSV;
				END IF;
			END IF;
			IF (impTotalPercebut <> impTotalEfectes AND nominaExecutada) THEN				
				RAISE NOTICE '   %: %', (SELECT RPAD('eco_percebut', 30, '.')), (impTotalPercebut - impTotalEfectes);
				IF (generateCSV) THEN
					SELECT basePathFitxers || REPLACE(numExpedients[counter] || '_Percebut','/','_') INTO pathFitxerCSV;				
					SELECT (pathFitxerCSV || '_' || TO_CHAR(NOW(),'YYYY-MM-DD') || '.csv') INTO pathFitxerCSV;				
					SELECT ('SELECT id, opt_lck_ctl, rcd_crt_nm, rcd_crt_ts, data_efecte, REPLACE(TO_CHAR(import_percebut,''9999.99''),''.'','','') AS import_percebut, 
							nomina_id, concepte_id') INTO selectFitxerCSV;
					SELECT (selectFitxerCSV || ' FROM eco_percebut WHERE nomina_id = ' || nominaId || ' ORDER BY data_efecte') INTO selectFitxerCSV;				
					SELECT ('COPY (' || selectFitxerCSV || ') TO ''' || pathFitxerCSV || ''' DELIMITER '';'' CSV HEADER') INTO copyFitxerCSV;												
					EXECUTE copyFitxerCSV;
				END IF;
			END IF;
			IF (impTotalPercebutDet <> impTotalEfectes AND nominaExecutada) THEN				
				RAISE NOTICE '   %: %', (SELECT RPAD('eco_percebut_detall', 30, '.')), (impTotalPercebutDet - impTotalEfectes);
				IF (generateCSV) THEN
					SELECT basePathFitxers || REPLACE(numExpedients[counter] || '_Percebut_Detall','/','_') INTO pathFitxerCSV;				
					SELECT (pathFitxerCSV || '_' || TO_CHAR(NOW(),'YYYY-MM-DD') || '.csv') INTO pathFitxerCSV;				
					SELECT ('SELECT id, opt_lck_ctl, rcd_crt_nm, rcd_crt_ts, dret_id, nomina_id, data_efecte, REPLACE(TO_CHAR(quantitat,''9999.99''),''.'','','') AS quantitat, 
							data_execucio, concepte_id, modalitat_pagament_id, tipus_pagament_id, activitat_detall_id') INTO selectFitxerCSV;
					SELECT (selectFitxerCSV || ' FROM eco_percebut_detall WHERE nomina_id = ' || nominaId || ' ORDER BY data_efecte') INTO selectFitxerCSV;				
					SELECT ('COPY (' || selectFitxerCSV || ') TO ''' || pathFitxerCSV || ''' DELIMITER '';'' CSV HEADER') INTO copyFitxerCSV;												
					EXECUTE copyFitxerCSV;
				END IF;
			END IF;
			IF (impTotalOrdPagament <> impTotalEfectes AND nominaExecutada) THEN				
				RAISE NOTICE '   %: %', (SELECT RPAD('eco_ordenacio_pagament', 30, '.')), (impTotalOrdPagament - impTotalEfectes);	
				IF (generateCSV) THEN
					SELECT basePathFitxers || REPLACE(numExpedients[counter] || '_Ordenacio_Pagament','/','_') INTO pathFitxerCSV;				
					SELECT (pathFitxerCSV || '_' || TO_CHAR(NOW(),'YYYY-MM-DD') || '.csv') INTO pathFitxerCSV;				
					SELECT ('SELECT *') INTO selectFitxerCSV;
					SELECT (selectFitxerCSV || ' FROM eco_ordenacio_pagament WHERE nomina_id = ' || nominaId || ' ORDER BY rcd_crt_ts') INTO selectFitxerCSV;						
					SELECT ('COPY (' || selectFitxerCSV || ') TO ''' || pathFitxerCSV || ''' DELIMITER '';'' CSV HEADER') INTO copyFitxerCSV;												
					EXECUTE copyFitxerCSV;
				END IF;
			END IF;
			IF (impTotalOrdPagamentDet <> impTotalEfectes AND nominaExecutada) THEN				
				RAISE NOTICE '   %: %', (SELECT RPAD('eco_ordenacio_pagament_detall', 30, '.')), (impTotalOrdPagamentDet - impTotalEfectes);
				IF (generateCSV) THEN
					SELECT basePathFitxers || REPLACE(numExpedients[counter] || '_Ordenacio_Pagament_Detall','/','_') INTO pathFitxerCSV;				
					SELECT (pathFitxerCSV || '_' || TO_CHAR(NOW(),'YYYY-MM-DD') || '.csv') INTO pathFitxerCSV;				
					SELECT ('SELECT *') INTO selectFitxerCSV;
					SELECT (selectFitxerCSV || ' FROM eco_ordenacio_pagament_detall WHERE nomina_id = ' || nominaId || ' ORDER BY rcd_crt_ts') INTO selectFitxerCSV;						
					SELECT ('COPY (' || selectFitxerCSV || ') TO ''' || pathFitxerCSV || ''' DELIMITER '';'' CSV HEADER') INTO copyFitxerCSV;												
					EXECUTE copyFitxerCSV;
				END IF;
			END IF;
		ELSE
			RAISE NOTICE '  Resultat.......................: OK';
		END IF;	
		RAISE NOTICE '-----------------------------------------------------------------------------';				
	END LOOP;	
	RAISE NOTICE 'Total expedients processats..: %', array_length(numExpedients, 1);
	RAISE NOTICE 'Total expedients sense errors: %', (array_length(numExpedients, 1) - totalExpAmbErrors);
	RAISE NOTICE 'Total expedients amb errors..: %', totalExpAmbErrors;
	IF (lstExpedientsErronis <> '') THEN
		RAISE NOTICE '  Expedients.................: %', lstExpedientsErronis;
	END IF;
	RAISE NOTICE '-----------------------------------------------------------------------------';				
	RAISE NOTICE 'INFO: END Process.';	
END;
$$;