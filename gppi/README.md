## gPFI - Payroll Performance Information

Created by gluques.  
Barcelona, July 10, 2020.

#### Historial de versiones

    Fecha       Descripción                                                                             Implementado
    ----------  -----------------------------------------------------------------------------------     ------------
    10/07/2020  Creación de la primera versión del script.                                              Versión 1.0
    
    16/07/2020  Añadir la posibilidad de seleccionar qué datos se desean mostrar ("check").             Versión 2.0
    
    16/07/2020  Añadir totalizadores de importes a las tablas:                                          Versión 2.0
                    - eco_prestacio_reserva 
                    - eco_activitat_detall  
                    - eco_dret_teoric   
                    - eco_dret_teoric_detall    
                    - eco_percebut  
                    - eco_percebut_detall   
                    - eco_ordenacio_pagament    
                    - eco_ordenacio_pagament_detall 
                    - eco_liquidat                          
                    
    16/07/2020  Añadir tablas Ordenació Pagaments y Liquidats.                                          Versión 2.0
    
    16/07/2020  Ordenar la tabla eco_activitat_detall por Id de Nòmina Mensual y Data Efecte.           Versión 2.0
    
    17/07/2020  Añadir el número de registros por tabla.                                                Versión 2.0    
    
    19/07/2020  Ordenar tabla eco_activitat_detall por Id Activitat, Id Nòmina Mensual,                 Versión 2.1
                Data de Efecte i Id.        
                
    19/07/2020  Añadir posibilidad de ejecución con "dret_id" y "numeroExpedient".                      Versión 3.0
    
    23/07/2020  Añadir totalizador de importes a la tabla eco_deute_detall.                             Versión 2.2
    
    03/09/2020  Añadir columna "deute_id" al listado de registros de la tabla "eco_deute_detall".       Versión 3.1
    
    07/08/2020  Añadir columna "liquidacio" al listado de registros de la tabla "eco_activitat".        Versión 3.2
    
    07/08/2020  Ordenación por "data_efecte" de los registros de la tabla "eco_activitat_detall".       Versión 3.2
    
    18/09/2020  Cambio todos los "RAISE NOTICE" por "RAISE INFO".                                       Versión 4.0
    
    18/09/2020  Se agrega a la cabecera información:                                                    Versión 4.0
                    - Exp.Prestació Id 
                    - Procediment Id
                    - Tramit Id
                    
    18/09/2020  Se agrega el nuevo apartado "Informació de situació".                                   Versión 4.0
    
    18/09/2020  Se agrega el nuevo apartado "Resum imports taules".                                     Versión 4.0
    
    18/09/2020  Se tabulan a la derecha los datos de las tablas del apartado "Dades taules".            Versión 4.0
    
    18/09/2020  Se crean "checks" para mostrar o ocultar:                                               Versión 4.0
                    - Informació de situació                    
                    - Informació de situació dret
                    - Informació de situació nomina
                    - Informació de situació persona
                    - Informació de situació nomina mensual                    
                    - Resum imports taules
                    
    21/09/2020  Evitar que se muestre información cuando indico una prestación que no dispone           Versión 4.1
                de Dret.  
    
    11/03/2021  Modificar cabecera para que incluya más información de resumen:                         Versión 5.0
                    - Eliminar referencias DXC.
                    - Modificar la presentacion y añadir los siguientes campos a la cabecera:
                        * Tipus nòmina
                        * Alta nòmina
                        * Primera execució
                        * Efecte inici
                        * Estat
                        * Últim efecte
                        * Tipus efecte
                        * Import actual
                        * Import anterior
                        * Data últim percebut 
                        * Import últim percebut
                        * Id Última nòmina mensual
                        * Data generació nòmina mensual
                        * Data nòmina mensual
                        * Estat nòmina mensual
                    - Creación de un "check" para mostrar únicamente la cabecera. 
                    - Se añade el campo que indica la fecha de modificación del registro 
                      a las tablas:                    
                        * Dret Reserva                        
                        * Activitat
                        * Dret Teòric
                    

    
                
    

    
       
                
