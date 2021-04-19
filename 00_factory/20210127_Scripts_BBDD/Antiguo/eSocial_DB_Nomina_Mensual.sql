--
--	[02.04] ESTABLECER FASE NOMINA MENSUAL
--
-- Taula "eco_nomina_mensual":
		SELECT * FROM eco_nomina_mensual WHERE id = 48;
		SELECT * FROM eco_nomina_mensual WHERE tipus_nomina_id = 11 ORDER BY data_nomina DESC;
		
		--DELETE FROM eco_nomina_mensual WHERE id = 41;		
		UPDATE eco_nomina_mensual SET estat = 'ORDN', fase_id = 4 WHERE id = 48;
--		
-- Taula "eco_nomina_mensual_procediment":
		SELECT * FROM eco_nomina_mensual_procediment 
		WHERE nomina_mensual_id = 48 ORDER BY data_inici_procediment;

		DELETE FROM eco_nomina_mensual_procediment WHERE nomina_mensual_id = 48 AND id > 406;
--				 
-- Taula "eco_nomina_mensual_quantitat":
		SELECT * FROM eco_nomina_mensual_quantitat WHERE nomina_mensual_id = 48 ORDER BY id;	  

		DELETE FROM eco_nomina_mensual_quantitat WHERE nomina_mensual_id = 48;
--		
-- Taula "eco_control_errors":
		SELECT * FROM eco_control_errors	WHERE nomina_mensual_historic_id 
		IN (SELECT id FROM eco_nomina_mensual_procediment WHERE nomina_mensual_id = 48 AND id > 341)
		ORDER BY nomina_mensual_historic_id;

		--DELETE FROM eco_control_errors WHERE nomina_mensual_historic_id 
		--IN (SELECT id FROM eco_nomina_mensual_procediment WHERE nomina_mensual_id = 41 AND id > 341);
--
-- Taula "eco_nomina_mensual_procediment_quantitat":
		SELECT * FROM eco_nomina_mensual_procediment_quantitat 
		WHERE nomina_mensual_procediment_id 
		   IN (SELECT id FROM eco_nomina_mensual_procediment 
				 WHERE nomina_mensual_id = 41 AND id > 341);
				 
		/*		
		DELETE FROM eco_nomina_mensual_procediment_quantitat
		WHERE nomina_mensual_procediment_id 
		  IN (SELECT id FROM eco_nomina_mensual_procediment 
			   WHERE nomina_mensual_id = 41 AND id > 341);
		*/		
--		
-- Taula "eco_ordenacio_pagament":
		SELECT * FROM eco_ordenacio_pagament WHERE nomina_mensual_id = 43 ORDER BY nomina_id, id;

		--DELETE FROM eco_ordenacio_pagament WHERE nomina_mensual_id = 41;
--		
-- Taula "eco_ordenacio_pagament_detall":		
		SELECT * FROM eco_ordenacio_pagament_detall WHERE nomina_mensual_id = 41 ORDER BY nomina_id, id;

		--DELETE FROM eco_ordenacio_pagament_detall WHERE nomina_mensual_id = 41;
--
-- Taula "eco_incidencies_pagament":
		SELECT * FROM eco_incidencies_pagament 
		WHERE ordenacio_pagament_id IN (SELECT id FROM eco_ordenacio_pagament WHERE nomina_mensual_id = 43);		

		--DELETE FROM eco_incidencies_pagament 
		--WHERE ordenacio_pagament_id IN (SELECT id FROM eco_ordenacio_pagament WHERE nomina_mensual_id = 41);		
--		
-- Taula "eco_fitxer_pagaments_historic":
		SELECT * FROM eco_fitxer_pagaments_historic WHERE nomina_mensual_id = 43;		

		--DELETE FROM eco_fitxer_pagaments_historic WHERE nomina_mensual_id = 41;
--	   
-- Taula "eco_liquidat":
		SELECT * FROM eco_liquidat WHERE ordenacio_pagament_id
		IN (SELECT id FROM eco_ordenacio_pagament WHERE nomina_mensual_id = 41);
		
		--DELETE FROM eco_liquidat WHERE ordenacio_pagament_id 
	   --IN (SELECT id FROM eco_ordenacio_pagament WHERE nomina_mensual_id = 41);
--	   
-- Taula "eco_dret_teoric":
		SELECT * FROM eco_dret_teoric edt
		WHERE edt.dret_id IN 
			(SELECT act.dret_id 
			 FROM eco_activitat act
			 	 JOIN eco_activitat_detall actDet ON act.id = actDet.activitat_id
			 WHERE actDet.nomina_mensual_id = 41)
		  AND edt.data_efecte = '2020-12-01 00:00:00'
		ORDER BY edt.dret_id, edt.id DESC;
--
-- Taula "eco_dret_teoric_detall"		
	SELECT * FROM eco_dret_teoric_detall edtd
	WHERE edtd.quantitat > 0 
	  AND edtd.dret_id IN 
	  		(SELECT act.dret_id 
			 FROM eco_activitat act
			 	 JOIN eco_activitat_detall actDet ON act.id = actDet.activitat_id
			 WHERE actDet.nomina_mensual_id = 41)
		  AND edtd.data_efecte = '2020-12-01 00:00:00'
		ORDER BY edtd.dret_id, edtd.id DESC;
	
	/*
	UPDATE eco_dret_teoric_detall edtd SET tipus_pagament_id = NULL
	WHERE edtd.quantitat > 0 
	  AND edtd.dret_id IN 
	  		(SELECT act.dret_id 
			 FROM eco_activitat act
			 	 JOIN eco_activitat_detall actDet ON act.id = actDet.activitat_id
			 WHERE actDet.nomina_mensual_id = 41)
		  AND edtd.data_efecte = '2020-12-01 00:00:00';	
	*/
--
-- Taula "eco_activitat_detall"
		SELECT * FROM eco_activitat_detall WHERE nomina_mensual_id = 41;	  

		--DELETE FROM eco_activitat_detall WHERE nomina_mensual_id = 41; 
--		
-- Taula "eco_nomina_mensual_crida_externa_his":
		SELECT * FROM eco_nomina_mensual_crida_externa_his
		WHERE nomina_mensual_procediment_id 
		IN (SELECT id FROM eco_nomina_mensual_procediment 
			 WHERE nomina_mensual_id = 41 AND id > 340);	
	
		/*
		DELETE FROM eco_nomina_mensual_crida_externa_his
		WHERE nomina_mensual_procediment_id 
		IN (SELECT id FROM eco_nomina_mensual_procediment 
			 WHERE nomina_mensual_id = 41 AND id > 340);
		*/	
        
-------------------------------------
-- Volver a la fase de Generació Q34
-------------------------------------
-- Tablas implicadas:
SELECT * FROM eco_nomina_mensual enm WHERE enm.id = 67;
SELECT * FROM eco_nomina_mensual_procediment enmp WHERE enmp.nomina_mensual_id = 67 ORDER BY enmp.id;
SELECT * FROM eco_fitxer_pagaments_historic WHERE nomina_mensual_id = 67;

-- Cambiar estado:
DELETE FROM eco_fitxer_pagaments_historic WHERE nomina_mensual_id = 67;
DELETE FROM eco_nomina_mensual_procediment enmp WHERE enmp.nomina_mensual_id = 67 AND id > 592;
UPDATE eco_nomina_mensual SET estat = 'FQ34' WHERE id = 67;