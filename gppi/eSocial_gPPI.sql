---------------------------------------------------------------------------------------------------------------------
--  eSocial_gPPI.sql                                                                                               --
--	Payroll Performance Information - v.5.0 release 20210318     												   --	
--  						  																					   --	
--																						   						   --	
--  Created by Gregorio Luque Serrano.      	   								   		                           --
--  Barcelona, July 10, 2020.	   												   		                           --
---------------------------------------------------------------------------------------------------------------------
SET SCHEMA 'esocial';
SET search_path TO esocial;
DO $$
DECLARE
    -------------------------------------------------------------------------------
    -- Configurable parameters:
    -------------------------------------------------------------------------------
    --
    -- File identification parameters:
    --
    prestacioId INTEGER := 712;
    dretId INTEGER := NULL;
	numeroExpedient TEXT := NULL;
    --
    -- Checkers to display blocks of information:
    --
    mostrarNomesHeader BOOLEAN := FALSE;
    mostrarResumImportsTaules BOOLEAN := TRUE;
    mostrarInformaciSituacio BOOLEAN := TRUE;
    mostrarDadesTaules BOOLEAN := TRUE;
    --
    -- Checkers to display specific situation information:
    --
    mostratInformaciSituacioDret BOOLEAN := TRUE;
    mostratInformaciSituacioNomina BOOLEAN := TRUE;
    mostratInformaciSituacioPersona BOOLEAN := TRUE;
    mostratInformaciSituacioNominaMensual BOOLEAN := TRUE; 
    --
    -- Checkers to display information from tables
    --
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
    mostrarLiquidat BOOLEAN := TRUE;    
    -------------------------------------------------------------------------------
    -- Cursor variables:
    -------------------------------------------------------------------------------
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
		SELECT * FROM eco_activitat_detall WHERE nomina_id = p_idNomina ORDER BY data_efecte, activitat_id, id;   
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
    -------------------------------------------------------------------------------
    -- Table row type variables:
    -------------------------------------------------------------------------------
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
    regDret eco_dret%ROWTYPE;
    regNomina eco_nomina%ROWTYPE;
    regPersona persona%ROWTYPE;
    regNominaMensual eco_nomina_mensual%ROWTYPE;
    regIdentificador identificador%ROWTYPE;    
    regDadesBancaries dades_bancaries%ROWTYPE;
    regNominaPersona eco_nomina_persona%ROWTYPE;
    -------------------------------------------------------------------------------
    -- Simple type variables:
    -------------------------------------------------------------------------------
    expedientPrestacioId INTEGER;
    personaId INTEGER;
    nominaId INTEGER;
    procedimentId INTEGER;
    tramitId INTEGER;
    mostrarNomsColumnes BOOLEAN;
    posicio INTEGER;
    sumaTotal1 DECIMAL; 
    sumaTotal2 DECIMAL;
    sumaTotal3 DECIMAL;
    sumaTotal4 DECIMAL;
    numTotalRegistres INTEGER;
    descripcio TEXT := NULL;
    importsPositius DECIMAL;
    importsNegatius DECIMAL;
    importTotal DECIMAL;
