---------------------------------------------------------------------------------------------------------------------
--	PAYROLL PERFORMANCE INFORMATION - gPPI v.3.0 release 20200803												   --	
--  						  																					   --	
--																						   						   --	
--  Created by Gregorio Luque Serrano for DXC.	   								   		   © eSocial DXC Software  --
--  Barcelona, July 10, 2020.	   												   		   █║▌│█│║▌║││█║▌║▌║█║▌│█  --
---------------------------------------------------------------------------------------------------------------------
SET SCHEMA 'esocial';
SET search_path TO esocial;
DO $$
DECLARE
    -- Configurable parameters -------------------
    prestacioId INTEGER := 613;                 -- Ex. 613;
    dretId INTEGER := NULL;                     -- Ex. 172;
	numeroExpedient TEXT := NULL;  				-- Ex. '00006/2020/1003';
    mostrarPrestacioReserva BOOLEAN := TRUE;
    mostrarDretReserva BOOLEAN := TRUE;
    mostrarMoviment BOOLEAN := TRUE;
    mostrarContingutMoviment BOOLEAN := TRUE;
    mostrarMovimentDetall BOOLEAN := TRUE;
    mostrarEfecteMovimentNomina BOOLEAN := TRUE;
    mostrarActivitat BOOLEAN := TRUE;
    mostrarActivitatDetall BOOLEAN := TRUE;
    mostrarDretTeoric BOOLEAN := TRUE;
    mostrarDretTeoricDetall BOOLEAN := TRUE;
    mostrarDeute BOOLEAN := TRUE;
    mostrarDeuteDetall BOOLEAN := TRUE;
    mostrarPercebut BOOLEAN := TRUE;
    mostrarPercebutDetall BOOLEAN := TRUE;
    mostrarOrdenacioPagament BOOLEAN := TRUE;
    mostrarOrdenacioPagamentDetall BOOLEAN := TRUE;
    mostrarOrdenacioLiquidat BOOLEAN := TRUE;    
    ----------------------------------------------        
    cur_PrestacioReserva CURSOR(p_idPrestacio INTEGER) FOR
		SELECT * FROM eco_prestacio_reserva WHERE prestacio_id = p_idPrestacio ORDER BY data_reserva, id;    
    cur_DretReserva CURSOR(p_idDret INTEGER) FOR
		SELECT * FROM eco_dret_reserva WHERE dret_id = p_idDret ORDER BY id;        
    cur_Moviment CURSOR(p_idNomina INTEGER) FOR
        SELECT * FROM eco_moviment WHERE id IN (SELECT DISTINCT moviment_id FROM eco_moviment_detall WHERE nomina_id = p_idNomina);    
    cur_Moviment_Detall CURSOR(p_idNomina INTEGER) FOR
        SELECT * FROM eco_moviment_detall WHERE nomina_id = p_idNomina ORDER BY moviment_id, data_efecte_inicial, id;        
    cur_EfecteMovimentNomina CURSOR(p_idDret INTEGER) FOR
		SELECT * FROM eco_efecte_moviment_nomina WHERE dret_id = p_idDret ORDER BY moviment_detall_id, data_efecte_inici, id;    
    cur_Activitat CURSOR(p_idDret INTEGER) FOR
		SELECT * FROM eco_activitat WHERE dret_id = p_idDret ORDER BY moviment_id, data_efecte_inicial, id;        
    cur_ActivitatDetall CURSOR(p_idNomina INTEGER) FOR
		SELECT * FROM eco_activitat_detall WHERE nomina_id = p_idNomina ORDER BY nomina_mensual_id, activitat_id, data_efecte, id;        
    cur_DretTeoric CURSOR(p_idDret INTEGER) FOR
		SELECT * FROM eco_dret_teoric WHERE dret_id = p_idDret ORDER BY data_efecte, id;
    cur_DretTeoricDetall CURSOR(p_idDret INTEGER) FOR
		SELECT * FROM eco_dret_teoric_detall WHERE dret_id = p_idDret ORDER BY data_efecte, id;                
    cur_Deute CURSOR(p_idNomina INTEGER) FOR
		SELECT * FROM eco_deute WHERE nomina_id = p_idNomina ORDER BY data_creacio, id;        
    cur_DeuteDetall CURSOR(p_idNomina INTEGER) FOR
		SELECT * FROM eco_deute_detall WHERE nomina_id = p_idNomina ORDER BY data_efecte, id;                
    cur_Percebut CURSOR(p_idNomina INTEGER) FOR
		SELECT * FROM eco_percebut WHERE nomina_id = p_idNomina ORDER BY data_efecte, id;        
    cur_PercebutDetall CURSOR(p_idNomina INTEGER) FOR
		SELECT * FROM eco_percebut_detall WHERE nomina_id = p_idNomina ORDER BY data_efecte, id;
    cur_OrdenacioPagament CURSOR(p_idNomina INTEGER) FOR
		SELECT * FROM eco_ordenacio_pagament WHERE nomina_id = p_idNomina ORDER BY nomina_mensual_id, id;        
    cur_OrdenacioPagamentDetall CURSOR(p_idNomina INTEGER) FOR
		SELECT * FROM eco_ordenacio_pagament_detall WHERE nomina_id = p_idNomina ORDER BY nomina_mensual_id, id;
    cur_Liquidat CURSOR(p_idNomina INTEGER) FOR
		SELECT * FROM eco_liquidat WHERE ordenacio_pagament_id IN (SELECT id FROM eco_ordenacio_pagament WHERE nomina_id = p_idNomina)
        ORDER BY ordenacio_pagament_id, data_efecte, data_periode, id;    
    regPrestacioReserva	eco_prestacio_reserva%ROWTYPE;
    regDretReserva eco_dret_reserva%ROWTYPE;
    regMoviment eco_moviment%ROWTYPE;
    regMovimentDetall eco_moviment_detall%ROWTYPE;
    regEfecteMovimentNomina eco_efecte_moviment_nomina%ROWTYPE;
    regActivitat eco_activitat%ROWTYPE;
    regActivitatDetall eco_activitat_detall%ROWTYPE;
    regDretTeoric eco_dret_teoric%ROWTYPE;
    regDretTeoricDetall eco_dret_teoric_detall%ROWTYPE;
    regDeute eco_deute%ROWTYPE;
    regDeuteDetall eco_deute_detall%ROWTYPE;
    regPercebut eco_percebut%ROWTYPE;
    regPercebutDetall eco_percebut_detall%ROWTYPE;    
    regOrdenacioPagament eco_ordenacio_pagament%ROWTYPE;
    regOrdenacioPagamentDetall eco_ordenacio_pagament_detall%ROWTYPE;
    regLiquidat eco_liquidat%ROWTYPE;
    expedientPrestacioId INTEGER;
    personaId INTEGER;
    nominaId INTEGER;
    mostrarNomsColumnes BOOLEAN;
    posicio INTEGER;
    sumaTotal1 DECIMAL; 
    sumaTotal2 DECIMAL;
    sumaTotal3 DECIMAL;
    sumaTotal4 DECIMAL;
    numTotalRegistres INTEGER;
