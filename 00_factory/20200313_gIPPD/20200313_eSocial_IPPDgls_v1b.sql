------------------------------------------------------------------------------------------------
-- Inserts Percebut Percebut Detall (gIPPD)
-- Script eSocial gIPPD - 1.1 beta
--
-- Notas:
--
--		[17/03] Se están calculando los periodos empleando la Activitat Detall, lo que implica
--				que esta tabla disponga de los registros correctos, pero no siempre es así. 
--				Habría que cambiar el sistema para que los periodos se calcularan a partir de 
--				los efectos existentes.
------------------------------------------------------------------------------------------------
SET ROLE esocial;
SET search_path TO esocial;

DO $$
DECLARE
	-- Paràmetres -------------------------------------------------		
	numExpedients 			TEXT[] 	:= '{00001/2019/91}';	
	dataInici 				TEXT	:= '2019-11-01';
	dataFi 					TEXT 	:= '2019-12-01';	
	generarActivitatDetall 	BOOLEAN := FALSE;		-- No implementado!
	generarPercebut			BOOLEAN := TRUE;
	generarPercebutDetall	BOOLEAN := TRUE;
	refIdActivitatDetall	INTEGER := 0;	
	refIdPercebut			INTEGER := 427;
	refIdPercebutDetall		INTEGER := 447;	
	-- Variables -------------------------------------------------		
	cur_actitivat_detall CURSOR(p_idNomina INTEGER, p_dataInici TEXT, p_dataFi TEXT) FOR
							SELECT * FROM eco_activitat_detall WHERE nomina_id = p_idNomina
							AND data_efecte >= TO_DATE(p_dataInici,'YYYY/MM/DD')
							AND data_efecte <= TO_DATE(p_dataFi,'YYYY/MM/DD')
							ORDER BY data_efecte;						
							
	insert_act_detall		TEXT := '';
	insert_percebuts 		TEXT := 'INSERT INTO eco_percebut (opt_lck_ctl, rcd_crt_nm, rcd_crt_ts, data_efecte, import_percebut, nomina_id, concepte_id)';
	insert_percebuts_detall TEXT := 'INSERT INTO eco_percebut_detall (opt_lck_ctl, rcd_crt_nm, rcd_crt_ts, dret_id, nomina_id, data_efecte, quantitat, data_execucio, concepte_id, modalitat_pagament_id, tipus_pagament_id, activitat_detall_id)';
	
	rowPercebut 				eco_percebut%ROWTYPE;	
	rowPercebutDetall 			eco_percebut_detall%ROWTYPE;
	rowActivitatDetall 			eco_activitat_detall%ROWTYPE;
	
	totalInsertsPercebuts 		INTEGER;
	totalInsertsPercebutsDet 	INTEGER;	
	prestacioId 				INTEGER;
	dretId 						INTEGER;
	personaId 					INTEGER;
	nominaId 					INTEGER;
