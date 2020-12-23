---------------------------------------------------------------------------------------------------------------------
--	PAYROLL FILE INFORMATION - gPFI v.1.0 release 20200713												           --	
--  						  																					   --	
--																						   						   --	
--  Created by Gregorio Luque Serrano for DXC.	   								   		   © eSocial DXC Software  --
--  Barcelona, July 13, 2020.	   												   		   █║▌│█│║▌║││█║▌║▌║█║▌│█  --
---------------------------------------------------------------------------------------------------------------------
SET SCHEMA 'esocial';
SET search_path TO esocial;
DO $$
DECLARE
    -- Configurable parameters -------------------
    prestacioId INTEGER := 603;    
    dretId INTEGER := NULL;--172;
	numeroExpedient TEXT := NULL;--'00006/2020/1003';
    ----------------------------------------------        
    regPrestacio prestacio%ROWTYPE;
	regDret eco_dret%ROWTYPE;	
    regNominaPersona eco_nomina_persona%ROWTYPE;
    regExpedientPrestacio expedient_prestacio%ROWTYPE;    
    regMoviment eco_moviment%ROWTYPE;
    regMovimentDetall eco_moviment_detall%ROWTYPE;    
	regPersona persona%ROWTYPE;    
    regIdentificador identificador%ROWTYPE;    
    regDadesBancaries dades_bancaries%ROWTYPE;
    regNomina eco_nomina%ROWTYPE;
    regProcedimentPrestacio procediment_prestacio%ROWTYPE;
    regTramitPrestacio tramit_prestacio%ROWTYPE;
    regNominaMensual eco_nomina_mensual%ROWTYPE;
	parametersOk BOOLEAN := FALSE;
	nominaId INTEGER := NULL;
    personaId INTEGER := NULL;
    expedientPrestacioId INTEGER := NULL;
    descripcio TEXT := NULL;
