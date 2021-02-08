####################################################################################################################################
# eTtools - eSocial Tools v.1.0 2020
#
# Created by gluques
# Barcelona, November 20, 2020.
####################################################################################################################################

# ------------------------------------------------------------------------------------------
# CONSTANTS
# ------------------------------------------------------------------------------------------
YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`
HOUR=`date +%H`
MINUTE=`date +%M`
SECOND=`date +%S`

# ------------------------------------------------------------------------------------------
# Global variables
# ------------------------------------------------------------------------------------------
# Paths:
base_root_path="C:/gluques"
base_gtools_path="$base_root_path/srcown/esfds-eSocial/etools"
base_artifacts_path="$base_root_path/src"
yml_local_jpa_bck_file="$base_gtools_path/bckyml/application-local_jpa.yml"
yml_local_jpa_restore_path="$base_artifacts_path/esocial-jpa-repositories/src/main/resources/application-local.yml"
yml_local_back_bck_file="$base_gtools_path/bckyml/application-local_back.yml"
yml_local_back_restore_path="$base_artifacts_path/portal-empleat-public-back/src/main/resources/config/application-local.yml"

# Arrays:
declare -a arrayVersions=("eSocial-Core-Front" 
                          "esocial-dynamic-blocks" 
                          "esocial-jpa-repositories" 
                          "esocial-services" 
                          "portal-ciutada-back" 
                          "portal-empleat-public-back" 
                          "portal-empleat-public-front")
arrayVersionsLength=${#arrayVersions[@]}                          
                          
declare -a arrayYMLRestore=("esocial-jpa-repositories"
                            "portal-empleat-public-back")

# Artifacts version file and tags:
artifacts_version_file="pom.xml"
artifacts_initial_tag="<version>"
artifacts_final_tag="</version>"

# Colors:
fg_default_color="\e[39m"
fg_red_color="\e[31m"
fg_green_color="\e[32m"
fg_yellow_color="\e[33m"
fg_white_color="\e[97m"
fg_light_blue_color="\e[94m"

bg_default_color="\e[49m"
bg_green_color="\e[42m"

#Prompt:
PROMPT="[gt-$DAY-$MONTH-$YEAR $HOUR:$MINUTE:$SECOND]"

# ------------------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------------------
# ----------------------------------------------
# Show Version Artifacts:
# ----------------------------------------------
function showVersionArtifacts() {    
    echo -e "$PROMPT Version of the artifacts:"
    echo
    printf "\t> Source code root path: $base_artifacts_path\n\n"    
    for (( i=1; i<${arrayVersionsLength}+1; i++ ));
    do          
        version_file_path="$base_artifacts_path/${arrayVersions[$i-1]}/$artifacts_version_file"        
        searching=1        
        while IFS= read -r line && [[ searching -eq 1 ]]
        do        
            version=$line
            version="$(grep -Po -m 1 '(?<=<version>).*(?=</version>)')"
            lengthVersion=${#version}
            if [[ lengthVersion -gt 0 ]];
            then                
                searching=0
            fi
        done <"$version_file_path"  
        if [[ searching -eq 0 ]]
        then
            printf "\t> ${arrayVersions[$i-1]} $version\n"
        else
            printf "\t> ${arrayVersions[$i-1]} [No version]\n"
        fi
    done
}
# ----------------------------------------------
# Restore Application Local Files
# ----------------------------------------------
function restoreAppLocalFiles() {
    echo -e "$fg_light_blue_color$PROMPT Restore application local YML files:"
    echo
    printf "\t> Application file for Back:\t$yml_local_back_bck_file\n"
    printf "\t> Destination path Back file:\t$yml_local_back_restore_path\n"
    cp -r $yml_local_back_bck_file $yml_local_back_restore_path
    if [[ ! $? -eq 0 ]]
    then
        echo -e "$fg_red_color\t> ERROR: file cannot be copied."                
    else     
        echo -e "\t> File copied successfully."                    
    fi
    echo
    printf "$fg_light_blue_color\t> Application file for JPA:\t$yml_local_jpa_bck_file\n"
    printf "\t> Destination path JPA file:\t$yml_local_jpa_restore_path\n"
    cp -r $yml_local_jpa_bck_file $yml_local_jpa_restore_path
    if [[ ! $? -eq 0 ]]
    then        
        echo -e "$fg_red_color\t> ERROR: file cannot be copied."                
    else     
        echo -e "\t> File copied successfully."                    
    fi
}
# ----------------------------------------------
# Restore Application Local Files
# ----------------------------------------------
function cloneFrontRepositories() {
    echo -e "$fg_light_blue_color$PROMPT Restore application local YML files:"
    echo
    echo -e "$fg_yellow_color\t> Not implemented."   
    
    # Parámetro directorio destino; se podría indicar o no.
    # Parámetro eliminar o no directorios existentes; se podrían renombrar.
    # Parámetro rama del proyecto a clonar; se podría indicar o no.
}
# ----------------------------------------------
# Script Show Help:
# ----------------------------------------------
function showHelp() {
    echo -e "$PROMPT eTools Help:"
    echo
    printf " Usage: etools [OPTION]\n"
    printf " Options:\n"    
    printf "\t-av\t\tShow artifacts version.\n"    
    echo
    printf "\t-ry\t\tRestore the 'application-local.yml' file for the following projects:\n"
    arrayVersionsLength=${#arrayYMLRestore[@]}
    for (( i=1; i<${arrayVersionsLength}+1; i++ ));
    do
        printf "\t\t\t  - ${arrayYMLRestore[$i-1]}\n"
    done
    echo
    printf "\t-cf\t\tClone Front repositories.\n"    
    echo
}
# ------------------------------------------------------------------------------------------
# Script main
# ------------------------------------------------------------------------------------------
echo -e "$fg_light_blue_color$PROMPT eTools v.1.0 2020 by gluques";
if [[ $# == 1 ]]
then
    case $@ in 
    '--help')
        showHelp;;
    '-av') 
        showVersionArtifacts;;    
    '-ry')
        restoreAppLocalFiles;;
    '-cf')
        cloneFrontRepositories;;
    *)
        echo -e "$fg_red_color$PROMPT ERROR: unknown command '$@'."
        echo -e "$fg_light_blue_color$PROMPT Use the --help parameter for help.";;
    esac
else
    echo -e "$fg_red_color$PROMPT ERROR: incorrect number of arguments."
    echo -e "$fg_light_blue_color$PROMPT Use the --help parameter for help."
fi

