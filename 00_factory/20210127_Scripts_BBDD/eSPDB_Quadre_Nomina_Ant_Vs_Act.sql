---------------------------------------------------------------------------------------------------------------------
--  eSPDB_Quadre_Nomina_Ant_vs_Act.sql
--	Recopilación de sentencias SQL asociadas al Quadre de Nòmina Anterior Vs. Actual.
-- 
--  Created by gluques. 
--  Barcelona, April 16, 2021. 
--  						  																					   								    
--  Last update: 17/04/2021
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
-- QUADRE NÒMINA ANTERIOR VS. ACTUAL
--
--  [01] TORNAR A GENERAR EL QUADRE
--  [02] TORNAR A GENERAR EXCEL QUADRE
--  [03] ACTIVITAT DETALL QUADRE
--
---------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------
-- [01] TORNAR A GENERAR EL QUADRE
-----------------------------------------------------------------------
--
-- eco_quadre_nomina_detall:
--
SELECT * FROM eco_quadre_nomina_detall eqnd 
WHERE eqnd.quadre_nomina_id IN (SELECT eqn.id FROM eco_quadre_nomina eqn 
							    WHERE eqn.nomina_mensual_id = 67);
                              
DELETE FROM eco_quadre_nomina_detall eqnd 
WHERE eqnd.quadre_nomina_id IN (SELECT id FROM eco_quadre_nomina eqn 
							    WHERE eqn.nomina_mensual_id = 67);
--
-- eco_quadre_nomina:            
--
SELECT * FROM eco_quadre_nomina eqn WHERE eqn.nomina_mensual_id = 67;
                    
DELETE FROM eco_quadre_nomina eqn WHERE eqn.nomina_mensual_id = 67;
--
-- eco_nomina_mensual_quantitat:
--
SELECT * FROM eco_nomina_mensual_quantitat enmq 
WHERE enmq.nomina_mensual_id = 67;

DELETE FROM eco_nomina_mensual_quantitat enmq 
WHERE enmq.nomina_mensual_id =67;
--
-- eco_nomina_mensual_procediment:
--
SELECT * FROM eco_nomina_mensual_procediment enmp 
WHERE enmp.nomina_mensual_id = 67 ORDER BY enmp.id;

DELETE FROM eco_nomina_mensual_procediment enmp 
WHERE enmp.nomina_mensual_id = 67 AND id > 584;
--
-- eco_nomina_mensual:
--
SELECT * FROM eco_nomina_mensual enm WHERE enm.id = 67;

UPDATE eco_nomina_mensual SET estat = 'ORDN' WHERE id = 67;

-----------------------------------------------------------------------
-- [02] TORNAR A GENERAR EXCEL QUADRE
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- [03] ACTIVITAT DETALL QUADRE
-----------------------------------------------------------------------
