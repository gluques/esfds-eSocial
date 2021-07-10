------------------------------------------------------------------------------------------------
-- Script: ESOCIAL-14405
-- Date: 2021-07-11
------------------------------------------------------------------------------------------------
DO
$$

BEGIN
	SET search_path TO esocial;

	RAISE NOTICE 'START Executing script in ESOCIAL-14405.sql';

	IF EXISTS (SELECT 1 FROM registre_scripts WHERE script = 'ESOCIAL-14405')
	THEN
		RAISE WARNING '¡¡¡¡¡¡¡¡¡WARNING: ESOCIAL-14405.sql already been applied on database!!!!!!!!!!';
	ELSE
		----------------------------------------------------------
        -- Expedient "00017/2021/4973"
        ----------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2057;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2057;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3473;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3474;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6297;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6298;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6299;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5349;

        ------------------------------------------------------------
        -- Expedient "00017/2021/5012"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2059;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2059;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3476;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3477;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6302;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6303;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6304;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5352;

        ------------------------------------------------------------
        -- Expedient "00017/2021/5015"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2060;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2060;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3478;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3479;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6305;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6306;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6307;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5354;

        ------------------------------------------------------------
        -- Expedient "00017/2021/5032"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2061;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2061;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3480;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3481;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6308;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6309;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6310;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5356;

        ------------------------------------------------------------
        -- Expedient "00017/2021/5034"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2062;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2062;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3482;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3483;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6311;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6312;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6313;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5358;

        ------------------------------------------------------------
        -- Expedient "00017/2021/5035"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2063;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2063;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3484;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3485;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6314;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6315;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6316;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5360;

        ------------------------------------------------------------
        -- Expedient "00017/2021/5039"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2067;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2067;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3492;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3493;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6326;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6327;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6328;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5368;

        ------------------------------------------------------------
        -- Expedient "00017/2021/5061"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2068;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2068;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3494;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3495;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6329;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6330;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6331;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5370;

        ------------------------------------------------------------
        -- Expedient "00017/2021/5069"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2069;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2069;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3496;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3497;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6332;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6333;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6334;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5372;

        ------------------------------------------------------------
        -- Expedient "00017/2021/5106"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2070;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2070;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3498;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3499;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6335;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6336;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6337;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5374;

        ------------------------------------------------------------
        -- Expedient "00017/2021/5130"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2071;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2071;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3500;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3501;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6338;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6339;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6340;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5376;

        ------------------------------------------------------------
        -- Expedient "00017/2021/4956"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2056;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2056;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3471;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3472;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6294;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6295;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6296;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5347;

        ------------------------------------------------------------
        -- Expedient "00017/2020/329"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2065;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2065;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3488;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3489;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6320;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6321;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6322;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5364;

        ------------------------------------------------------------
        -- Expedient "00017/2021/3293"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2064;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2064;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3486;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3487;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6317;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6318;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6319;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5362;

        ------------------------------------------------------------
        -- Expedient "00017/2021/3079"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2052;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2052;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3463;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3464;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6282;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6283;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6284;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5339;

        ------------------------------------------------------------
        -- Expedient "00017/2021/3237"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2053;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2053;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3465;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3466;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6285;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6286;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6287;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5341;

        ------------------------------------------------------------
        -- Expedient "00017/2021/3381"
        ------------------------------------------------------------

        -- eco_dret:
        UPDATE eco_dret
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2066;

        -- eco_nomina
        UPDATE eco_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 2066;

        -- eco_moviment_detall
        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 3490;

        UPDATE eco_moviment_detall
        SET data_efecte_inicial='2021-08-01 00:00:00'
        WHERE id = 3491;        

        -- eco_efecte_moviment_nomina
        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-07-01 00:00:00', 
            data_efecte_fi='2021-07-01 00:00:00'
        WHERE id = 6323;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-08-01 00:00:00', 
            data_efecte_fi='2021-08-01 00:00:00'
        WHERE id = 6324;

        UPDATE eco_efecte_moviment_nomina
        SET data_efecte_inici='2021-09-01 00:00:00'
        WHERE id = 6325;

        -- eco_activitat
        UPDATE eco_activitat
        SET data_efecte_inicial='2021-07-01 00:00:00', 
            data_efecte_final='2021-07-01 00:00:00'
        WHERE id = 5366;

		-------------------------------------------------------------------------------------------------
		INSERT INTO registre_scripts (script,descripcio) VALUES ('ESOCIAL-14405','Correcció dades producció');
		-------------------------------------------------------------------------------------------------
		RAISE NOTICE 'INFO: END Processing ESOCIAL-14405.sql';
	END IF;
END
$$;