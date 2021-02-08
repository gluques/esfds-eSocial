------------------------------------------------------------------------------------------------
-- VISUALIZADOR DE IMPORTES ECONÓMICOS
-- Script eSocial VIE gls - version 1.2b release 20200312 by DXC
------------------------------------------------------------------------------------------------
DO $$
DECLARE 
	numExpedients text[] := '{00002/2019/68, 00002/2019/88, 00002/2019/79, 00002/2019/69, 00002/2019/146, 00002/2019/91, 00002/2019/25}';
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
	prestacioId INTEGER;
	dretId INTEGER;
	personaId INTEGER;
	nominaId INTEGER;
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
	RAISE NOTICE 'START Executing script in eSocial-SQL-Verificar_Imports_v1.sql';	
	RAISE NOTICE 'Total nòmines a processar: %', array_length(numExpedients, 1);
	FOR counter IN 1..array_length(numExpedients,1) LOOP			
		RAISE NOTICE '-----------------------------------------------------------------------------';
		SELECT pr.id, pr.dret_id, ep.persona_id, np.nomina_id INTO prestacioId, dretId, personaId, nominaId
		FROM prestacio pr LEFT JOIN expedient_prestacio ep ON pr.expedient_prestacio_id = ep.id
						  LEFT JOIN eco_nomina_persona np ON ep.persona_id = np.persona_id
		WHERE ep.numero_expedient = numExpedients[counter];				
		RAISE NOTICE 'Num.Expedient..........: %', numExpedients[counter];
		RAISE NOTICE '  Prestació............: %', prestacioId;
		RAISE NOTICE '  Dret.................: %', dretId;
		RAISE NOTICE '  Persona..............: %', personaId;	
		RAISE NOTICE '  Nòmina...............: %', nominaId;	
		OPEN cur_dades(nominaId, dretId);
		FETCH cur_dades INTO actDetall, dreTeoric, dreTeoricDet, liquidat, percebut, percebutDet, ordPagament, ordPagamentDet;
		CLOSE cur_dades;
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