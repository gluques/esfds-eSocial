------------------------------------------------------------------------------------------------
-- VISUALIZADOR DE IMPORTES ECONÓMICOS
-- Script eSocial VIE gls - version 1.1b release 20200311 by DXC
------------------------------------------------------------------------------------------------
DO $$
DECLARE 
	nomines integer[] 	  := '{ 77,  65,  64,  54,  49,  27, 19,  7, 10}';
	prestacions integer[] := '{115, 145, 127, 116, 232, 152, 53, 29, 50}';	
	cur_dades CURSOR(p_idNomina INTEGER, p_idDret INTEGER) FOR
		SELECT * FROM 
			(SELECT SUM(quantitat) AS "Act. Detall" FROM eco_activitat_detall WHERE nomina_id = p_idNomina) a1,
			(SELECT SUM(quantitat) AS "Dre.Tèoric Detall" FROM eco_dret_teoric_detall WHERE dret_id = p_idDret) a2,
			(SELECT SUM(quantitat) AS "Dre.Tèoric" FROM eco_dret_teoric WHERE dret_id = p_idDret) a3,
			(SELECT SUM(quantitat) AS "Liquidat" FROM eco_liquidat WHERE dret_id = p_idDret) a4,
			(SELECT SUM(import_percebut) AS "Percebut" FROM eco_percebut WHERE nomina_id = p_idNomina) a5,
			(SELECT SUM(quantitat) AS "Percebut Detall" FROM eco_percebut_detall WHERE nomina_id = p_idNomina) a6,
			(SELECT SUM(quantitat) AS "Ord. Pagament" FROM eco_ordenacio_pagament WHERE nomina_id = p_idNomina) a7,
			(SELECT SUM(quantitat) AS "Ord. Pagament Detall" FROM eco_ordenacio_pagament_detall WHERE nomina_id = p_idNomina) a8;	
	expedientPrestacioId INTEGER;
	dretId INTEGER;
	personaId INTEGER;
	numeroExpedient text;
	actDetall DECIMAL;
	dreTeoric DECIMAL;
	dreTeoricDet DECIMAL;
	liquidat DECIMAL;
	percebut DECIMAL;
	percebutDet DECIMAL;
	ordPagament DECIMAL;
	ordPagamentDet DECIMAL;
BEGIN		
	SET ROLE esocial;
	SET search_path TO esocial;
	RAISE NOTICE 'START Executing script in eSocial-SQL-Verificar_Imports.sql';	
	RAISE NOTICE 'Total nòmines a processar: %', array_length(prestacions,1);	
	RAISE NOTICE 'Nòmines....: %', nomines;	
	RAISE NOTICE 'Prestacions: %', prestacions;
	FOR counter IN 1..array_length(prestacions,1) LOOP			
		SELECT expedient_prestacio_id, dret_id INTO expedientPrestacioId, dretId FROM prestacio WHERE id = prestacions[counter];
		SELECT persona_id, numero_expedient INTO personaId, numeroExpedient FROM expedient_prestacio WHERE id = expedientPrestacioId;
		OPEN cur_dades(nomines[counter], dretId);
		FETCH cur_dades INTO actDetall, dreTeoric, dreTeoricDet, liquidat, percebut, percebutDet, ordPagament, ordPagamentDet;
		CLOSE cur_dades;
		RAISE NOTICE '-----------------------------------------------------------------------------';
		RAISE NOTICE 'Num.Expedient........: %', numeroExpedient;
		RAISE NOTICE 'Nòmina...............: %', nomines[counter];		
		RAISE NOTICE 'Prestació............: %', prestacions[counter];				
		RAISE NOTICE 'Expedient Prestacio..: %', expedientPrestacioId;
		RAISE NOTICE 'Dret.................: %', dretId;
		RAISE NOTICE 'Persona..............: %', personaId;				
		RAISE NOTICE '   Act. Detall..........: %', actDetall;
		RAISE NOTICE '   Dre.Tèoric Detall....: %', dreTeoric;
		RAISE NOTICE '   Dre.Tèoric...........: %', dreTeoricDet;
		RAISE NOTICE '   Liquidat.............: %', liquidat;
		RAISE NOTICE '   Percebut.............: %', percebut;
		RAISE NOTICE '   Percebut Detall......: %', percebutDet;
		RAISE NOTICE '   Ord.Pagament.........: %', ordPagament;
		RAISE NOTICE '   Ord.Pagament Detall..: %', ordPagamentDet;
		RAISE NOTICE '-----------------------------------------------------------------------------';
	END LOOP;	
	RAISE NOTICE 'INFO: END Processing eSocial-SQL-Verificar_Imports.sql';	
END;
$$;