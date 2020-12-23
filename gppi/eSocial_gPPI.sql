---------------------------------------------------------------------------------------------------------------------
--	PAYROLL PERFORMANCE INFORMATION - gPPI v.1.0 release 20200710												   --	
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
    prestacioId INTEGER := 603;
    ----------------------------------------------        
    cur_PrestacioReserva CURSOR(p_idPrestacio INTEGER) FOR
		SELECT * FROM eco_prestacio_reserva WHERE prestacio_id = p_idPrestacio ORDER BY data_reserva, id;    
    cur_DretReserva CURSOR(p_idDret INTEGER) FOR
		SELECT * FROM eco_dret_reserva WHERE dret_id = p_idDret ORDER BY id;        
    cur_EfecteMovimentNomina CURSOR(p_idDret INTEGER) FOR
		SELECT * FROM eco_efecte_moviment_nomina WHERE dret_id = p_idDret ORDER BY moviment_detall_id, data_efecte_inici, id;    
    cur_Activitat CURSOR(p_idDret INTEGER) FOR
		SELECT * FROM eco_activitat WHERE dret_id = p_idDret ORDER BY moviment_id, data_efecte_inicial, id;        
    cur_ActivitatDetall CURSOR(p_idNomina INTEGER) FOR
		SELECT * FROM eco_activitat_detall WHERE nomina_id = p_idNomina ORDER BY data_efecte, id;        
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
    regPrestacioReserva	eco_prestacio_reserva%ROWTYPE;
    regDretReserva eco_dret_reserva%ROWTYPE;
    regEfecteMovimentNomina eco_efecte_moviment_nomina%ROWTYPE;
    regActivitat eco_activitat%ROWTYPE;
    regActivitatDetall eco_activitat_detall%ROWTYPE;
    regDretTeoric eco_dret_teoric%ROWTYPE;
    regDretTeoricDetall eco_dret_teoric_detall%ROWTYPE;
    regDeute eco_deute%ROWTYPE;
    regDeuteDetall eco_deute_detall%ROWTYPE;
    regPercebut eco_percebut%ROWTYPE;
    regPercebutDetall eco_percebut_detall%ROWTYPE;    
    dretId INTEGER;
    expedientPrestacioId INTEGER;
    personaId INTEGER;
    nominaId INTEGER;
    numeroExpedient TEXT;
    mostrarNomsColumnes BOOLEAN;
BEGIN
    SELECT pre.dret_id, pre.expedient_prestacio_id INTO dretId, expedientPrestacioId FROM prestacio pre WHERE id = prestacioId;
    SELECT epr.persona_id, epr.numero_expedient INTO personaId, numeroExpedient FROM expedient_prestacio epr WHERE id = expedientPrestacioId;
    SELECT dre.nomina_id INTO nominaId FROM eco_dret dre WHERE id = dretId;
    RAISE NOTICE '----------------------------------------------------------------------------------------------------------------------------';
	RAISE NOTICE ' Script eSocial gPPI v.1.0 release 20200710';
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
    RAISE NOTICE '      Data Execució.: %', (SELECT (TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS')));	
	RAISE NOTICE '----------------------------------------------------------------------------------------------------------------------------';    
    ----------------------------------------------
    -- eco_prestacio_reserva
    ----------------------------------------------
    mostrarNomsColumnes := TRUE;
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
    END LOOP;
    CLOSE cur_PrestacioReserva;            
    IF (mostrarNomsColumnes) THEN
        RAISE NOTICE 'Prestació Reserva: sense registres';
    END IF;
    IF (dretId IS NOT NULL) THEN 
        ----------------------------------------------
        -- eco_dret_reserva
        ----------------------------------------------
        RAISE NOTICE '';        
        mostrarNomsColumnes := TRUE;
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
        END LOOP;
        CLOSE cur_DretReserva;
        IF (mostrarNomsColumnes) THEN
            RAISE NOTICE 'Dret Reserva: sense registres';
        END IF;
        ----------------------------------------------
        -- eco_efecte_moviment_nomina
        ----------------------------------------------
        RAISE NOTICE '';        
        mostrarNomsColumnes := TRUE;
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
        END LOOP;
        CLOSE cur_EfecteMovimentNomina;
        IF (mostrarNomsColumnes) THEN
            RAISE NOTICE 'Efecte Moviment Nòmina: sense registres';
        END IF;
        ----------------------------------------------
        -- eco_activitat
        ----------------------------------------------
        RAISE NOTICE '';        
        mostrarNomsColumnes := TRUE;
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
        END LOOP;
        CLOSE cur_Activitat;
        IF (mostrarNomsColumnes) THEN
            RAISE NOTICE 'Activitat: sense registres';
        END IF;        
        IF (nominaId IS NOT NULL) THEN 
            ----------------------------------------------
            -- eco_activitat_detall
            ----------------------------------------------
            RAISE NOTICE '';        
            mostrarNomsColumnes := TRUE;
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
            END LOOP;
            CLOSE cur_ActivitatDetall;
            IF (mostrarNomsColumnes) THEN
                RAISE NOTICE 'Activitat Detall: sense registres';
            END IF;
        END IF;
        ----------------------------------------------
        -- eco_dret_teoric
        ----------------------------------------------
        RAISE NOTICE '';        
        mostrarNomsColumnes := TRUE;
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
        END LOOP;
        CLOSE cur_DretTeoric;
        IF (mostrarNomsColumnes) THEN
            RAISE NOTICE 'Dret Teòric: sense registres';
        END IF;
        ----------------------------------------------
        -- eco_dret_teoric_detall
        ----------------------------------------------
        RAISE NOTICE '';        
        mostrarNomsColumnes := TRUE;
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
        END LOOP;
        CLOSE cur_DretTeoricDetall;
        IF (mostrarNomsColumnes) THEN
            RAISE NOTICE 'Dret Teòric Detall: sense registres';
        END IF;        
        IF (nominaId IS NOT NULL) THEN 
            ----------------------------------------------
            -- eco_deute
            ----------------------------------------------
            RAISE NOTICE '';        
            mostrarNomsColumnes := TRUE;            
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
            END LOOP;
            CLOSE cur_Deute;
            IF (mostrarNomsColumnes) THEN
                RAISE NOTICE 'Deute: sense registres';
            END IF;
            ----------------------------------------------
            -- eco_deute_detall
            ----------------------------------------------
            RAISE NOTICE '';        
            mostrarNomsColumnes := TRUE;
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
            END LOOP;
            CLOSE cur_DeuteDetall;
            IF (mostrarNomsColumnes) THEN
                RAISE NOTICE 'Dret Detall: sense registres';
            END IF;
            ----------------------------------------------
            -- eco_percebut
            ----------------------------------------------
            RAISE NOTICE '';        
            mostrarNomsColumnes := TRUE;            
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
            END LOOP;
            CLOSE cur_Percebut;            
            IF (mostrarNomsColumnes) THEN
                RAISE NOTICE 'Percebut: sense registres';
            END IF;
            ----------------------------------------------
            -- eco_percebut_detall
            ----------------------------------------------
            RAISE NOTICE '';        
            mostrarNomsColumnes := TRUE;            
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
            END LOOP;
            CLOSE cur_PercebutDetall;            
            IF (mostrarNomsColumnes) THEN
                RAISE NOTICE 'Percebut Detall: sense registres';
            END IF;
        END IF;       
    END IF;
    RAISE NOTICE '';
    RAISE NOTICE '----------------------------------------------------------------------------------------------------------------------------';
END;
$$;