BEGIN		
	RAISE NOTICE '-----------------------------------------------------------------------------';
	RAISE NOTICE 'Script eSocial IPPD gls - 1.0 release 20200313 by DXC';	
	RAISE NOTICE 'Total expedients a processar: %', array_length(numExpedients, 1);
	RAISE NOTICE '-----------------------------------------------------------------------------';		
	-- Expedient:	
	SELECT pr.id, pr.dret_id, ep.persona_id, np.nomina_id 
		INTO prestacioId, dretId, personaId, nominaId
		FROM prestacio pr LEFT JOIN expedient_prestacio ep ON pr.expedient_prestacio_id = ep.id
						  LEFT JOIN eco_nomina_persona np ON ep.persona_id = np.persona_id
		WHERE ep.numero_expedient = numExpedients[1];	
	-- Resum dades:
	RAISE NOTICE 'Num.Expedient...........: %', numExpedients[1];		
	RAISE NOTICE '  Prestació.............: %', prestacioId;
	RAISE NOTICE '  Dret..................: %', dretId;
	RAISE NOTICE '  Persona...............: %', personaId;		
	RAISE NOTICE '  Nòmina................: %', nominaId;
	RAISE NOTICE 'Sentencias INSERT:';
	RAISE NOTICE '';
	-- Activitat Detall:
	IF (generarActivitatDetall) THEN 
	END IF;
	-- Percebuts:	
	IF (generarPercebut) THEN 
		RAISE NOTICE '-- Taula eco_percebut';
		SELECT * INTO rowPercebut FROM eco_percebut WHERE id = refIdPercebut;		
		RAISE NOTICE '%', insert_percebuts;
		totalInsertsPercebuts := 0;
		OPEN cur_actitivat_detall(nominaId, dataInici, dataFi);   
		LOOP	
		  FETCH cur_actitivat_detall INTO rowActivitatDetall;	
		  EXIT WHEN NOT FOUND;		 
			IF ((TO_CHAR(rowActivitatDetall.data_efecte,'YYYY-MM-DD')) = dataFi) THEN
				RAISE NOTICE '	VALUES (%, ''%'', ''%'', ''%'', %, %, %);', 
								rowPercebut.opt_lck_ctl, rowPercebut.rcd_crt_nm, 
								rowPercebut.rcd_crt_ts, rowActivitatDetall.data_efecte, 
								rowActivitatDetall.quantitat, rowPercebut.nomina_id, 
								rowPercebut.concepte_id;
			ELSE
				RAISE NOTICE '	VALUES (%, ''%'', ''%'', ''%'', %, %, %),', 
								rowPercebut.opt_lck_ctl, rowPercebut.rcd_crt_nm, 
								rowPercebut.rcd_crt_ts, rowActivitatDetall.data_efecte, 
								rowActivitatDetall.quantitat, rowPercebut.nomina_id, 
								rowPercebut.concepte_id;
			END IF;
			totalInsertsPercebuts := totalInsertsPercebuts + 1;	
		END LOOP;
		CLOSE cur_actitivat_detall;	
	END IF;
	-- Percebuts Detall:
	IF (generarPercebutDetall) THEN
		RAISE NOTICE '';	
		RAISE NOTICE '-- Taula eco_percebut_detall';
		SELECT * INTO rowPercebutDetall FROM eco_percebut_detall WHERE id = refIdPercebut;		
		RAISE NOTICE '%', insert_percebuts_detall;
		totalInsertsPercebutsDet := 0;	
		OPEN cur_actitivat_detall(nominaId, dataInici, dataFi); 	
		LOOP	
		  FETCH cur_actitivat_detall INTO rowActivitatDetall;	
		  EXIT WHEN NOT FOUND;
			IF ((TO_CHAR(rowActivitatDetall.data_efecte,'YYYY-MM-DD')) = dataFi) THEN
				RAISE NOTICE '	VALUES (%, ''%'', ''%'', %, %, ''%'', %, ''%'', %, %, %, %);',
								rowPercebutDetall.opt_lck_ctl, rowPercebutDetall.rcd_crt_nm,
								rowPercebutDetall.rcd_crt_ts, rowPercebutDetall.dret_id, 
								rowPercebutDetall.nomina_id, rowActivitatDetall.data_efecte, 
								rowActivitatDetall.quantitat, rowPercebutDetall.data_execucio,
								rowPercebutDetall.concepte_id, rowPercebutDetall.modalitat_pagament_id,
								rowActivitatDetall.pagament_tipus_id, rowActivitatDetall.id;		
			ELSE
				RAISE NOTICE '	VALUES (%, ''%'', ''%'', %, %, ''%'', %, ''%'', %, %, %, %),',
								rowPercebutDetall.opt_lck_ctl, rowPercebutDetall.rcd_crt_nm,
								rowPercebutDetall.rcd_crt_ts, rowPercebutDetall.dret_id, 
								rowPercebutDetall.nomina_id, rowActivitatDetall.data_efecte, 
								rowActivitatDetall.quantitat, rowPercebutDetall.data_execucio,
								rowPercebutDetall.concepte_id, rowPercebutDetall.modalitat_pagament_id,
								rowActivitatDetall.pagament_tipus_id, rowActivitatDetall.id;
			END IF;
			totalInsertsPercebutsDet := totalInsertsPercebutsDet + 1;
		END LOOP;
		CLOSE cur_actitivat_detall;	
	END IF;	
	RAISE NOTICE '-----------------------------------------------------------------------------';
	RAISE NOTICE 'Total expedients processats..: %', array_length(numExpedients, 1);
	RAISE NOTICE 'Total inserts Percebuts......: %', totalInsertsPercebuts;
	RAISE NOTICE 'Total inserts Percebuts Det..: %', totalInsertsPercebutsDet;
	RAISE NOTICE '-----------------------------------------------------------------------------';
	RAISE NOTICE 'INFO: END Process.';
END;
$$;