BEGIN
    -------------------------------------------------------------------------------
    -- Checking input parameters:
    -------------------------------------------------------------------------------
    IF prestacioId IS NULL AND dretId IS NULL AND numeroExpedient IS NULL THEN
        RAISE EXCEPTION 'No s''''ha indicat cap paràmetre'; 
    END IF;
    IF prestacioId IS NULL THEN
        IF dretId IS NOT NULL THEN
            SELECT id INTO prestacioId FROM prestacio WHERE dret_id = dretId;
            IF prestacioId IS NULL THEN 
                RAISE EXCEPTION 'No és possible obtenir la prestació associada al dret indicat';
            END IF;            
        ELSE
            SELECT id INTO expedientPrestacioId FROM expedient_prestacio WHERE numero_expedient = numeroExpedient;
            IF expedientPrestacioId IS NOT NULL THEN
                SELECT id INTO prestacioId FROM prestacio WHERE expedient_prestacio_id = expedientPrestacioId;
            END IF;
            IF prestacioId IS NULL THEN
                RAISE EXCEPTION 'No és possible obtenir la prestació associada al número d''''expedient indicat';
            END IF;
        END IF;
    END IF;
    -------------------------------------------------------------------------------
    -- Script header:
    -------------------------------------------------------------------------------    
    SELECT pre.dret_id, pre.expedient_prestacio_id INTO dretId, expedientPrestacioId FROM prestacio pre WHERE pre.id = prestacioId;    
    IF expedientPrestacioId IS NOT NULL THEN
        SELECT epr.persona_id, epr.numero_expedient INTO personaId, numeroExpedient FROM expedient_prestacio epr WHERE epr.id = expedientPrestacioId;
        SELECT ppr.id INTO procedimentId FROM procediment_prestacio ppr WHERE ppr.expedient_prestacio_id = expedientPrestacioId;
        IF nominaId IS NULL THEN
            SELECT tramit_id INTO tramitId FROM eco_moviment 
            WHERE expedient_id = expedientPrestacioId AND procediment_id = procedimentId 
            ORDER BY data_creacio_moviment DESC, id DESC LIMIT 1;
        ELSE 
            SELECT tramit_id INTO tramitId FROM eco_moviment
            WHERE id = (SELECT moviment_id FROM eco_moviment_detall WHERE nomina_id = nominaId 
                        ORDER BY data_efecte_inicial DESC, id DESC LIMIT 1);
        END IF;
    END IF;
    SELECT dre.nomina_id INTO nominaId FROM eco_dret dre WHERE id = dretId; 
    RAISE INFO '----------------------------------------------------------------------------------------------------------------------------';
	RAISE INFO ' Script eSocial gPPI v.5.0 release 20210318';
    RAISE INFO '';
    RAISE INFO ' Payroll Performance Information created by gluques.';    
    RAISE INFO ' 2020-2021 - Economic eSocial Project.';
	RAISE INFO '';
	RAISE INFO '    Dades Prestació:';    
    RAISE INFO '      Num.Expedient......: %', numeroExpedient;
    RAISE INFO '      Exp.Prestació......: %', expedientPrestacioId;
    RAISE INFO '      Procediment........: %', procedimentId;
    RAISE INFO '      Tramit.............: %', tramitId;
    RAISE INFO '      Prestació..........: %', prestacioId;
    RAISE INFO '      Persona............: %', personaId;
    RAISE INFO '      Dret...............: %', dretId;
    IF (dretId IS NOT NULL) THEN
        SELECT * INTO regNomina FROM eco_nomina WHERE id = nominaId;
        RAISE INFO '      Nòmina.............: %', nominaId;        
        SELECT lvi.descripcio INTO descripcio FROM eco_tipus_nomina etn
        JOIN llistat_valors lv ON etn.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE etn.id = regNomina.tipus_nomina_id;
        RAISE INFO '      Tipus..............: % [%]', descripcio, regNomina.tipus_nomina_id;
        RAISE INFO '      Alta...............: %', regNomina.data_alta_nomina;
        RAISE INFO '      Primera execució...: %', regNomina.data_primera_execucio;
        RAISE INFO '      Efecte inici.......: %', TO_CHAR(regNomina.data_efecte_inici, 'DD-MM-YYYY');
        SELECT lvi.descripcio INTO descripcio FROM eco_estat_nomina een
        JOIN llistat_valors lv ON een.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE een.id = regNomina.estat_id;
        RAISE INFO '      Estat..............: % [%]', descripcio, regNomina.estat_id;             
        SELECT * INTO regMoviment FROM eco_moviment 
        WHERE id IN (SELECT DISTINCT moviment_id FROM eco_moviment_detall WHERE nomina_id = nominaId) 
        ORDER BY id DESC LIMIT 1; 
        RAISE INFO '      Últim moviment.....: % ', TO_CHAR(regMoviment.data_creacio_moviment, 'DD-MM-YYYY HH24:MI:SS');
        SELECT * INTO regEfecteMovimentNomina FROM eco_efecte_moviment_nomina 
        WHERE dret_id = dretId ORDER BY moviment_detall_id DESC, id DESC LIMIT 1;
        SELECT lvi.descripcio INTO descripcio FROM eco_tipus_efecte_nomina ten
        JOIN llistat_valors lv ON ten.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE ten.id = regEfecteMovimentNomina.tipus_id;        
        RAISE INFO '      Últim efecte.......: %', TO_CHAR(regEfecteMovimentNomina.data_efecte_inici, 'DD-MM-YYYY');
        RAISE INFO '      Tipus efecte.......: % [%]', descripcio, regEfecteMovimentNomina.tipus_id;        
        RAISE INFO '      Import actual......: %', TO_CHAR(regEfecteMovimentNomina.import_actual, 'fm99999990.00');
        RAISE INFO '      Import anterior....: %', TO_CHAR(regEfecteMovimentNomina.import_anterior, 'fm99999990.00');
        SELECT * INTO regPercebut FROM eco_percebut 
        WHERE nomina_id = nominaId ORDER BY data_efecte DESC LIMIT 1;        
        RAISE INFO '      Últim percebut.....: %', TO_CHAR(regPercebut.data_efecte, 'DD-MM-YYYY');
        RAISE INFO '      Import percebut....: %', TO_CHAR(regPercebut.import_percebut, 'fm99999990.00');
        SELECT * INTO regNominaMensual FROM eco_nomina_mensual 
        WHERE tipus_nomina_id = regNomina.tipus_nomina_id ORDER BY data_nomina DESC LIMIT 1;
        RAISE INFO '      Última nòm.mensual.: %', regNominaMensual.id;
        RAISE INFO '      Data generació.....: %', TO_CHAR(regNominaMensual.data_inici_generacio, 'DD-MM-YYYY HH24:MI:SS');
        RAISE INFO '      Data nòmina........: %', TO_CHAR(regNominaMensual.data_nomina, 'DD-MM-YYYY');        
        RAISE INFO '      Estat nòmina.......: ''%''', regNominaMensual.estat;         
    END IF;
    RAISE INFO '';
    RAISE INFO '    Data execució script: %', (SELECT (TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS')));	
	RAISE INFO '----------------------------------------------------------------------------------------------------------------------------';
    IF (dretId IS NOT NULL AND NOT mostrarNomesHeader) THEN
        -------------------------------------------------------------------------------
        -- Información de situació:
        -------------------------------------------------------------------------------
        IF (mostrarInformaciSituacio AND 
            (mostratInformaciSituacioDret OR mostratInformaciSituacioNomina OR 
             mostratInformaciSituacioPersona OR mostratInformaciSituacioNominaMensual)) 
        THEN            
            RAISE INFO 'INFORMACIÓ DE SITUACIÓ:';
            RAISE INFO '';
            ----------------------------------------------
            --- Informació de situació - Dret:    
            ----------------------------------------------
            IF (mostratInformaciSituacioDret) THEN            
                SELECT * INTO regDret FROM eco_dret WHERE id = dretId;
                RAISE INFO '  Dret...................: %', dretId;
                RAISE INFO '    Data activació.......: %', regDret.data_activacio;
                RAISE INFO '    Data canvi estat.....: %', regDret.data_canvi_estat;
                RAISE INFO '    Data efecte inici....: %', regDret.data_efecte_inici;
                RAISE INFO '    Data efecte fi.......: %', regDret.data_efecte_fi;
                SELECT lvi.descripcio INTO descripcio FROM eco_tipus_estat_dret eted
                JOIN llistat_valors lv ON eted.llistat_valors_id = lv.id
                JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
                WHERE eted.id = regDret.estat_id;
                RAISE INFO '    Estat................: % [%]', descripcio, regDret.estat_id;
                SELECT lvi.descripcio INTO descripcio FROM eco_motiu_estat_dret emed
                JOIN llistat_valors lv ON emed.llistat_valors_id = lv.id
                JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
                WHERE emed.id = regDret.estat_motiu_id;
                RAISE INFO '    Motiu estat..........: % [%]', descripcio, regDret.estat_motiu_id;   
            END IF;        
            ----------------------------------------------
            --- Informació de situació - Nòmina:    
            ----------------------------------------------            
            IF (mostratInformaciSituacioNomina) THEN                        
                RAISE INFO '  Nòmina.................: %', nominaId;                	
                RAISE INFO '    Alta.................: %', regNomina.data_alta_nomina;
                SELECT lvi.descripcio INTO descripcio FROM eco_tipus_nomina etn
                JOIN llistat_valors lv ON etn.llistat_valors_id = lv.id
                JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
                WHERE etn.id = regNomina.tipus_nomina_id;
                RAISE INFO '    Tipus................: % [%]', descripcio, regNomina.tipus_nomina_id;	
                RAISE INFO '    Primera execució.....: %', regNomina.data_primera_execucio;
                RAISE INFO '    Efecte inici.........: %', regNomina.data_efecte_inici;
                RAISE INFO '    Efecte fi............: %', regNomina.data_efecte_fi;
                SELECT lvi.descripcio INTO descripcio FROM eco_estat_nomina een
                JOIN llistat_valors lv ON een.llistat_valors_id = lv.id
                JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
                WHERE een.id = regNomina.estat_id;
                RAISE INFO '    Estat................: % [%]', descripcio, regNomina.estat_id;
                SELECT lvi.descripcio INTO descripcio FROM eco_motiu_estat_nomina emen
                JOIN llistat_valors lv ON emen.llistat_valors_id = lv.id
                JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
                WHERE emen.id = regNomina.estat_motiu_id;
                RAISE INFO '    Motiu estat..........: % [%]', descripcio, regNomina.estat_motiu_id;	
                RAISE INFO '    Data estat...........: %', regNomina.data_estat;
            END IF;
            ----------------------------------------------
            --- Informació de situació - Persona:    
            ----------------------------------------------
            IF (mostratInformaciSituacioPersona) THEN            
                SELECT * INTO regPersona FROM persona WHERE id = personaId;
                SELECT * INTO regIdentificador FROM identificador WHERE persona_id = personaId;          
                SELECT INTO regNominaPersona * FROM eco_nomina_persona WHERE nomina_id = nominaId;    
                SELECT * INTO regDadesBancaries FROM dades_bancaries WHERE id = regNominaPersona.dades_bancaries_id;
                RAISE INFO '  Persona................: %', personaId;
                RAISE INFO '    Nom i cognoms........: %', regPersona.nom || ' ' || regPersona.cognom1 || ' ' || regPersona.cognom2;
                RAISE INFO '    Actiu................: %', CASE WHEN regPersona.actiu THEN 'True' ELSE 'False' END;
                RAISE INFO '    Identificador........: %', regIdentificador.valor;
                RAISE INFO '    IBAN.................: %', regDadesBancaries.iban;		
            END IF;
            ----------------------------------------------
            -- Informació de situació - Nòmina Mensual:
            ----------------------------------------------
            IF (mostratInformaciSituacioNominaMensual) THEN
                RAISE INFO '  Última Nòmina.Mensual..: %', regNominaMensual.id;	        
                SELECT lvi.descripcio INTO descripcio FROM eco_tipus_nomina etn
                JOIN llistat_valors lv ON etn.llistat_valors_id = lv.id
                JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
                WHERE etn.id = regNominaMensual.tipus_nomina_id;
                RAISE INFO '    Tipus nòmina.........: % [%]', descripcio, regNominaMensual.tipus_nomina_id;
                RAISE INFO '    Data.................: %', regNominaMensual.data_nomina;
                RAISE INFO '    Data generació.......: %', regNominaMensual.data_inici_generacio;
                RAISE INFO '    Estat................: ''%''', regNominaMensual.estat;        
                RAISE INFO '    Data canvi estat.....: %', regNominaMensual.data_canvi_estat;    
            END IF;
        ELSE 
            mostrarInformaciSituacio = FALSE;
        END IF;
        -------------------------------------------------------------------------------
        -- Resum imports taules:
        -------------------------------------------------------------------------------
        IF (mostrarResumImportsTaules) THEN        
            RAISE INFO '';
            RAISE INFO 'RESUM IMPORTS TAULES:';
            RAISE INFO '                                Imp.Positius  Imp.Negatius  Imp.Total';
            RAISE INFO '                                ------------  ------------  ------------';    
            ----------------------------------------------
            -- Resum imports taules - Activitat Detall:
            ----------------------------------------------
            SELECT SUM(CASE WHEN (quantitat > 0) THEN quantitat ELSE 0 END),
                   SUM(CASE WHEN (quantitat < 0) THEN quantitat ELSE 0 END) AS "Imp.Negatius",
                   SUM(quantitat) AS "Imp.Total"
            INTO importsPositius, importsNegatius, importTotal
            FROM eco_activitat_detall WHERE nomina_id = nominaId;
            IF (importTotal IS NULL) THEN
                importsPositius := 0;
                importsNegatius := 0;
                importTotal := 0;
            END IF;
            RAISE INFO '    Activitat Detall....:  %  %  %',
                                                     LPAD(TO_CHAR(importsPositius, 'fm99999990.00'), 17, ' '),
                                                     LPAD(TO_CHAR(importsNegatius * -1, 'fm99999990.00'), 12, ' '),
                                                     LPAD(TO_CHAR(importTotal, 'fm99999990.00'), 12, ' ');
            ----------------------------------------------
            -- Resum imports taules - Dret Teòric:
            ----------------------------------------------
            SELECT SUM(CASE WHEN (quantitat > 0) THEN quantitat ELSE 0 END),
                   SUM(CASE WHEN (quantitat < 0) THEN quantitat ELSE 0 END) AS "Imp.Negatius",
                   SUM(quantitat) AS "Imp.Total"
            INTO importsPositius, importsNegatius, importTotal
            FROM eco_dret_teoric WHERE dret_id = dretId;
            IF (importTotal IS NULL) THEN
                importsPositius := 0;
                importsNegatius := 0;
                importTotal := 0;
            END IF;
            RAISE INFO '    Dret Teòric.........:  %  %  %',
                                                     LPAD(TO_CHAR(importsPositius, 'fm99999990.00'), 17, ' '),
                                                     LPAD(TO_CHAR(importsNegatius * -1, 'fm99999990.00'), 12, ' '),
                                                     LPAD(TO_CHAR(importTotal, 'fm99999990.00'), 12, ' ');
            ----------------------------------------------
            -- Resum imports taules - Dret Teòric Detall:
            ----------------------------------------------
            SELECT SUM(CASE WHEN (quantitat > 0) THEN quantitat ELSE 0 END),
                   SUM(CASE WHEN (quantitat < 0) THEN quantitat ELSE 0 END) AS "Imp.Negatius",
                   SUM(quantitat) AS "Imp.Total"
            INTO importsPositius, importsNegatius, importTotal
            FROM eco_dret_teoric_detall WHERE dret_id = dretId;
            IF (importTotal IS NULL) THEN
                importsPositius := 0;
                importsNegatius := 0;
                importTotal := 0;
            END IF;
            RAISE INFO '    Dret Teòric Detall..:  %  %  %',
                                                     LPAD(TO_CHAR(importsPositius, 'fm99999990.00'), 17, ' '),
                                                     LPAD(TO_CHAR(importsNegatius * -1, 'fm99999990.00'), 12, ' '),
                                                     LPAD(TO_CHAR(importTotal, 'fm99999990.00'), 12, ' ');
            ----------------------------------------------
            -- Resum imports taules - Deute:
            ----------------------------------------------
            SELECT SUM(CASE WHEN (quantitat > 0) THEN quantitat ELSE 0 END),
                   SUM(CASE WHEN (quantitat < 0) THEN quantitat ELSE 0 END) AS "Imp.Negatius",
                   SUM(quantitat) AS "Imp.Total"
            INTO importsPositius, importsNegatius, importTotal
            FROM eco_deute WHERE nomina_id = nominaId;
            IF (importTotal IS NULL) THEN
                importsPositius := 0;
                importsNegatius := 0;
                importTotal := 0;
            END IF;
            RAISE INFO '    Deute...............:  %  %  %',
                                                     LPAD(TO_CHAR(importsPositius, 'fm99999990.00'), 17, ' '),
                                                     LPAD(TO_CHAR(importsNegatius * -1, 'fm99999990.00'), 12, ' '),
                                                     LPAD(TO_CHAR(importTotal, 'fm99999990.00'), 12, ' ');
            ----------------------------------------------
            -- Resum imports taules - Deute Detall:
            ----------------------------------------------
            SELECT SUM(CASE WHEN (quantitat > 0) THEN quantitat ELSE 0 END),
                   SUM(CASE WHEN (quantitat < 0) THEN quantitat ELSE 0 END) AS "Imp.Negatius",
                   SUM(quantitat) AS "Imp.Total"
            INTO importsPositius, importsNegatius, importTotal
            FROM eco_deute_detall WHERE nomina_id = nominaId;
            IF (importTotal IS NULL) THEN
                importsPositius := 0;
                importsNegatius := 0;
                importTotal := 0;
            END IF;
            RAISE INFO '    Deute Detall........:  %  %  %',
                                                     LPAD(TO_CHAR(importsPositius, 'fm99999990.00'), 17, ' '),
                                                     LPAD(TO_CHAR(importsNegatius * -1, 'fm99999990.00'), 12, ' '),
                                                     LPAD(TO_CHAR(importTotal, 'fm99999990.00'), 12, ' ');
            ----------------------------------------------
            -- Resum imports taules - Percebut:
            ----------------------------------------------
            SELECT SUM(CASE WHEN (import_percebut > 0) THEN import_percebut ELSE 0 END),
                   SUM(CASE WHEN (import_percebut < 0) THEN import_percebut ELSE 0 END) AS "Imp.Negatius",
                   SUM(import_percebut) AS "Imp.Total"
            INTO importsPositius, importsNegatius, importTotal
            FROM eco_percebut WHERE nomina_id = nominaId;
            IF (importTotal IS NULL) THEN
                importsPositius := 0;
                importsNegatius := 0;
                importTotal := 0;
            END IF;        
            RAISE INFO '    Percebut............:  %  %  %',
                                                     LPAD(TO_CHAR(importsPositius, 'fm99999990.00'), 17, ' '),
                                                     LPAD(TO_CHAR(importsNegatius * -1, 'fm99999990.00'), 12, ' '),
                                                     LPAD(TO_CHAR(importTotal, 'fm99999990.00'), 12, ' ');
            ----------------------------------------------
            -- Resum imports taules - Percebut Detall:
            ----------------------------------------------
            SELECT SUM(CASE WHEN (quantitat > 0) THEN quantitat ELSE 0 END),
                   SUM(CASE WHEN (quantitat < 0) THEN quantitat ELSE 0 END) AS "Imp.Negatius",
                   SUM(quantitat) AS "Imp.Total"
            INTO importsPositius, importsNegatius, importTotal
            FROM eco_percebut_detall WHERE nomina_id = nominaId;
            IF (importTotal IS NULL) THEN
                importsPositius := 0;
                importsNegatius := 0;
                importTotal := 0;
            END IF;
            RAISE INFO '    Percebut Detall.....:  %  %  %',
                                                     LPAD(TO_CHAR(importsPositius, 'fm99999990.00'), 17, ' '),
                                                     LPAD(TO_CHAR(importsNegatius * -1, 'fm99999990.00'), 12, ' '),
                                                     LPAD(TO_CHAR(importTotal, 'fm99999990.00'), 12, ' ');
                                                     
            ----------------------------------------------
            -- Resum imports taules - Ordenació Pagament:
            ----------------------------------------------
            SELECT SUM(CASE WHEN (quantitat > 0) THEN quantitat ELSE 0 END),
                   SUM(CASE WHEN (quantitat < 0) THEN quantitat ELSE 0 END) AS "Imp.Negatius",
                   SUM(quantitat) AS "Imp.Total"
            INTO importsPositius, importsNegatius, importTotal
            FROM eco_ordenacio_pagament WHERE nomina_id = nominaId;
            IF (importTotal IS NULL) THEN
                importsPositius := 0;
                importsNegatius := 0;
                importTotal := 0;
            END IF;
            RAISE INFO '    Ord.Pagament........:  %  %  %',
                                                     LPAD(TO_CHAR(importsPositius, 'fm99999990.00'), 17, ' '),
                                                     LPAD(TO_CHAR(importsNegatius * -1, 'fm99999990.00'), 12, ' '),
                                                     LPAD(TO_CHAR(importTotal, 'fm99999990.00'), 12, ' ');
            ----------------------------------------------
            -- Resum imports taules - Ord.Pagament Detall:
            ----------------------------------------------
            SELECT SUM(CASE WHEN (quantitat > 0) THEN quantitat ELSE 0 END),
                   SUM(CASE WHEN (quantitat < 0) THEN quantitat ELSE 0 END) AS "Imp.Negatius",
                   SUM(quantitat) AS "Imp.Total"
            INTO importsPositius, importsNegatius, importTotal
            FROM eco_ordenacio_pagament_detall WHERE nomina_id = nominaId;
            IF (importTotal IS NULL) THEN
                importsPositius := 0;
                importsNegatius := 0;
                importTotal := 0;
            END IF;
            RAISE INFO '    Ord.Pagament Detall.:  %  %  %',
                                                     LPAD(TO_CHAR(importsPositius, 'fm99999990.00'), 17, ' '),
                                                     LPAD(TO_CHAR(importsNegatius * -1, 'fm99999990.00'), 12, ' '),
                                                     LPAD(TO_CHAR(importTotal, 'fm99999990.00'), 12, ' ');
            ----------------------------------------------
            -- Resum imports taules - Liquidat:
            ----------------------------------------------
            SELECT SUM(CASE WHEN (quantitat > 0) THEN quantitat ELSE 0 END),
                   SUM(CASE WHEN (quantitat < 0) THEN quantitat ELSE 0 END) AS "Imp.Negatius",
                   SUM(quantitat) AS "Imp.Total"
            INTO importsPositius, importsNegatius, importTotal
            FROM eco_liquidat WHERE dret_id = dretId;
            IF (importTotal IS NULL) THEN
                importsPositius := 0;
                importsNegatius := 0;
                importTotal := 0;
            END IF;
            RAISE INFO '    Liquidat............:  %  %  %',
                                                     LPAD(TO_CHAR(importsPositius, 'fm99999990.00'), 17, ' '),
                                                     LPAD(TO_CHAR(importsNegatius * -1, 'fm99999990.00'), 12, ' '),
                                                     LPAD(TO_CHAR(importTotal, 'fm99999990.00'), 12, ' ');
        END IF;
        -------------------------------------------------------------------------------
        -- Tables data:
        -------------------------------------------------------------------------------
        IF (mostrarDadesTaules AND 
           (mostrarPrestacioReserva OR mostrarDretReserva OR mostrarEfecteMovimentNomina OR mostrarActivitat OR mostrarDretTeoric OR mostrarDretTeoricDetall OR 
           (nominaId IS NOT NULL AND (mostrarMoviment OR mostrarMovimentDetall OR mostrarActivitatDetall OR mostrarDeute OR mostrarDeuteDetall OR mostrarPercebut OR 
                                      mostrarPercebutDetall OR mostrarOrdenacioPagament OR  mostrarOrdenacioPagamentDetall OR mostrarLiquidat)))) 
        THEN
            RAISE INFO '';
            RAISE INFO 'DADES TAULES:';
            ----------------------------------------------
            -- Dades taules - eco_prestacio_reserva
            ----------------------------------------------
            IF (mostrarPrestacioReserva) THEN
                RAISE INFO '';
                mostrarNomsColumnes := TRUE;
                sumaTotal1 := 0;
                sumaTotal2 := 0;
                numTotalRegistres := 0;
                OPEN cur_PrestacioReserva(prestacioId);   
                LOOP	
                  FETCH cur_PrestacioReserva INTO regPrestacioReserva;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE INFO '  Prestació Reserva:';
                        RAISE INFO '';
                        RAISE INFO '    Id      Reserva     Data Reserva         Imp.Reservat  Imp.Recuperat';
                        RAISE INFO '    ------  ----------  -------------------  ------------  -------------';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE INFO '    %  %  %  %  %', 
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
                    RAISE INFO '  Prestació Reserva: sense registres';
                ELSE
                    RAISE INFO '                                             ------------  -------------';
                    RAISE INFO '    %  %', 
                                 LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 53, ' '),
                                 LPAD(TO_CHAR(sumaTotal2, 'fm99999990.00'), 13, ' ');
                    IF (numTotalRegistres > 1) THEN
                        RAISE INFO '    % registres.', numTotalRegistres;
                    ELSE 
                        RAISE INFO '    1 registre.';
                    END IF;
                END IF;
            END IF;
            IF (dretId IS NOT NULL) THEN 
                ----------------------------------------------
                -- Dades taules - eco_dret_reserva
                ----------------------------------------------
                IF (mostrarDretReserva) THEN
                    RAISE INFO '';        
                    mostrarNomsColumnes := TRUE;
                    numTotalRegistres := 0;
                    OPEN cur_DretReserva(dretId);   
                    LOOP	
                      FETCH cur_DretReserva INTO regDretReserva;	
                      EXIT WHEN NOT FOUND;
                        IF (mostrarNomsColumnes) THEN
                            RAISE INFO '  Dret Reserva:';
                            RAISE INFO '';
                            RAISE INFO '    Id      Imp.Reservat  Imp.Ordenat  Imp.Trames  Imp.Pagat  Imp.Recuperat  Imp.Restant  Rcd Crt Ts'; 
                            RAISE INFO '    ------  ------------  -----------  ----------  ---------  -------------  -----------  -------------------';
                            mostrarNomsColumnes := FALSE;
                        END IF;
                        RAISE INFO '    %  %  %  %  %  %  %  %', 
                                     RPAD(TO_CHAR(regDretReserva.id, 'fm9999999'), 6, ' '),                             
                                     LPAD(TO_CHAR(regDretReserva.import_reservat, 'fm99999990.00'), 12, ' '),
                                     LPAD(TO_CHAR(regDretReserva.import_ordenat, 'fm99999990.00'), 11, ' '),
                                     LPAD(TO_CHAR(regDretReserva.import_trames, 'fm99999990.00'), 10, ' '),
                                     LPAD(TO_CHAR(regDretReserva.import_pagat, 'fm99999990.00'), 9, ' '),
                                     LPAD(TO_CHAR(regDretReserva.import_recuperat, 'fm99999990.00'), 13, ' '),
                                     LPAD(TO_CHAR(regDretReserva.import_restant, 'fm99999990.00'), 11, ' '),
                                     TO_CHAR(regDretReserva.rcd_crt_ts, 'DD-MM-YYYY HH24:MI:SS');
                        numTotalRegistres := numTotalRegistres + 1;
                    END LOOP;
                    CLOSE cur_DretReserva;
                    IF (mostrarNomsColumnes) THEN
                        RAISE INFO '  Dret Reserva: sense registres';
                    ELSE
                        RAISE INFO '';
                        IF (numTotalRegistres > 1) THEN
                            RAISE INFO '    % registres.', numTotalRegistres;
                        ELSE 
                            RAISE INFO '    1 registre.';
                        END IF;
                    END IF;
                END IF;
                IF (nominaId IS NOT NULL) THEN 
                    ----------------------------------------------
                    -- Dades taules - eco_moviment
                    ----------------------------------------------
                    IF (mostrarMoviment) THEN
                        RAISE INFO '';        
                        mostrarNomsColumnes := TRUE;
                        numTotalRegistres := 0;
                        OPEN cur_Moviment(nominaId);
                        LOOP	
                          FETCH cur_Moviment INTO regMoviment;	
                          EXIT WHEN NOT FOUND;
                            IF (mostrarNomsColumnes) THEN
                                RAISE INFO '  Moviment:';
                                RAISE INFO '';
                                RAISE INFO '    Id      Expedient  Procediment  Tramit  Data creació         Estat '; 
                                RAISE INFO '    ------  ---------  -----------  ------  -------------------  ------------';
                                mostrarNomsColumnes := FALSE;
                            END IF;
                            RAISE INFO '    %  %  %  %  %  %', 
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
                            RAISE INFO '  Moviment: sense registres';
                        ELSE
                            RAISE INFO '';
                            IF (numTotalRegistres > 1) THEN
                                RAISE INFO '    % registres.', numTotalRegistres;
                            ELSE 
                                RAISE INFO '    1 registre.';
                            END IF;
                            IF (mostrarContingutMoviment) THEN
                                OPEN cur_Moviment(nominaId);
                                LOOP	
                                  FETCH cur_Moviment INTO regMoviment;
                                  EXIT WHEN NOT FOUND;
                                    RAISE INFO '';
                                    RAISE INFO '    Contingut Moviment: %', regMoviment.id;
                                    RAISE INFO '';
                                    posicio := 1;
                                    WHILE (posicio < character_length(regMoviment.contingut_moviment)) LOOP
                                        IF ((posicio + 79) > character_length(regMoviment.contingut_moviment)) THEN
                                            RAISE INFO '          %', substring(regMoviment.contingut_moviment FROM posicio FOR character_length(regMoviment.contingut_moviment));
                                        ELSE
                                            RAISE INFO '          %', substring(regMoviment.contingut_moviment FROM posicio FOR 79);
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
                    -- Dades taules - eco_moviment_detall
                    ----------------------------------------------
                    IF (mostrarMovimentDetall) THEN
                        RAISE INFO '';        
                        mostrarNomsColumnes := TRUE;   
                        numTotalRegistres := 0;            
                        OPEN cur_Moviment_Detall(nominaId);
                        LOOP	
                          FETCH cur_Moviment_Detall INTO regMovimentDetall;	
                          EXIT WHEN NOT FOUND;
                            IF (mostrarNomsColumnes) THEN
                                RAISE INFO '  Moviment Detall:';
                                RAISE INFO '';
                                RAISE INFO '    Id      Rcd Crt Ts           Moviment  Data Efecte Inicial  Data Efecte Final    Import    '; 
                                RAISE INFO '    ------  -------------------  --------  -------------------  -------------------  ----------';
                                mostrarNomsColumnes := FALSE;
                            END IF;
                            RAISE INFO '    %  %  %  %  %  %', 
                                         RPAD(TO_CHAR(regMovimentDetall.id, 'fm9999999'), 6, ' '), 
                                         TO_CHAR(regMovimentDetall.rcd_crt_ts, 'DD-MM-YYYY HH24:MI:SS'),
                                         RPAD(TO_CHAR(regMovimentDetall.moviment_id, 'fm9999999'), 8, ' '),
                                         TO_CHAR(regMovimentDetall.data_efecte_inicial, 'DD-MM-YYYY HH24:MI:SS'),
                                         TO_CHAR(regMovimentDetall.data_efecte_final, 'DD-MM-YYYY HH24:MI:SS'),
                                         CASE WHEN regMovimentDetall.data_efecte_final IS NULL 
                                            THEN LPAD(TO_CHAR(regMovimentDetall.import_moviment, 'fm99999990.00'), 23, ' ') 
                                            ELSE TO_CHAR(regMovimentDetall.import_moviment, 'fm99999990.00') END;
                            numTotalRegistres := numTotalRegistres + 1;
                        END LOOP;
                        CLOSE cur_Moviment_Detall;            
                        IF (mostrarNomsColumnes) THEN
                            RAISE INFO '  Moviment Detall: sense registres';
                        ELSE 
                            RAISE INFO '';
                            IF (numTotalRegistres > 1) THEN
                                RAISE INFO '    % registres.', numTotalRegistres;
                            ELSE 
                                RAISE INFO '    1 registre.';
                            END IF;
                        END IF;            
                    END IF;
                END IF;
            END IF;
            ----------------------------------------------
            -- Dades taules - eco_efecte_moviment_nomina
            ----------------------------------------------
            IF (mostrarEfecteMovimentNomina) THEN
                RAISE INFO '';        
                mostrarNomsColumnes := TRUE;
                numTotalRegistres := 0;
                OPEN cur_EfecteMovimentNomina(dretId);   
                LOOP	
                  FETCH cur_EfecteMovimentNomina INTO regEfecteMovimentNomina;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE INFO '  Efecte Moviment Nòmina:';
                        RAISE INFO '';
                        RAISE INFO '    Id      Mov.Detall  Tipus  Data Inici           Data Fi              Imp.Anterior  Imp.Actual  Diferencial'; 
                        RAISE INFO '    ------  ----------  -----  -------------------  -------------------  ------------  ----------  -----------';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE INFO '    %  %  %  %  %  %  %  %', 
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
                    RAISE INFO '  Efecte Moviment Nòmina: sense registres';
                ELSE
                    RAISE INFO '';
                    IF (numTotalRegistres > 1) THEN
                        RAISE INFO '    % registres.', numTotalRegistres;
                    ELSE 
                        RAISE INFO '    1 registre.';
                    END IF;
                END IF;
            END IF;
            ----------------------------------------------
            -- Dades taules - eco_activitat
            ----------------------------------------------
            IF (mostrarActivitat) THEN
                RAISE INFO '';        
                mostrarNomsColumnes := TRUE;
                numTotalRegistres := 0;
                OPEN cur_Activitat(dretId);   
                LOOP	
                  FETCH cur_Activitat INTO regActivitat;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE INFO '  Activitat:';
                        RAISE INFO '';
                        RAISE INFO '    Id      Moviment  Data Inici           Data Fi              Quantitat  Estat  Arxivat  Modalitat  Liquidació  Rcd Crt Ts'; 
                        RAISE INFO '    ------  --------  -------------------  -------------------  ---------  -----  -------  ---------  ----------  -------------------';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE INFO '    %  %  %  %  %  %  %  %  %  %', 
                                 RPAD(TO_CHAR(regActivitat.id, 'fm9999999'), 6, ' '), 
                                 RPAD(TO_CHAR(regActivitat.moviment_id, 'fm999999'), 8, ' '),                             
                                 TO_CHAR(regActivitat.data_efecte_inicial, 'DD-MM-YYYY HH24:MI:SS'),
                                 CASE WHEN regActivitat.data_efecte_final IS NULL THEN RPAD('NULL', 19, ' ') 
                                    ELSE TO_CHAR(regActivitat.data_efecte_final, 'DD-MM-YYYY HH24:MI:SS') END,                              
                                 LPAD(TO_CHAR(regActivitat.quantitat, 'fm99999990.00'), 9, ' '),							 
                                 LPAD(regActivitat.estat_activitat, 1, ' '),
                                 CASE WHEN regActivitat.arxivat THEN LPAD('TRUE', 8, ' ') ELSE LPAD('FALSE', 9, ' ') END,
                                 CASE WHEN regActivitat.arxivat THEN LPAD(TO_CHAR(regActivitat.pagament_modalitat_id, 'fm9999999'), 4, ' ') 
                                    ELSE LPAD(TO_CHAR(regActivitat.pagament_modalitat_id, 'fm9999999'), 3, ' ') END,                             
                                 CASE WHEN regActivitat.liquidacio THEN LPAD('TRUE', 12, ' ') ELSE LPAD('FALSE', 13, ' ') END,
                                 CASE WHEN regActivitat.liquidacio THEN LPAD(TO_CHAR(regActivitat.rcd_crt_ts, 'DD-MM-YYYY HH24:MI:SS'), 23, ' ')
                                    ELSE LPAD(TO_CHAR(regActivitat.rcd_crt_ts, 'DD-MM-YYYY HH24:MI:SS'), 24, ' ') END;
                    numTotalRegistres := numTotalRegistres + 1;
                END LOOP;
                CLOSE cur_Activitat;
                IF (mostrarNomsColumnes) THEN
                    RAISE INFO '  Activitat: sense registres';
                ELSE
                    RAISE INFO '';
                    IF (numTotalRegistres > 1) THEN
                        RAISE INFO '    % registres.', numTotalRegistres;
                    ELSE 
                        RAISE INFO '    1 registre.';
                    END IF;
                END IF;
            END IF;    
            IF (nominaId IS NOT NULL) THEN 
                ----------------------------------------------
                -- Dades taules - eco_activitat_detall
                ----------------------------------------------
                IF (mostrarActivitatDetall) THEN
                    RAISE INFO '';        
                    mostrarNomsColumnes := TRUE;
                    numTotalRegistres := 0;
                    sumaTotal1 := 0;
                    OPEN cur_ActivitatDetall(nominaId);   
                    LOOP	
                      FETCH cur_ActivitatDetall INTO regActivitatDetall;	
                      EXIT WHEN NOT FOUND;
                        IF (mostrarNomsColumnes) THEN
                            RAISE INFO '  Activitat Detall:';
                            RAISE INFO '';
                            RAISE INFO '    Id      N.Mensual  Activitat  Data Efecte          Quantitat  Modalitat  T.Pagament'; 
                            RAISE INFO '    ------  ---------  ---------  -------------------  ---------  ---------  ----------';
                            mostrarNomsColumnes := FALSE;
                        END IF;
                        RAISE INFO '    %  %  %  %  %  %  %', 
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
                        RAISE INFO '  Activitat Detall: sense registres';
                    ELSE
                        RAISE INFO '                                                       ---------';
                        RAISE INFO '    %', 
                                     LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 60, ' ');
                        IF (numTotalRegistres > 1) THEN
                            RAISE INFO '    % registres.', numTotalRegistres;
                        ELSE 
                            RAISE INFO '    1 registre.';
                        END IF;
                    END IF;
                END IF;
            END IF;
            ----------------------------------------------
            -- Dades taules - eco_dret_teoric
            ----------------------------------------------
            IF (mostrarDretTeoric) THEN
                RAISE INFO '';        
                mostrarNomsColumnes := TRUE;
                numTotalRegistres := 0;
                sumaTotal1 := 0;
                OPEN cur_DretTeoric(dretId);   
                LOOP	
                  FETCH cur_DretTeoric INTO regDretTeoric;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE INFO '  Dret Teòric:';
                        RAISE INFO '';
                        RAISE INFO '    Id      Data Efecte          Quantitat  Data Execució        Rcd Crt Ts'; 
                        RAISE INFO '    ------  -------------------  ---------  -------------------  -------------------';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE INFO '    %  %  %  %  %', 
                                 RPAD(TO_CHAR(regDretTeoric.id, 'fm9999999'), 6, ' '),                                                              
                                 TO_CHAR(regDretTeoric.data_efecte, 'DD-MM-YYYY HH24:MI:SS'),
                                 LPAD(TO_CHAR(regDretTeoric.quantitat, 'fm99999990.00'), 9, ' '),
                                 TO_CHAR(regDretTeoric.data_execucio, 'DD-MM-YYYY HH24:MI:SS'),
                                 TO_CHAR(regDretTeoric.rcd_crt_ts, 'DD-MM-YYYY HH24:MI:SS');
                    sumaTotal1 := sumaTotal1 + regDretTeoric.quantitat;
                    numTotalRegistres := numTotalRegistres + 1;
                END LOOP;
                CLOSE cur_DretTeoric;
                IF (mostrarNomsColumnes) THEN
                    RAISE INFO '  Dret Teòric: sense registres';
                ELSE            
                    RAISE INFO '                                 ---------';
                    RAISE INFO '    %', 
                                 LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 38, ' ');
                    IF (numTotalRegistres > 1) THEN
                        RAISE INFO '    % registres.', numTotalRegistres;
                    ELSE 
                        RAISE INFO '    1 registre.';
                    END IF;
                END IF;
            END IF;
            ----------------------------------------------
            -- Dades taules - eco_dret_teoric_detall
            ----------------------------------------------        
            IF (mostrarDretTeoricDetall) THEN
                RAISE INFO '';        
                mostrarNomsColumnes := TRUE;
                numTotalRegistres := 0;
                sumaTotal1 := 0;
                OPEN cur_DretTeoricDetall(dretId);   
                LOOP	
                  FETCH cur_DretTeoricDetall INTO regDretTeoricDetall;	
                  EXIT WHEN NOT FOUND;
                    IF (mostrarNomsColumnes) THEN
                        RAISE INFO '  Dret Teòric Detall:';
                        RAISE INFO '';
                        RAISE INFO '    Id      Efecte  Data Efecte          Quantitat  Modalitat  T.Pagament'; 
                        RAISE INFO '    ------  ------  -------------------  ---------  ---------  ----------  ';
                        mostrarNomsColumnes := FALSE;
                    END IF;
                    RAISE INFO '    %  %  %  %  %  %', 
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
                    RAISE INFO '  Dret Teòric Detall: sense registres';
                ELSE                        
                    RAISE INFO '                                         ---------';
                    RAISE INFO '    %', 
                                 LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 46, ' ');
                    IF (numTotalRegistres > 1) THEN
                        RAISE INFO '    % registres.', numTotalRegistres;
                    ELSE 
                        RAISE INFO '    1 registre.';
                    END IF;
                END IF;
            END IF;    
            IF (nominaId IS NOT NULL) THEN 
                ----------------------------------------------
                -- Dades taules - eco_deute
                ----------------------------------------------
                IF (mostrarDeute) THEN
                    RAISE INFO '';        
                    mostrarNomsColumnes := TRUE;
                    numTotalRegistres := 0;            
                    OPEN cur_Deute(nominaId);   
                    LOOP	
                      FETCH cur_Deute INTO regDeute;	
                      EXIT WHEN NOT FOUND;
                        IF (mostrarNomsColumnes) THEN
                            RAISE INFO '  Deute:';
                            RAISE INFO '';
                            RAISE INFO '    Id      Data Creacio         Quantitat  Estat  Q.Negociada  Q.Condonada  Q.Aplicada  Data Pagament Inici  Data Pagament Fi'; 
                            RAISE INFO '    ------  -------------------  ---------  -----  -----------  -----------  ----------  -------------------  -------------------';
                            mostrarNomsColumnes := FALSE;
                        END IF;
                        RAISE INFO '    %  %  %  %  %  %  %  %  %', 
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
                        RAISE INFO '  Deute: sense registres';
                    ELSE
                        RAISE INFO '';
                        IF (numTotalRegistres > 1) THEN
                            RAISE INFO '    % registres.', numTotalRegistres;
                        ELSE 
                            RAISE INFO '    1 registre.';
                        END IF;
                    END IF;
                END IF;
                ----------------------------------------------
                -- Dades taules - eco_deute_detall
                ----------------------------------------------            
                IF (mostrarDeuteDetall) THEN
                    RAISE INFO '';        
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
                            RAISE INFO '  Deute Detall:';
                            RAISE INFO '';
                            RAISE INFO '    Id      Deute   Efecte  Data Efecte          Quantitat  Q.Negociada  Q.Condonada  Q.Aplicada  Data Execució'; 
                            RAISE INFO '    ------  ------  ------  -------------------  ---------  -----------  -----------  ----------  -------------------';
                            mostrarNomsColumnes := FALSE;
                        END IF;
                        RAISE INFO '    %  %  %  %  %  %  %  %  %', 
                                     RPAD(TO_CHAR(regDeuteDetall.id, 'fm9999999'), 6, ' '),
                                     RPAD(TO_CHAR(regDeuteDetall.deute_id, 'fm9999999'), 6, ' '),
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
                        RAISE INFO '  Deute Detall: sense registres';
                    ELSE                    
                        RAISE INFO '                                                 ---------  -----------  -----------  ----------';
                        RAISE INFO '    %  %  %  %', 
                                     LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 54, ' '),
                                     LPAD(TO_CHAR(sumaTotal2, 'fm99999990.00'), 11, ' '),
                                     LPAD(TO_CHAR(sumaTotal3, 'fm99999990.00'), 11, ' '),
                                     LPAD(TO_CHAR(sumaTotal4, 'fm99999990.00'), 10, ' ');
                        IF (numTotalRegistres > 1) THEN
                            RAISE INFO '    % registres.', numTotalRegistres;
                        ELSE 
                            RAISE INFO '    1 registre.';
                        END IF;
                    END IF;
                END IF;
                ----------------------------------------------
                -- Dades taules - eco_percebut
                ----------------------------------------------            
                IF (mostrarPercebut) THEN
                    RAISE INFO '';        
                    mostrarNomsColumnes := TRUE;
                    numTotalRegistres := 0;            
                    sumaTotal1 := 0;
                    OPEN cur_Percebut(nominaId);   
                    LOOP	
                      FETCH cur_Percebut INTO regPercebut;	
                      EXIT WHEN NOT FOUND;
                        IF (mostrarNomsColumnes) THEN
                            RAISE INFO '  Percebut:';
                            RAISE INFO '';
                            RAISE INFO '    Id      Rcd_Crt_Ts           Data Efecte          Imp.Percebut'; 
                            RAISE INFO '    ------  -------------------  -------------------  ------------';
                            mostrarNomsColumnes := FALSE;
                        END IF;
                        RAISE INFO '    %  %  %  %', 
                                     RPAD(TO_CHAR(regPercebut.id, 'fm9999999'), 6, ' '),
                                     TO_CHAR(regPercebut.rcd_crt_ts, 'DD-MM-YYYY HH24:MI:SS'),
                                     TO_CHAR(regPercebut.data_efecte, 'DD-MM-YYYY HH24:MI:SS'),
                                     LPAD(TO_CHAR(regPercebut.import_percebut, 'fm99999990.00'), 12, ' ');
                        sumaTotal1 := sumaTotal1 + regPercebut.import_percebut;
                        numTotalRegistres := numTotalRegistres + 1;
                    END LOOP;
                    CLOSE cur_Percebut;            
                    IF (mostrarNomsColumnes) THEN
                        RAISE INFO '  Percebut: sense registres';
                    ELSE                        
                        RAISE INFO '                                                      ------------';
                        RAISE INFO '    %', 
                                     LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 62, ' ');
                        IF (numTotalRegistres > 1) THEN
                            RAISE INFO '    % registres.', numTotalRegistres;
                        ELSE 
                            RAISE INFO '    1 registre.';
                        END IF;
                    END IF;
                END IF;
                ----------------------------------------------
                -- Dades taules - eco_percebut_detall
                ----------------------------------------------            
                IF (mostrarPercebutDetall) THEN
                    RAISE INFO '';        
                    mostrarNomsColumnes := TRUE;
                    numTotalRegistres := 0;
                    sumaTotal1 := 0;            
                    OPEN cur_PercebutDetall(nominaId);   
                    LOOP	
                      FETCH cur_PercebutDetall INTO regPercebutDetall;	
                      EXIT WHEN NOT FOUND;
                        IF (mostrarNomsColumnes) THEN
                            RAISE INFO '  Percebut Detall:';
                            RAISE INFO '';
                            RAISE INFO '    Id      Act.Detall  Data Efecte          Quantitat  Modalitat  T.Pagament  Data Execució'; 
                            RAISE INFO '    ------  ----------  -------------------  ---------  ---------  ----------  -------------------';
                            mostrarNomsColumnes := FALSE;
                        END IF;
                        RAISE INFO '    %  %  %  %  %  %  %', 
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
                        RAISE INFO '  Percebut Detall: sense registres';
                    ELSE                                        
                        RAISE INFO '                                             ---------';
                        RAISE INFO '      %',
                                     LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 48, ' ');
                        IF (numTotalRegistres > 1) THEN
                            RAISE INFO '    % registres.', numTotalRegistres;
                        ELSE 
                            RAISE INFO '    1 registre.';
                        END IF;
                    END IF;
                END IF;
                ----------------------------------------------
                -- Dades taules - eco_ordenacio_pagament
                ----------------------------------------------            
                IF (mostrarOrdenacioPagament) THEN
                    RAISE INFO '';        
                    mostrarNomsColumnes := TRUE;
                    numTotalRegistres := 0;            
                    sumaTotal1 := 0;
                    OPEN cur_OrdenacioPagament(nominaId);   
                    LOOP	
                      FETCH cur_OrdenacioPagament INTO regOrdenacioPagament;	
                      EXIT WHEN NOT FOUND;
                        IF (mostrarNomsColumnes) THEN
                            RAISE INFO '  Ordenació Pagament:';
                            RAISE INFO '';
                            RAISE INFO '    Id      Rcd_Crt_Ts           N.Mensual  Quantitat'; 
                            RAISE INFO '    ------  -------------------  ---------  ---------';
                            mostrarNomsColumnes := FALSE;
                        END IF;
                        RAISE INFO '    %  %  %  %', 
                                     RPAD(TO_CHAR(regOrdenacioPagament.id, 'fm9999999'), 6, ' '),
                                     TO_CHAR(regOrdenacioPagament.rcd_crt_ts, 'DD-MM-YYYY HH24:MI:SS'),                             
                                     RPAD(TO_CHAR(regOrdenacioPagament.nomina_mensual_id, 'fm9999999'), 9, ' '),
                                     LPAD(TO_CHAR(regOrdenacioPagament.quantitat, 'fm99999990.00'), 9, ' ');
                        sumaTotal1 := sumaTotal1 + regOrdenacioPagament.quantitat;
                        numTotalRegistres := numTotalRegistres + 1;
                    END LOOP;
                    CLOSE cur_OrdenacioPagament; 
                    IF (mostrarNomsColumnes) THEN
                        RAISE INFO '  Ordenació Pagament: sense registres';
                    ELSE                                        
                        RAISE INFO '                                            ---------';
                        RAISE INFO '    %',
                                     LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 49, ' ');
                        IF (numTotalRegistres > 1) THEN
                            RAISE INFO '    % registres.', numTotalRegistres;
                        ELSE 
                            RAISE INFO '    1 registre.';
                        END IF;                             
                    END IF;
                END IF;
                ----------------------------------------------
                -- Dades taules - eco_ordenacio_pagament_detall
                ----------------------------------------------            
                IF (mostrarOrdenacioPagamentDetall) THEN
                    RAISE INFO '';        
                    mostrarNomsColumnes := TRUE;
                    numTotalRegistres := 0;
                    sumaTotal1 := 0;
                    OPEN cur_OrdenacioPagamentDetall(nominaId);   
                    LOOP	
                      FETCH cur_OrdenacioPagamentDetall INTO regOrdenacioPagamentDetall;	
                      EXIT WHEN NOT FOUND;
                        IF (mostrarNomsColumnes) THEN
                            RAISE INFO '  Ordenació Pagament Detall:';
                            RAISE INFO '';
                            RAISE INFO '    Id      Rcd_Crt_Ts           N.Mensual  Quantitat  Act.Detall'; 
                            RAISE INFO '    ------  -------------------  ---------  ---------  ----------';
                            mostrarNomsColumnes := FALSE;
                        END IF;
                        RAISE INFO '    %  %  %  %  %', 
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
                        RAISE INFO '  Ordenació Pagament Detall: sense registres';
                    ELSE                                        
                        RAISE INFO '                                            ---------';
                        RAISE INFO '    %',
                                     LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 49, ' ');
                        IF (numTotalRegistres > 1) THEN
                            RAISE INFO '    % registres.', numTotalRegistres;
                        ELSE 
                            RAISE INFO '    1 registre.';
                        END IF;
                    END IF;
                END IF;
                ----------------------------------------------
                -- Dades taules - eco_liquidat
                ----------------------------------------------
                IF (mostrarLiquidat) THEN
                    RAISE INFO '';        
                    mostrarNomsColumnes := TRUE;
                    numTotalRegistres := 0;
                    sumaTotal1 := 0;            
                    OPEN cur_Liquidat(nominaId);   
                    LOOP	
                      FETCH cur_Liquidat INTO regLiquidat;	
                      EXIT WHEN NOT FOUND;
                        IF (mostrarNomsColumnes) THEN
                            RAISE INFO '  Liquidat:';
                            RAISE INFO '';
                            RAISE INFO '    Id      Ord.Pagament  Data Període         Data Execució        Data Efecte          Quantitat'; 
                            RAISE INFO '    ------  ------------  -------------------  -------------------  -------------------  ---------';
                            mostrarNomsColumnes := FALSE;
                        END IF;
                        RAISE INFO '    %  %  %  %  %  %', 
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
                        RAISE INFO '  Liquidat: sense registres';
                    ELSE                                        
                        RAISE INFO '                                                                                         ---------';
                        RAISE INFO '    %',
                                     LPAD(TO_CHAR(sumaTotal1, 'fm99999990.00'), 94, ' ');
                        IF (numTotalRegistres > 1) THEN
                            RAISE INFO '    % registres.', numTotalRegistres;
                        ELSE 
                            RAISE INFO '    1 registre.';
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
	IF NOT (mostrarInformaciSituacio OR mostrarResumImportsTaules OR mostrarDadesTaules) THEN
		RAISE INFO 'ATENCIÓ: S''ha desactivat la visualització de totes les dades.';
        RAISE INFO '----------------------------------------------------------------------------------------------------------------------------';
    ELSEIF (dretId IS NULL AND NOT mostrarNomesHeader) THEN
        RAISE INFO 'ATENCIÓ: La prestació no disposa de dret.';
        RAISE INFO '----------------------------------------------------------------------------------------------------------------------------';
	ELSEIF (NOT mostrarNomesHeader) THEN
		RAISE INFO '';
        RAISE INFO '----------------------------------------------------------------------------------------------------------------------------';
	END IF;	        
END;
$$;