BEGIN
    IF prestacioId IS NULL AND dretId IS NULL AND numeroExpedient IS NULL THEN
        RAISE EXCEPTION 'No s''''ha indicat cap paràmetre'; 
    END IF;
    IF prestacioId IS NULL THEN
        IF dretId IS NOT NULL THEN
            SELECT id INTO prestacioId FROM prestacio WHERE dret_id = dretId;
            IF prestacioId IS NULL THEN 
                RAISE EXCEPTION 'No és possible obtenir la prestació associada a el dret indicat';
            END IF;            
        ELSE
            SELECT id INTO expedientPrestacioId FROM expedient_prestacio WHERE numero_expedient = numeroExpedient;
            IF expedientPrestacioId IS NOT NULL THEN
                SELECT id INTO prestacioId FROM prestacio WHERE expedient_prestacio_id = expedientPrestacioId;
            END IF;
            IF prestacioId IS NULL THEN
                RAISE EXCEPTION 'No és possible obtenir la prestació associada a el número d''''expedient indicat';
            END IF;
        END IF;
    END IF;
    SELECT pre.dret_id, pre.expedient_prestacio_id INTO dretId, expedientPrestacioId FROM prestacio pre WHERE id = prestacioId;
    SELECT epr.persona_id, epr.numero_expedient INTO personaId, numeroExpedient FROM expedient_prestacio epr WHERE id = expedientPrestacioId;
    SELECT dre.nomina_id INTO nominaId FROM eco_dret dre WHERE id = dretId;
    RAISE NOTICE '----------------------------------------------------------------------------------------------------------------------------';
	RAISE NOTICE ' Script eSocial gPPI v.3.0 release 20200803';
    RAISE NOTICE '';
    RAISE NOTICE ' Payroll Performance Information created by gluques.';    
    RAISE NOTICE ' (c) 2020 - eSocial DXC Software.';
	RAISE NOTICE '';
	RAISE NOTICE '    Dades Prestació:';
    RAISE NOTICE '      Prestació Id..: %', prestacioId;		
    RAISE NOTICE '      Num.Expedient.: %', numeroExpedient;
    RAISE NOTICE '      Persona Id....: %', personaId;
    RAISE NOTICE '      Dret Id.......: %', dretId;
    RAISE NOTICE '      Nòmina Id.....: %', nominaId;
    RAISE NOTICE '';
    RAISE NOTICE '    Data execució script: %', (SELECT (TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS')));	
	RAISE NOTICE '----------------------------------------------------------------------------------------------------------------------------';    
    ----------------------------------------------
    -- eco_prestacio_reserva
    ----------------------------------------------
    IF (mostrarPrestacioReserva) THEN
        mostrarNomsColumnes := TRUE;
        sumaTotal1 := 0;
        sumaTotal2 := 0;
        numTotalRegistres := 0;
        OPEN cur_PrestacioReserva(prestacioId);   
        LOOP	
          FETCH cur_PrestacioReserva INTO regPrestacioReserva;	
          EXIT WHEN NOT FOUND;
            IF (mostrarNomsColumnes) THEN
                RAISE NOTICE 'Prestació Reserva:';
                RAISE NOTICE '';
                RAISE NOTICE '  Id      Reserva     Data Reserva         Imp.Reservat  Imp.Recuperat';
                RAISE NOTICE '  ------  ----------  -------------------  ------------  -------------';
                mostrarNomsColumnes := FALSE;
            END IF;
            RAISE NOTICE '  %  %  %  %  %', 
                         RPAD(TO_CHAR(regPrestacioReserva.id, 'fm9999999'), 6, ' '),
                         RPAD(TO_CHAR(regPrestacioReserva.reserva_id, 'fm999999'), 10, ' '),
                         TO_CHAR(regPrestacioReserva.data_reserva, 'DD-MM-YYYY HH24:MI:SS'),
                         LPAD(TO_CHAR(regPrestacioReserva.import_reservat, 'fm99999990.00'), 12, ' '),
                         LPAD(TO_CHAR(regPrestacioReserva.import_recuperat, 'fm99999990.00'), 13, ' ');
            sumaTotal1 := sumaTotal1 + regPrestacioReserva.import_reservat;
            sumaTotal2 := sumaTotal2 + regPrestacioReserva.import_recuperat;
            numTotalRegistres := numTotalRegistres + 1;
        END LOOP;
        CLOSE cur_PrestacioReserva;            
        IF (mostrarNomsColumnes) THEN
            RAISE NOTICE 'Prestació Reserva: sense registres';
        ELSE
            RAISE NOTICE '                                           ------------  -------------';
            RAISE NOTICE '  %  %', 
                         LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 53, ' '),
                         LPAD(TO_CHAR(sumaTotal2, 'fm99999990.00'), 13, ' ');
            IF (numTotalRegistres > 1) THEN
                RAISE NOTICE '  % registres.', numTotalRegistres;
            ELSE 
                RAISE NOTICE '  1 registre.';
            END IF;
        END IF;
    END IF;
    IF (dretId IS NOT NULL) THEN 
        ----------------------------------------------
        -- eco_dret_reserva
        ----------------------------------------------
        IF (mostrarDretReserva) THEN
            RAISE NOTICE '';        
            mostrarNomsColumnes := TRUE;
            numTotalRegistres := 0;
            OPEN cur_DretReserva(dretId);   
            LOOP	
              FETCH cur_DretReserva INTO regDretReserva;	
              EXIT WHEN NOT FOUND;
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Dret Reserva:';
                    RAISE NOTICE '';
                    RAISE NOTICE '  Id      Imp.Reservat  Imp.Ordenat  Imp.Trames  Imp.Pagat  Imp.Recuperat  Imp.Restant'; 
                    RAISE NOTICE '  ------  ------------  -----------  ----------  ---------  -------------  -----------';
                    mostrarNomsColumnes := FALSE;
                END IF;
                RAISE NOTICE '  %  %  %  %  %  %  %', 
                             RPAD(TO_CHAR(regDretReserva.id, 'fm9999999'), 6, ' '),                             
                             LPAD(TO_CHAR(regDretReserva.import_reservat, 'fm99999990.00'), 12, ' '),
                             LPAD(TO_CHAR(regDretReserva.import_ordenat, 'fm99999990.00'), 11, ' '),
                             LPAD(TO_CHAR(regDretReserva.import_trames, 'fm99999990.00'), 10, ' '),
                             LPAD(TO_CHAR(regDretReserva.import_pagat, 'fm99999990.00'), 9, ' '),
                             LPAD(TO_CHAR(regDretReserva.import_recuperat, 'fm99999990.00'), 13, ' '),
                             LPAD(TO_CHAR(regDretReserva.import_restant, 'fm99999990.00'), 11, ' ');
                numTotalRegistres := numTotalRegistres + 1;
            END LOOP;
            CLOSE cur_DretReserva;
            IF (mostrarNomsColumnes) THEN
                RAISE NOTICE 'Dret Reserva: sense registres';
            ELSE
                RAISE NOTICE '';
                IF (numTotalRegistres > 1) THEN
                    RAISE NOTICE '  % registres.', numTotalRegistres;
                ELSE 
                    RAISE NOTICE '  1 registre.';
                END IF;
            END IF;
        END IF;
        IF (nominaId IS NOT NULL) THEN 
            ----------------------------------------------
            -- eco_moviment
            ----------------------------------------------
            IF (mostrarMoviment) THEN
                RAISE NOTICE '';        
                mostrarNomsColumnes := TRUE;
                numTotalRegistres := 0;
                OPEN cur_Moviment(nominaId);
                LOOP	
                  FETCH cur_Moviment INTO regMoviment;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE NOTICE 'Moviment:';
                        RAISE NOTICE '';
                        RAISE NOTICE '  Id      Expedient  Procediment  Tramit  Data creació         Estat '; 
                        RAISE NOTICE '  ------  ---------  -----------  ------  -------------------  ------------';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE NOTICE '  %  %  %  %  %  %', 
                                 RPAD(TO_CHAR(regMoviment.id, 'fm9999999'), 6, ' '), 
                                 RPAD(TO_CHAR(regMoviment.expedient_id, 'fm999999'), 9, ' '),
                                 RPAD(TO_CHAR(regMoviment.procediment_id, 'fm999999'), 11, ' '),
                                 RPAD(TO_CHAR(regMoviment.tramit_id, 'fm999999'), 6, ' '),
                                 TO_CHAR(regMoviment.data_creacio_moviment, 'DD-MM-YYYY HH24:MI:SS'),
                                 regMoviment.estat_moviment;
                    numTotalRegistres := numTotalRegistres + 1;
                END LOOP;
                CLOSE cur_Moviment;            
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Moviment: sense registres';
                ELSE
                    RAISE NOTICE '';
                    IF (numTotalRegistres > 1) THEN
                        RAISE NOTICE '  % registres.', numTotalRegistres;
                    ELSE 
                        RAISE NOTICE '  1 registre.';
                    END IF;
                    IF (mostrarContingutMoviment) THEN
                        OPEN cur_Moviment(nominaId);
                        LOOP	
                          FETCH cur_Moviment INTO regMoviment;
                          EXIT WHEN NOT FOUND;
                            RAISE NOTICE '';
                            RAISE NOTICE '  Contingut Moviment..: %', regMoviment.id;
                            RAISE NOTICE '';
                            posicio := 1;
                            WHILE (posicio < character_length(regMoviment.contingut_moviment)) LOOP
                                IF ((posicio + 79) > character_length(regMoviment.contingut_moviment)) THEN
                                    RAISE NOTICE '        %', substring(regMoviment.contingut_moviment FROM posicio FOR character_length(regMoviment.contingut_moviment));
                                ELSE
                                    RAISE NOTICE '        %', substring(regMoviment.contingut_moviment FROM posicio FOR 79);
                                END IF;
                                posicio := posicio + 79;
                            END LOOP;
                          EXIT WHEN NOT FOUND;
                        END LOOP;
                        CLOSE cur_Moviment;
                    END IF;
                END IF;
            END IF;
            ----------------------------------------------
            -- eco_moviment_detall
            ----------------------------------------------
            IF (mostrarMovimentDetall) THEN
                RAISE NOTICE '';        
                mostrarNomsColumnes := TRUE;   
                numTotalRegistres := 0;            
                OPEN cur_Moviment_Detall(nominaId);
                LOOP	
                  FETCH cur_Moviment_Detall INTO regMovimentDetall;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE NOTICE 'Moviment Detall:';
                        RAISE NOTICE '';
                        RAISE NOTICE '  Id      Rcd_Crt_Ts           Moviment  Data Efecte Inicial  Data Efecte Final    Import    '; 
                        RAISE NOTICE '  ------  -------------------  --------  -------------------  -------------------  ----------';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE NOTICE '  %  %  %  %  %  %', 
                                 RPAD(TO_CHAR(regMovimentDetall.id, 'fm9999999'), 6, ' '), 
                                 TO_CHAR(regMovimentDetall.rcd_crt_ts, 'DD-MM-YYYY HH24:MI:SS'),
                                 RPAD(TO_CHAR(regMovimentDetall.moviment_id, 'fm9999999'), 8, ' '),
                                 TO_CHAR(regMovimentDetall.data_efecte_inicial, 'DD-MM-YYYY HH24:MI:SS'),
                                 TO_CHAR(regMovimentDetall.data_efecte_final, 'DD-MM-YYYY HH24:MI:SS'),
                                 CASE WHEN regMovimentDetall.data_efecte_final IS NULL 
                                    THEN LPAD(TO_CHAR(regMovimentDetall.import_moviment, 'fm99999990.00'), 19, ' ') 
                                    ELSE TO_CHAR(regMovimentDetall.import_moviment, 'fm99999990.00') END;
                    numTotalRegistres := numTotalRegistres + 1;
                END LOOP;
                CLOSE cur_Moviment_Detall;            
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Moviment Detall: sense registres';
                ELSE 
                    RAISE NOTICE '';
                    IF (numTotalRegistres > 1) THEN
                        RAISE NOTICE '  % registres.', numTotalRegistres;
                    ELSE 
                        RAISE NOTICE '  1 registre.';
                    END IF;
                END IF;            
            END IF;
        END IF;
        ----------------------------------------------
        -- eco_efecte_moviment_nomina
        ----------------------------------------------
        IF (mostrarEfecteMovimentNomina) THEN
            RAISE NOTICE '';        
            mostrarNomsColumnes := TRUE;
            numTotalRegistres := 0;
            OPEN cur_EfecteMovimentNomina(dretId);   
            LOOP	
              FETCH cur_EfecteMovimentNomina INTO regEfecteMovimentNomina;	
              EXIT WHEN NOT FOUND;
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Efecte Moviment Nòmina:';
                    RAISE NOTICE '';
                    RAISE NOTICE '  Id      Mov.Detall  Tipus  Data Inici           Data Fi              Imp.Anterior  Imp.Actual  Diferencial'; 
                    RAISE NOTICE '  ------  ----------  -----  -------------------  -------------------  ------------  ----------  -----------';
                    mostrarNomsColumnes := FALSE;
                END IF;
                RAISE NOTICE '  %  %  %  %  %  %  %  %', 
                             RPAD(TO_CHAR(regEfecteMovimentNomina.id, 'fm9999999'), 6, ' '), 
                             RPAD(TO_CHAR(regEfecteMovimentNomina.moviment_detall_id, 'fm999999'), 10, ' '),
                             RPAD(TO_CHAR(regEfecteMovimentNomina.tipus_id, 'fm99'), 5, ' '),
                             TO_CHAR(regEfecteMovimentNomina.data_efecte_inici, 'DD-MM-YYYY HH24:MI:SS'),
                             CASE WHEN regEfecteMovimentNomina.data_efecte_fi IS NULL THEN RPAD('NULL', 19, ' ') 
                                ELSE TO_CHAR(regEfecteMovimentNomina.data_efecte_fi, 'DD-MM-YYYY HH24:MI:SS') END,                              
                             CASE WHEN regEfecteMovimentNomina.import_anterior IS NULL THEN LPAD('NULL', 12, ' ') 
                                ELSE LPAD(TO_CHAR(regEfecteMovimentNomina.import_anterior, 'fm99999990.00'), 12, ' ') END,							 
                             LPAD(TO_CHAR(regEfecteMovimentNomina.import_actual, 'fm99999990.00'), 10, ' '),
                             CASE WHEN regEfecteMovimentNomina.diferencial IS NULL THEN LPAD('NULL', 11, ' ') 
                                ELSE LPAD(TO_CHAR(regEfecteMovimentNomina.diferencial, 'fm99999990.00'), 11, ' ') END;
                numTotalRegistres := numTotalRegistres + 1;
            END LOOP;
            CLOSE cur_EfecteMovimentNomina;
            IF (mostrarNomsColumnes) THEN
                RAISE NOTICE 'Efecte Moviment Nòmina: sense registres';
            ELSE
                RAISE NOTICE '';
                IF (numTotalRegistres > 1) THEN
                    RAISE NOTICE '  % registres.', numTotalRegistres;
                ELSE 
                    RAISE NOTICE '  1 registre.';
                END IF;
            END IF;
        END IF;
        ----------------------------------------------
        -- eco_activitat
        ----------------------------------------------
        IF (mostrarActivitat) THEN
            RAISE NOTICE '';        
            mostrarNomsColumnes := TRUE;
            numTotalRegistres := 0;
            OPEN cur_Activitat(dretId);   
            LOOP	
              FETCH cur_Activitat INTO regActivitat;	
              EXIT WHEN NOT FOUND;
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Activitat:';
                    RAISE NOTICE '';
                    RAISE NOTICE '  Id      Moviment  Data Inici           Data Fi              Quantitat  Estat  Arxivat  Modalitat'; 
                    RAISE NOTICE '  ------  --------  -------------------  -------------------  ---------  -----  -------  ---------';
                    mostrarNomsColumnes := FALSE;
                END IF;
                RAISE NOTICE '  %  %  %  %  %  %  %  %', 
                             RPAD(TO_CHAR(regActivitat.id, 'fm9999999'), 6, ' '), 
                             RPAD(TO_CHAR(regActivitat.moviment_id, 'fm999999'), 8, ' '),                             
                             TO_CHAR(regActivitat.data_efecte_inicial, 'DD-MM-YYYY HH24:MI:SS'),
                             CASE WHEN regActivitat.data_efecte_final IS NULL THEN RPAD('NULL', 19, ' ') 
                                ELSE TO_CHAR(regActivitat.data_efecte_final, 'DD-MM-YYYY HH24:MI:SS') END,                              
                             LPAD(TO_CHAR(regActivitat.quantitat, 'fm99999990.00'), 9, ' '),							 
                             LPAD(regActivitat.estat_activitat, 1, ' '),
                             CASE WHEN regActivitat.arxivat THEN LPAD('TRUE', 8, ' ') ELSE LPAD('FALSE', 9, ' ') END,
                             CASE WHEN regActivitat.arxivat THEN LPAD(TO_CHAR(regActivitat.pagament_modalitat_id, 'fm9999999'), 4, ' ') 
                                ELSE LPAD(TO_CHAR(regActivitat.pagament_modalitat_id, 'fm9999999'), 3, ' ') END;
                numTotalRegistres := numTotalRegistres + 1;
            END LOOP;
            CLOSE cur_Activitat;
            IF (mostrarNomsColumnes) THEN
                RAISE NOTICE 'Activitat: sense registres';
            ELSE
                RAISE NOTICE '';
                IF (numTotalRegistres > 1) THEN
                    RAISE NOTICE '  % registres.', numTotalRegistres;
                ELSE 
                    RAISE NOTICE '  1 registre.';
                END IF;
            END IF;
        END IF;    
        IF (nominaId IS NOT NULL) THEN 
            ----------------------------------------------
            -- eco_activitat_detall
            ----------------------------------------------
            IF (mostrarActivitatDetall) THEN
                RAISE NOTICE '';        
                mostrarNomsColumnes := TRUE;
                numTotalRegistres := 0;
                sumaTotal1 := 0;
                OPEN cur_ActivitatDetall(nominaId);   
                LOOP	
                  FETCH cur_ActivitatDetall INTO regActivitatDetall;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE NOTICE 'Activitat Detall:';
                        RAISE NOTICE '';
                        RAISE NOTICE '  Id      N.Mensual  Activitat  Data Efecte          Quantitat  Modalitat  T.Pagament'; 
                        RAISE NOTICE '  ------  ---------  ---------  -------------------  ---------  ---------  ----------';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE NOTICE '  %  %  %  %  %  %  %', 
                                 RPAD(TO_CHAR(regActivitatDetall.id, 'fm9999999'), 6, ' '), 
                                 RPAD(TO_CHAR(regActivitatDetall.nomina_mensual_id, 'fm999999'), 9, ' '),
                                 RPAD(TO_CHAR(regActivitatDetall.activitat_id, 'fm999999'), 9, ' '),                                 
                                 TO_CHAR(regActivitatDetall.data_efecte, 'DD-MM-YYYY HH24:MI:SS'),
                                 LPAD(TO_CHAR(regActivitatDetall.quantitat, 'fm99999990.00'), 9, ' '),
                                 LPAD(TO_CHAR(regActivitatDetall.pagament_modalitat_id, 'fm9999999'), 1, ' '),
                                 LPAD(TO_CHAR(regActivitatDetall.pagament_tipus_id, 'fm9999999'), 9, ' ');
                    sumaTotal1 := sumaTotal1 + regActivitatDetall.quantitat;
                    numTotalRegistres := numTotalRegistres + 1;
                END LOOP;
                CLOSE cur_ActivitatDetall;
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Activitat Detall: sense registres';
                ELSE
                    RAISE NOTICE '                                                     ---------                       ';
                    RAISE NOTICE '  %', 
                                 LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 60, ' ');
                    IF (numTotalRegistres > 1) THEN
                        RAISE NOTICE '  % registres.', numTotalRegistres;
                    ELSE 
                        RAISE NOTICE '  1 registre.';
                    END IF;
                END IF;
            END IF;
        END IF;
        ----------------------------------------------
        -- eco_dret_teoric
        ----------------------------------------------
        IF (mostrarDretTeoric) THEN
            RAISE NOTICE '';        
            mostrarNomsColumnes := TRUE;
            numTotalRegistres := 0;
            sumaTotal1 := 0;
            OPEN cur_DretTeoric(dretId);   
            LOOP	
              FETCH cur_DretTeoric INTO regDretTeoric;	
              EXIT WHEN NOT FOUND;
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Dret Teòric:';
                    RAISE NOTICE '';
                    RAISE NOTICE '  Id      Data Efecte          Quantitat  Data Execució'; 
                    RAISE NOTICE '  ------  -------------------  ---------  -------------------';
                    mostrarNomsColumnes := FALSE;
                END IF;
                RAISE NOTICE '  %  %  %  %', 
                             RPAD(TO_CHAR(regDretTeoric.id, 'fm9999999'), 6, ' '),                                                              
                             TO_CHAR(regDretTeoric.data_efecte, 'DD-MM-YYYY HH24:MI:SS'),
                             LPAD(TO_CHAR(regDretTeoric.quantitat, 'fm99999990.00'), 9, ' '),
                             TO_CHAR(regDretTeoric.data_execucio, 'DD-MM-YYYY HH24:MI:SS');
                sumaTotal1 := sumaTotal1 + regDretTeoric.quantitat;
                numTotalRegistres := numTotalRegistres + 1;
            END LOOP;
            CLOSE cur_DretTeoric;
            IF (mostrarNomsColumnes) THEN
                RAISE NOTICE 'Dret Teòric: sense registres';
            ELSE            
                RAISE NOTICE '                               ---------';
                RAISE NOTICE '  %', 
                             LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 38, ' ');
                IF (numTotalRegistres > 1) THEN
                    RAISE NOTICE '  % registres.', numTotalRegistres;
                ELSE 
                    RAISE NOTICE '  1 registre.';
                END IF;
            END IF;
        END IF;
        ----------------------------------------------
        -- eco_dret_teoric_detall
        ----------------------------------------------
        IF (mostrarDretTeoricDetall) THEN
            RAISE NOTICE '';        
            mostrarNomsColumnes := TRUE;
            numTotalRegistres := 0;
            sumaTotal1 := 0;
            OPEN cur_DretTeoricDetall(dretId);   
            LOOP	
              FETCH cur_DretTeoricDetall INTO regDretTeoricDetall;	
              EXIT WHEN NOT FOUND;
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Dret Teòric Detall:';
                    RAISE NOTICE '';
                    RAISE NOTICE '  Id      Efecte  Data Efecte          Quantitat  Modalitat  T.Pagament'; 
                    RAISE NOTICE '  ------  ------  -------------------  ---------  ---------  ----------  ';
                    mostrarNomsColumnes := FALSE;
                END IF;
                RAISE NOTICE '  %  %  %  %  %  %', 
                             RPAD(TO_CHAR(regDretTeoricDetall.id, 'fm9999999'), 6, ' '),               
                             RPAD(TO_CHAR(regDretTeoricDetall.efecte_moviment_id, 'fm9999999'), 6, ' '),
                             TO_CHAR(regDretTeoricDetall.data_efecte, 'DD-MM-YYYY HH24:MI:SS'),
                             LPAD(TO_CHAR(regDretTeoricDetall.quantitat, 'fm99999990.00'), 9, ' '),
                             LPAD(TO_CHAR(regDretTeoricDetall.modalitat_pagament_id, 'fm9999999'), 1, ' '),
                             CASE WHEN regDretTeoricDetall.tipus_pagament_id IS NULL THEN LPAD('NULL', 12, ' ')
                                ELSE LPAD(TO_CHAR(regDretTeoricDetall.tipus_pagament_id, 'fm9999999'), 9, ' ') END;
                sumaTotal1 := sumaTotal1 + regDretTeoricDetall.quantitat;
                numTotalRegistres := numTotalRegistres + 1;
            END LOOP;
            CLOSE cur_DretTeoricDetall;
            IF (mostrarNomsColumnes) THEN
                RAISE NOTICE 'Dret Teòric Detall: sense registres';
            ELSE                        
                RAISE NOTICE '                                       ---------';
                RAISE NOTICE '  %', 
                             LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 46, ' ');
                IF (numTotalRegistres > 1) THEN
                    RAISE NOTICE '  % registres.', numTotalRegistres;
                ELSE 
                    RAISE NOTICE '  1 registre.';
                END IF;
            END IF;
        END IF;    
        IF (nominaId IS NOT NULL) THEN 
            ----------------------------------------------
            -- eco_deute
            ----------------------------------------------
            IF (mostrarDeute) THEN
                RAISE NOTICE '';        
                mostrarNomsColumnes := TRUE;
                numTotalRegistres := 0;            
                OPEN cur_Deute(nominaId);   
                LOOP	
                  FETCH cur_Deute INTO regDeute;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE NOTICE 'Deute:';
                        RAISE NOTICE '';
                        RAISE NOTICE '  Id      Data Creacio         Quantitat  Estat  Q.Negociada  Q.Condonada  Q.Aplicada  Data Pagament Inici  Data Pagament Fi'; 
                        RAISE NOTICE '  ------  -------------------  ---------  -----  -----------  -----------  ----------  -------------------  -------------------';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE NOTICE '  %  %  %  %  %  %  %  %  %', 
                                 RPAD(TO_CHAR(regDeute.id, 'fm9999999'), 6, ' '),
                                 TO_CHAR(regDeute.data_creacio, 'DD-MM-YYYY HH24:MI:SS'),
                                 LPAD(TO_CHAR(regDeute.quantitat, 'fm99999990.00'), 9, ' '),
                                 LPAD(TO_CHAR(regDeute.estat_id, 'fm9999999'), 1, ' '), 
                                 CASE WHEN regDeute.quantitat_negociada IS NULL THEN LPAD('NULL', 15, ' ')
                                    ELSE LPAD(TO_CHAR(regDeute.quantitat_negociada, 'fm99999990.00'), 15, ' ') END,
                                 CASE WHEN regDeute.quantitat_condonada IS NULL THEN LPAD('NULL', 11, ' ')
                                    ELSE LPAD(TO_CHAR(regDeute.quantitat_condonada, 'fm99999990.00'), 11, ' ') END,
                                 CASE WHEN regDeute.quantitat_aplicada IS NULL THEN LPAD('NULL', 10, ' ')
                                    ELSE LPAD(TO_CHAR(regDeute.quantitat_aplicada, 'fm99999990.00'), 10, ' ') END,	
                                 CASE WHEN regDeute.data_pagament_inici IS NULL THEN RPAD('NULL', 19, ' ')
                                    ELSE TO_CHAR(regDeute.data_pagament_inici, 'DD-MM-YYYY HH24:MI:SS') END,
                                 CASE WHEN regDeute.data_pagament_inici IS NULL THEN 'NULL'
                                    ELSE TO_CHAR(regDeute.data_pagament_fi, 'DD-MM-YYYY HH24:MI:SS') END;
                    numTotalRegistres := numTotalRegistres + 1;
                END LOOP;
                CLOSE cur_Deute;
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Deute: sense registres';
                ELSE
                    RAISE NOTICE '';
                    IF (numTotalRegistres > 1) THEN
                        RAISE NOTICE '  % registres.', numTotalRegistres;
                    ELSE 
                        RAISE NOTICE '  1 registre.';
                    END IF;
                END IF;
            END IF;
            ----------------------------------------------
            -- eco_deute_detall
            ----------------------------------------------
            IF (mostrarDeuteDetall) THEN
                RAISE NOTICE '';        
                mostrarNomsColumnes := TRUE;
                numTotalRegistres := 0;
                sumaTotal1 := 0;
                sumaTotal2 := 0;
                sumaTotal3 := 0;
                sumaTotal4 := 0;
                OPEN cur_DeuteDetall(nominaId);   
                LOOP	
                  FETCH cur_DeuteDetall INTO regDeuteDetall;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE NOTICE 'Deute Detall:';
                        RAISE NOTICE '';
                        RAISE NOTICE '  Id      Efecte  Data Efecte          Quantitat  Q.Negociada  Q.Condonada  Q.Aplicada  Data Execució'; 
                        RAISE NOTICE '  ------  ------  -------------------  ---------  -----------  -----------  ----------  -------------------';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE NOTICE '  %  %  %  %  %  %  %  %', 
                                 RPAD(TO_CHAR(regDeuteDetall.id, 'fm9999999'), 6, ' '),
                                 RPAD(TO_CHAR(regDeuteDetall.efecte_moviment_nomina_id, 'fm9999999'), 6, ' '),
                                 TO_CHAR(regDeuteDetall.data_efecte, 'DD-MM-YYYY HH24:MI:SS'),
                                 LPAD(TO_CHAR(regDeuteDetall.quantitat, 'fm99999990.00'), 9, ' '),
                                 CASE WHEN regDeuteDetall.quantitat_negociada IS NULL THEN LPAD('NULL', 11, ' ')
                                    ELSE LPAD(TO_CHAR(regDeuteDetall.quantitat_negociada, 'fm99999990.00'), 11, ' ') END,
                                 CASE WHEN regDeuteDetall.quantitat_condonada IS NULL THEN LPAD('NULL', 11, ' ')
                                    ELSE LPAD(TO_CHAR(regDeuteDetall.quantitat_condonada, 'fm99999990.00'), 11, ' ') END,
                                 CASE WHEN regDeuteDetall.quantitat_aplicada IS NULL THEN LPAD('NULL', 10, ' ')
                                    ELSE LPAD(TO_CHAR(regDeuteDetall.quantitat_aplicada, 'fm99999990.00'), 10, ' ') END,
                                 CASE WHEN regDeuteDetall.data_execucio IS NULL THEN 'NULL'
                                    ELSE TO_CHAR(regDeuteDetall.data_execucio, 'DD-MM-YYYY HH24:MI:SS') END;
                    IF regDeuteDetall.quantitat IS NOT NULL THEN
                        sumaTotal1 := sumaTotal1 + regDeuteDetall.quantitat;
                    END IF;					
                    IF regDeuteDetall.quantitat_negociada IS NOT NULL THEN
                        sumaTotal2 := sumaTotal2 + regDeuteDetall.quantitat_negociada;
                    END IF;					
                    IF regDeuteDetall.quantitat_condonada IS NOT NULL THEN
                        sumaTotal3 := sumaTotal3 + regDeuteDetall.quantitat_condonada;
                    END IF;					
                    IF regDeuteDetall.quantitat_aplicada IS NOT NULL THEN
                        sumaTotal4 := sumaTotal4 + regDeuteDetall.quantitat_aplicada;
                    END IF;				
                    numTotalRegistres := numTotalRegistres + 1;
                END LOOP;
                CLOSE cur_DeuteDetall;
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Deute Detall: sense registres';
                ELSE
                    RAISE NOTICE '                                       ---------  -----------  -----------  ----------';
                    RAISE NOTICE '  %  %  %  %', 
                                 LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 46, ' '),
                                 LPAD(TO_CHAR(sumaTotal2, 'fm99999990.00'), 11, ' '),
                                 LPAD(TO_CHAR(sumaTotal3, 'fm99999990.00'), 11, ' '),
                                 LPAD(TO_CHAR(sumaTotal4, 'fm99999990.00'), 10, ' ');
                    IF (numTotalRegistres > 1) THEN
                        RAISE NOTICE '  % registres.', numTotalRegistres;
                    ELSE 
                        RAISE NOTICE '  1 registre.';
                    END IF;
                END IF;
            END IF;
            ----------------------------------------------
            -- eco_percebut
            ----------------------------------------------
            IF (mostrarPercebut) THEN
                RAISE NOTICE '';        
                mostrarNomsColumnes := TRUE;
                numTotalRegistres := 0;            
                sumaTotal1 := 0;
                OPEN cur_Percebut(nominaId);   
                LOOP	
                  FETCH cur_Percebut INTO regPercebut;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE NOTICE 'Percebut:';
                        RAISE NOTICE '';
                        RAISE NOTICE '  Id      Rcd_Crt_Ts           Data Efecte          Imp.Percebut'; 
                        RAISE NOTICE '  ------  -------------------  -------------------  ------------';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE NOTICE '  %  %  %  %', 
                                 RPAD(TO_CHAR(regPercebut.id, 'fm9999999'), 6, ' '),
                                 TO_CHAR(regPercebut.rcd_crt_ts, 'DD-MM-YYYY HH24:MI:SS'),
                                 TO_CHAR(regPercebut.data_efecte, 'DD-MM-YYYY HH24:MI:SS'),
                                 LPAD(TO_CHAR(regPercebut.import_percebut, 'fm99999990.00'), 12, ' ');
                    sumaTotal1 := sumaTotal1 + regPercebut.import_percebut;
                    numTotalRegistres := numTotalRegistres + 1;
                END LOOP;
                CLOSE cur_Percebut;            
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Percebut: sense registres';
                ELSE                        
                    RAISE NOTICE '                                                    ------------';
                    RAISE NOTICE '  %', 
                                 LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 62, ' ');
                    IF (numTotalRegistres > 1) THEN
                        RAISE NOTICE '  % registres.', numTotalRegistres;
                    ELSE 
                        RAISE NOTICE '  1 registre.';
                    END IF;
                END IF;
            END IF;
            ----------------------------------------------
            -- eco_percebut_detall
            ----------------------------------------------
            IF (mostrarPercebutDetall) THEN
                RAISE NOTICE '';        
                mostrarNomsColumnes := TRUE;
                numTotalRegistres := 0;
                sumaTotal1 := 0;            
                OPEN cur_PercebutDetall(nominaId);   
                LOOP	
                  FETCH cur_PercebutDetall INTO regPercebutDetall;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE NOTICE 'Percebut Detall:';
                        RAISE NOTICE '';
                        RAISE NOTICE '  Id      Act.Detall  Data Efecte          Quantitat  Modalitat  T.Pagament  Data Execució'; 
                        RAISE NOTICE '  ------  ----------  -------------------  ---------  ---------  ----------  -------------------';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE NOTICE '  %  %  %  %  %  %  %', 
                                 RPAD(TO_CHAR(regPercebutDetall.id, 'fm9999999'), 6, ' '),
                                 RPAD(TO_CHAR(regPercebutDetall.activitat_detall_id, 'fm9999999'), 10, ' '),                             
                                 TO_CHAR(regPercebutDetall.data_efecte, 'DD-MM-YYYY HH24:MI:SS'),
                                 LPAD(TO_CHAR(regPercebutDetall.quantitat, 'fm99999990.00'), 9, ' '),
                                 LPAD(TO_CHAR(regPercebutDetall.modalitat_pagament_id, 'fm9999999'), 1, ' '),
                                 LPAD(TO_CHAR(regPercebutDetall.tipus_pagament_id, 'fm9999999'), 9, ' '),
                                 CASE WHEN regPercebutDetall.data_execucio IS NULL THEN LPAD('NULL', 28, ' ')
                                    ELSE LPAD(TO_CHAR(regPercebutDetall.data_execucio, 'DD-MM-YYYY HH24:MI:SS'), 28, ' ') END;
                    sumaTotal1 := sumaTotal1 + regPercebutDetall.quantitat;
                    numTotalRegistres := numTotalRegistres + 1;
                END LOOP;
                CLOSE cur_PercebutDetall;            
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Percebut Detall: sense registres';
                ELSE                                        
                    RAISE NOTICE '                                           ---------';
                    RAISE NOTICE '  %',
                                 LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 50, ' ');
                    IF (numTotalRegistres > 1) THEN
                        RAISE NOTICE '  % registres.', numTotalRegistres;
                    ELSE 
                        RAISE NOTICE '  1 registre.';
                    END IF;
                END IF;
            END IF;
            ----------------------------------------------
            -- eco_ordenacio_pagament
            ----------------------------------------------
            IF (mostrarOrdenacioPagament) THEN
                RAISE NOTICE '';        
                mostrarNomsColumnes := TRUE;
                numTotalRegistres := 0;            
                sumaTotal1 := 0;
                OPEN cur_OrdenacioPagament(nominaId);   
                LOOP	
                  FETCH cur_OrdenacioPagament INTO regOrdenacioPagament;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE NOTICE 'Ordenació Pagament:';
                        RAISE NOTICE '';
                        RAISE NOTICE '  Id      Rcd_Crt_Ts           N.Mensual  Quantitat'; 
                        RAISE NOTICE '  ------  -------------------  ---------  ---------';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE NOTICE '  %  %  %  %', 
                                 RPAD(TO_CHAR(regOrdenacioPagament.id, 'fm9999999'), 6, ' '),
                                 TO_CHAR(regOrdenacioPagament.rcd_crt_ts, 'DD-MM-YYYY HH24:MI:SS'),                             
                                 RPAD(TO_CHAR(regOrdenacioPagament.nomina_mensual_id, 'fm9999999'), 9, ' '),
                                 LPAD(TO_CHAR(regOrdenacioPagament.quantitat, 'fm99999990.00'), 8, ' ');
                    sumaTotal1 := sumaTotal1 + regOrdenacioPagament.quantitat;
                    numTotalRegistres := numTotalRegistres + 1;
                END LOOP;
                CLOSE cur_OrdenacioPagament; 
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Ordenació Pagament: sense registres';
                ELSE                                        
                    RAISE NOTICE '                                          ---------';
                    RAISE NOTICE '  %',
                                 LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 48, ' ');
                    IF (numTotalRegistres > 1) THEN
                        RAISE NOTICE '  % registres.', numTotalRegistres;
                    ELSE 
                        RAISE NOTICE '  1 registre.';
                    END IF;                             
                END IF;
            END IF;
            ----------------------------------------------
            -- eco_ordenacio_pagament_detall
            ----------------------------------------------
            IF (mostrarOrdenacioPagamentDetall) THEN
                RAISE NOTICE '';        
                mostrarNomsColumnes := TRUE;
                numTotalRegistres := 0;
                sumaTotal1 := 0;
                OPEN cur_OrdenacioPagamentDetall(nominaId);   
                LOOP	
                  FETCH cur_OrdenacioPagamentDetall INTO regOrdenacioPagamentDetall;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE NOTICE 'Ordenació Pagament Detall:';
                        RAISE NOTICE '';
                        RAISE NOTICE '  Id      Rcd_Crt_Ts           N.Mensual  Quantitat  Act.Detall'; 
                        RAISE NOTICE '  ------  -------------------  ---------  ---------  ----------';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE NOTICE '  %  %  %  %  %', 
                                 RPAD(TO_CHAR(regOrdenacioPagamentDetall.id, 'fm9999999'), 6, ' '),
                                 TO_CHAR(regOrdenacioPagamentDetall.rcd_crt_ts, 'DD-MM-YYYY HH24:MI:SS'),                             
                                 RPAD(TO_CHAR(regOrdenacioPagamentDetall.nomina_mensual_id, 'fm9999999'), 9, ' '),
                                 LPAD(TO_CHAR(regOrdenacioPagamentDetall.quantitat, 'fm99999990.00'), 9, ' '),
                                 RPAD(TO_CHAR(regOrdenacioPagamentDetall.activitat_detall_id, 'fm9999999'), 6, ' ');
                    sumaTotal1 := sumaTotal1 + regOrdenacioPagamentDetall.quantitat;
                    numTotalRegistres := numTotalRegistres + 1;
                END LOOP;
                CLOSE cur_OrdenacioPagamentDetall;
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Ordenació Pagament Detall: sense registres';
                ELSE                                        
                    RAISE NOTICE '                                          ---------';
                    RAISE NOTICE '  %',
                                 LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 49, ' ');
                    IF (numTotalRegistres > 1) THEN
                        RAISE NOTICE '  % registres.', numTotalRegistres;
                    ELSE 
                        RAISE NOTICE '  1 registre.';
                    END IF;
                END IF;
            END IF;
            ----------------------------------------------
            -- eco_liquidat
            ----------------------------------------------
            IF (mostrarOrdenacioLiquidat) THEN
                RAISE NOTICE '';        
                mostrarNomsColumnes := TRUE;
                numTotalRegistres := 0;
                sumaTotal1 := 0;            
                OPEN cur_Liquidat(nominaId);   
                LOOP	
                  FETCH cur_Liquidat INTO regLiquidat;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE NOTICE 'Liquidat:';
                        RAISE NOTICE '';
                        RAISE NOTICE '  Id      Ord.Pagament  Data Període         Data Execució        Data Efecte          Quantitat'; 
                        RAISE NOTICE '  ------  ------------  -------------------  -------------------  -------------------  ---------';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE NOTICE '  %  %  %  %  %  %', 
                                 RPAD(TO_CHAR(regLiquidat.id, 'fm9999999'), 6, ' '),
                                 RPAD(TO_CHAR(regLiquidat.ordenacio_pagament_id, 'fm9999999'), 12, ' '),
                                 TO_CHAR(regLiquidat.data_periode, 'DD-MM-YYYY HH24:MI:SS'),
                                 TO_CHAR(regLiquidat.data_execucio, 'DD-MM-YYYY HH24:MI:SS'),
                                 TO_CHAR(regLiquidat.data_efecte, 'DD-MM-YYYY HH24:MI:SS'),
                                 LPAD(TO_CHAR(regLiquidat.quantitat, 'fm99999990.00'), 9, ' ');
                    sumaTotal1 := sumaTotal1 + regLiquidat.quantitat;
                    numTotalRegistres := numTotalRegistres + 1;
                END LOOP;
                CLOSE cur_Liquidat;
                IF (mostrarNomsColumnes) THEN
                    RAISE NOTICE 'Liquidat: sense registres';
                ELSE                                        
                    RAISE NOTICE '                                                                                       ---------';
                    RAISE NOTICE '  %',
                                 LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 94, ' ');
                    IF (numTotalRegistres > 1) THEN
                        RAISE NOTICE '  % registres.', numTotalRegistres;
                    ELSE 
                        RAISE NOTICE '  1 registre.';
                    END IF;
                END IF;
            END IF;
        END IF;       
    END IF;
    RAISE NOTICE '';
    RAISE NOTICE '----------------------------------------------------------------------------------------------------------------------------';
END;
$$;