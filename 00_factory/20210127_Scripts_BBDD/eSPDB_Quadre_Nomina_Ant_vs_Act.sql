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
SET SCHEMA 'esocial';
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
							    WHERE eqn.nomina_mensual_id = 67);--
-- eco_quadre_nomina:            
--
SELECT * FROM eco_quadre_nomina eqn WHERE eqn.nomina_mensual_id = 67;                    
DELETE FROM eco_quadre_nomina eqn WHERE eqn.nomina_mensual_id = 67;
--
-- eco_nomina_mensual_quantitat:
--
SELECT * FROM eco_nomina_mensual_quantitat enmq WHERE enmq.nomina_mensual_id = 67;
DELETE FROM eco_nomina_mensual_quantitat enmq WHERE enmq.nomina_mensual_id =67;
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
SELECT * FROM eco_excel_quadre_nomina WHERE nomina_mensual_id = 67;
DELETE FROM eco_excel_quadre_nomina WHERE nomina_mensual_id = 67;
-----------------------------------------------------------------------
-- [03] ACTIVITAT DETALL QUADRE
-----------------------------------------------------------------------
SELECT DISTINCT actdet.nomina_id AS "Id Nòmina",
		        actdet.id AS "Id Act.Detall",
		        actdet.data_efecte AS "Data Efecte",
		        actdet.quantitat AS "Quantitat",
		        actdet.pagament_tipus_id AS "T.Pagament",
		        efemovnom.id AS "Id Efecte",
		        efemovnom.tipus_id AS "Id T.Efecte",
		        efemovnom.import_actual AS "Imp.Actual",
		        efemovnom.import_anterior AS "Imp.Anterior",
		        efemovnom.diferencial AS "Diferencial",
		        efemovnom.data_efecte_inici AS "D.Efecte Inici",
		        act.tipus_incidencia_id AS "T.Incidencia",
		        actdet.pagament_modalitat_id AS "Id Modalitat"
FROM eco_activitat_detall actdet
 JOIN eco_activitat act ON actdet.activitat_id = act.id
 JOIN eco_moviment mov ON act.moviment_id = mov.id
 JOIN eco_moviment_detall movdet ON mov.id = movdet.moviment_id,
 eco_efecte_moviment_nomina efemovnom
WHERE movdet.id = efemovnom.moviment_detall_id
  AND actdet.nomina_mensual_id = 67
  AND efemovnom.data_efecte_inici <= '2021-04-01 00:00:00'
  AND (efemovnom.data_efecte_fi IS NULL OR efemovnom.data_efecte_fi >= actdet.data_efecte)
  AND efemovnom.data_efecte_inici <= actdet.data_efecte
ORDER BY actdet.nomina_id, actdet.data_efecte;
