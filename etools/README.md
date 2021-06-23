## eTools - eSocial Tools

Created by gluques.  
Barcelona, September 10, 2020

#### Historial de versiones

    Fecha           Descripción                                                                         Implementado
    ----------      --------------------------------------------------------------------------          ------------
    10/09/2020      Versión inicial.                                                                    Version 1.0
                    Opción "-av" para mostrar la versión de los artefactos.
                    Opción "-ry" para restaurar los ficheros YML.
                    Opción "--help" muestra ayuda.
                    
    27/01/2021      Opción "-cf" para clonar los repositorios de frontal "eSocial-Core-Front"           No implementado
                    y "portal-empleat-public-front"
                    
    27/01/2021      Hacer que la opción "-av" muetre la "rama" activa de los artefactos.                No implementado
                    Comando "git branch --show-current"
                    
    28/01/2021      Refactorización del código para el tratamiento de sub-parámetros.                   No implementado
    
    15/06/2021      Inicio el proyecto desde cero con el único comando "-la" que permite                Version 2.0
                    mostrar las versiones de los artefactos en los entornos de master,
                    sub_master y dev.
                    
    23/06/2021      Nuevo comando "-log" que permite la descarga de los ficheros de log de los          Version 2.1
                    entornos "INT", "PRE" y "PRO".