BEGIN	
    IF prestacioId IS NOT NULL THEN            
        SELECT * INTO regPrestacio FROM prestacio WHERE id = prestacioId;		
        IF regPrestacio.dret_id IS NOT NULL THEN                   
            dretId := regPrestacio.dret_id;
            expedientPrestacioId := regPrestacio.expedient_prestacio_id;    
            SELECT * INTO regExpedientPrestacio FROM expedient_prestacio WHERE id = expedientPrestacioId;
            numeroExpedient := regExpedientPrestacio.numero_expedient;
			SELECT * INTO regDret FROM eco_dret WHERE id = dretId;
			IF regDret.nomina_id IS NOT NULL THEN
				nominaId := regDret.nomina_id;
				SELECT INTO regNominaPersona * FROM eco_nomina_persona WHERE nomina_id = nominaId;
				IF regNominaPersona.persona_id IS NOT NULL THEN
					personaId := regNominaPersona.persona_id;
					parametersOk := TRUE;
				END IF;
			END IF;			
        END IF;
    END IF;
	IF NOT parametersOk AND dretId IS NOT NULL THEN
		SELECT * INTO regDret FROM eco_dret WHERE id = dretId;
		IF regDret.nomina_id IS NOT NULL THEN
			nominaId := regDret.nomina_id;
			SELECT * INTO regPrestacio FROM prestacio WHERE dret_id = dretId;
			IF regPrestacio.id IS NOT NULL THEN			
				prestacioId := regPrestacio.id;
                expedientPrestacioId := regPrestacio.expedient_prestacio_id;
                SELECT * INTO regExpedientPrestacio FROM expedient_prestacio WHERE id = expedientPrestacioId;
                numeroExpedient := regExpedientPrestacio.numero_expedient;
				SELECT INTO regNominaPersona * FROM eco_nomina_persona WHERE nomina_id = nominaId;
				IF regNominaPersona.persona_id IS NOT NULL THEN
					personaId := regNominaPersona.persona_id;
					parametersOk := TRUE;
				END IF;
			END IF;
		END IF;
	END IF;
    IF NOT parametersOk AND numeroExpedient IS NOT NULL THEN		
		SELECT * INTO regExpedientPrestacio FROM expedient_prestacio WHERE numero_expedient = numeroExpedient;
        IF regExpedientPrestacio.id IS NOT NULL THEN			
            expedientPrestacioId := regExpedientPrestacio.id;
            SELECT * INTO regPrestacio FROM prestacio WHERE expedient_prestacio_id = expedientPrestacioId;
            IF regPrestacio.dret_id IS NOT NULL THEN				
                prestacioId := regPrestacio.id;
                dretId := regPrestacio.dret_id;		
                SELECT * INTO regDret FROM eco_dret WHERE id = dretId;
                IF regDret.nomina_id IS NOT NULL THEN
                    nominaId := regDret.nomina_id;
                    SELECT INTO regNominaPersona * FROM eco_nomina_persona WHERE nomina_id = nominaId;
                    IF regNominaPersona.persona_id IS NOT NULL THEN
                        personaId := regNominaPersona.persona_id;
                        parametersOk := TRUE;
                    END IF;
                END IF;
            END IF;
        END IF;
	END IF;	
	RAISE NOTICE '----------------------------------------------------------------------------------------------------------------------------';
	RAISE NOTICE ' Script eSocial gPFI v.1.0 release 20200713';
    RAISE NOTICE '';
    RAISE NOTICE ' Payroll File Information created by gluques.';    
    RAISE NOTICE ' (c) 2020 - eSocial DXC Software.';
	RAISE NOTICE '';	
    RAISE NOTICE ' Data execució: %', (SELECT (TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS')));	
	RAISE NOTICE '----------------------------------------------------------------------------------------------------------------------------';        
    IF (prestacioId IS NOT NULL AND dretId IS NOT NULL AND nominaId IS NOT NULL AND personaId IS NOT NULL AND expedientPrestacioId IS NOT NULL AND numeroExpedient IS NOT NULL) THEN
        SELECT * INTO regMovimentDetall FROM eco_moviment_detall WHERE nomina_id = nominaId ORDER BY moviment_id LIMIT 1;
        SELECT * INTO regMoviment FROM eco_moviment WHERE id = regMovimentDetall.moviment_id;        
        SELECT * INTO regPersona FROM persona WHERE id = personaId;
        SELECT * INTO regIdentificador FROM identificador WHERE persona_id = personaId;                   
        SELECT * INTO regDadesBancaries FROM dades_bancaries WHERE id = regNominaPersona.dades_bancaries_id;
        SELECT * INTO regNomina FROM eco_nomina WHERE id = nominaId;   
        SELECT * INTO regProcedimentPrestacio FROM procediment_prestacio WHERE id = regMoviment.procediment_id;
        SELECT * INTO regTramitPrestacio FROM tramit_prestacio WHERE id = regMoviment.tramit_id;
        SELECT * INTO regNominaMensual FROM eco_nomina_mensual WHERE tipus_nomina_id = regNomina.tipus_nomina_id ORDER BY data_nomina DESC LIMIT 1;        
        ----------------------------------------------
        -- Expedient-Prestació
        ----------------------------------------------
        RAISE NOTICE 'Numero Expedient........: %', numeroExpedient;
        RAISE NOTICE '  Expedient-Prestació...: %', expedientPrestacioId;
        RAISE NOTICE '    Sol.licitud.........: %', regExpedientPrestacio.solicitud_id;
        RAISE NOTICE '    Data alta...........: %', regExpedientPrestacio.data_alta;
        RAISE NOTICE '    Data inici..........: %', regExpedientPrestacio.data_inici;
        RAISE NOTICE '    Data efecte.........: %', regExpedientPrestacio.data_efecte;        
        SELECT lvi.descripcio INTO descripcio FROM tipus_motiu_inici_expedient tmie
        JOIN llistat_valors lv ON tmie.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE tmie.id = regExpedientPrestacio.tipus_motiu_inici_expedient_id;                
        RAISE NOTICE '    Motiu inici.........: % [%]', descripcio, regExpedientPrestacio.tipus_motiu_inici_expedient_id;        
        SELECT lvi.descripcio INTO descripcio FROM tipus_situacio_expedient tse
        JOIN llistat_valors lv ON tse.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE tse.id = regExpedientPrestacio.tipus_situacio_expedient_id;
        RAISE NOTICE '    Situació............: % [%]', descripcio, regExpedientPrestacio.tipus_situacio_expedient_id;        
        SELECT lvi.descripcio INTO descripcio FROM tipus_motiu_situacio_expedient tmse
        JOIN llistat_valors lv ON tmse.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE tmse.id = regExpedientPrestacio.tipus_motiu_situacio_expedient_id;
        RAISE NOTICE '    Motiu situació......: % [%]', descripcio, regExpedientPrestacio.tipus_motiu_situacio_expedient_id;
        ----------------------------------------------
        -- Procediment
        ----------------------------------------------        
        RAISE NOTICE '  Procediment...........: %', regMoviment.procediment_id;
        RAISE NOTICE '    Data inici..........: %', regProcedimentPrestacio.data_inici;
        RAISE NOTICE '    Data tancament......: %', regProcedimentPrestacio.data_tancament;        
        SELECT lvi.descripcio INTO descripcio FROM tipus_procediment tp
        JOIN tipus_procediment_classe tpc ON tp.classe_id = tpc.id
        JOIN llistat_valors lv ON tpc.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE tp.id = regProcedimentPrestacio.tipus_procediment_id;
        RAISE NOTICE '    Tipus...............: % [%]', descripcio, regProcedimentPrestacio.tipus_procediment_id;        
        RAISE NOTICE '    Flag intervenció....: %', CASE WHEN regProcedimentPrestacio.flag_intervencio THEN 'True' ELSE 'False' END;
        ----------------------------------------------
        -- Tramit
        ----------------------------------------------
        RAISE NOTICE '  Tramit................: %', regMoviment.tramit_id;
        SELECT lvi.descripcio INTO descripcio FROM tipus_tramit_prestacio ttp
        JOIN llistat_valors lv ON ttp.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE ttp.id = regTramitPrestacio.tipus_tramit_prestacio_id;
        RAISE NOTICE '    Tipus...............: % [%]', descripcio, regTramitPrestacio.tipus_tramit_prestacio_id;        
        SELECT lvi.descripcio INTO descripcio FROM tipus_situacio_tramit tst
        JOIN llistat_valors lv ON tst.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE tst.id = regTramitPrestacio.tipus_situacio_tramit_id;
        RAISE NOTICE '    Situació............: % [%]', descripcio, regTramitPrestacio.tipus_situacio_tramit_id;
        RAISE NOTICE '    Data inici..........: %', regTramitPrestacio.data_inici;
        RAISE NOTICE '    Data situació.......: %', regTramitPrestacio.data_situacio;
        RAISE NOTICE '    Data tancament......: %', regTramitPrestacio.data_tancament;
        ----------------------------------------------
        -- Prestació
        ----------------------------------------------        
        RAISE NOTICE '  Prestació.............: %', prestacioId;
        RAISE NOTICE '    Origen..............: %', regPrestacio.rcd_crt_nm;
        RAISE NOTICE '    Data efecte inici...: %', regPrestacio.data_efecte_inici;
        SELECT lvi.descripcio INTO descripcio FROM eco_tipus_prestacio tp
        JOIN llistat_valors lv ON tp.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE tp.id = regPrestacio.tipus_prestacio_id;
        RAISE NOTICE '    Tipus...............: % [%]', descripcio, regPrestacio.tipus_prestacio_id;
        ----------------------------------------------
        -- Dret
        ----------------------------------------------
        RAISE NOTICE '  Dret..................: %', dretId;
        RAISE NOTICE '    Data activació......: %', regDret.data_activacio;
        RAISE NOTICE '    Data canvi estat....: %', regDret.data_canvi_estat;
        RAISE NOTICE '    Data efecte inici...: %', regDret.data_efecte_inici;
        RAISE NOTICE '    Data efecte fi......: %', regDret.data_efecte_fi;
        SELECT lvi.descripcio INTO descripcio FROM eco_tipus_estat_dret eted
        JOIN llistat_valors lv ON eted.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE eted.id = regDret.estat_id;
        RAISE NOTICE '    Estat...............: % [%]', descripcio, regDret.estat_id;
        SELECT lvi.descripcio INTO descripcio FROM eco_motiu_estat_dret emed
        JOIN llistat_valors lv ON emed.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE emed.id = regDret.estat_motiu_id;
        RAISE NOTICE '    Motiu estat.........: % [%]', descripcio, regDret.estat_motiu_id;        
        ----------------------------------------------
        -- Nòmina
        ----------------------------------------------
        RAISE NOTICE '  Nòmina................: %', nominaId;                	
		RAISE NOTICE '    Alta................: %', regNomina.data_alta_nomina;
        SELECT lvi.descripcio INTO descripcio FROM eco_tipus_nomina etn
        JOIN llistat_valors lv ON etn.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE etn.id = regNomina.tipus_nomina_id;
		RAISE NOTICE '    Tipus...............: % [%]', descripcio, regNomina.tipus_nomina_id;	
		RAISE NOTICE '    Primera execució....: %', regNomina.data_primera_execucio;
		RAISE NOTICE '    Efecte inici........: %', regNomina.data_efecte_inici;
		RAISE NOTICE '    Efecte fi...........: %', regNomina.data_efecte_fi;
        SELECT lvi.descripcio INTO descripcio FROM eco_estat_nomina een
        JOIN llistat_valors lv ON een.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE een.id = regNomina.estat_id;
		RAISE NOTICE '    Estat...............: % [%]', descripcio, regNomina.estat_id;
        SELECT lvi.descripcio INTO descripcio FROM eco_motiu_estat_nomina emen
        JOIN llistat_valors lv ON emen.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE emen.id = regNomina.estat_motiu_id;
		RAISE NOTICE '    Motiu estat.........: % [%]', descripcio, regNomina.estat_motiu_id;	
		RAISE NOTICE '    Data estat..........: %', regNomina.data_estat;
        ----------------------------------------------
        -- Persona
        ----------------------------------------------
        RAISE NOTICE '  Persona...............: %', personaId;
        RAISE NOTICE '    Nom i cognoms.......: %', regPersona.nom || ' ' || regPersona.cognom1 || ' ' || regPersona.cognom2;
        RAISE NOTICE '    Actiu...............: %', CASE WHEN regPersona.actiu THEN 'True' ELSE 'False' END;
        RAISE NOTICE '    Identificador.......: %', regIdentificador.valor;
        RAISE NOTICE '    IBAN................: %', regDadesBancaries.iban;
        ----------------------------------------------
        -- Nòmina Mensual
        ----------------------------------------------
        RAISE NOTICE '  Última Nòmina.Mensual.: %', regNominaMensual.id;	
        SELECT lvi.descripcio INTO descripcio FROM eco_tipus_nomina_mensual etnm
        JOIN llistat_valors lv ON etnm.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE etnm.id = regNominaMensual.tipus_nomina_mensual_id;
        RAISE NOTICE '    T.Nòmina Mensual....: % [%]', descripcio, regNominaMensual.tipus_nomina_mensual_id;
        SELECT lvi.descripcio INTO descripcio FROM eco_tipus_nomina etn
        JOIN llistat_valors lv ON etn.llistat_valors_id = lv.id
        JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
        WHERE etn.id = regNominaMensual.tipus_nomina_id;
        RAISE NOTICE '    Tipus Nòmina........: % [%]', descripcio, regNominaMensual.tipus_nomina_id;
		RAISE NOTICE '    Data................: %', regNominaMensual.data_nomina;
		RAISE NOTICE '    Data generació......: %', regNominaMensual.data_inici_generacio;
		RAISE NOTICE '    Estat...............: ''%''', regNominaMensual.estat;        
        RAISE NOTICE '    Data canvi estat....: %', regNominaMensual.data_inici_generacio;
        RAISE NOTICE '    D.Inici procediment.: %', regNominaMensual.data_inici_generacio;
        RAISE NOTICE '    D.Fi procediment....: %', regNominaMensual.data_inici_generacio;        
	ELSE				
        RAISE NOTICE '';
		RAISE NOTICE 'ATENCIÓ: no és possible obtenir els paràmetres de consulta necessaris.';
		RAISE NOTICE '';
		RAISE NOTICE '  Prestacio...........: %', prestacioId;
		RAISE NOTICE '  Dret................: %', dretId;
        RAISE NOTICE '  Numero Expedient....: %', numeroExpedient;
		RAISE NOTICE '  Nomina..............: %', nominaId;
		RAISE NOTICE '  Persona.............: %', personaId;
		RAISE NOTICE '  Expedient Prestacio.: %', expedientPrestacioId;
	END IF;    
    RAISE NOTICE '';
    RAISE NOTICE '----------------------------------------------------------------------------------------------------------------------------';
END;
$$;

