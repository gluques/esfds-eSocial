---------------------------------------------------------------------------------------------------------------------
--  eSPDB_Nomina_Mensual.sql
--	Recopilación de sentencias SQL asociadas a la nómina mensual.
-- 
--  Created by gluques. 
--  Barcelona, April 17, 2021. 
--  						  																					   								    
--  Last update: 17/04/2021
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
-- NOMINA MENSUAL
--
--  [01] FASES NÒMINA MENSUAL
--
---------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------
-- [01] FASES NÒMINA MENSUAL
-----------------------------------------------------------------------
SELECT enmf.id, enmf.codi, enmf.nom_curt, lvi.descripcio
FROM eco_nomina_mensual_fase enmf	
	JOIN llistat_valors lv ON enmf.llistat_valors_id = lv.id
	JOIN llistat_valors_idioma lvi ON lv.id = lvi.llistat_valors_id
ORDER BY enmf.codi;

