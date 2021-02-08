####################################################################################################################################
# gtools.sh
# gluques Tools - v.1.0 2020
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
root_path="C:/gluques"
gtools_path="$root_path/tools/global/personal/factory/20201119_gtools/v1.0"
src_code_path="$root_path/src"
yml_local_jpa_bck_file="$root_path/mgm/01_Entornos/02_eSocial/application-local_jpa.yml"
yml_local_jpa_restore_path="$src_code_path/esocial-jpa-repositories/src/main/resources/application-local.yml"
yml_local_back_bck_file="$root_path/mgm/01_Entornos/02_eSocial/application-local_back.yml"
yml_local_back_restore_path="$src_code_path/portal-empleat-public-back/src/main/resources/config/application-local.yml"

# Arrays:
declare -a arrayVersions=("eSocial-Core-Front" 
                          "esocial-dynamic-blocks" 
                          "esocial-jpa-repositories" 
                          "esocial-services" 
                          "portal-ciutada-back" 
                          "portal-empleat-public-back" 
                          "portal-empleat-public-front")
                          
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
    printf "\t> Source code root path: $src_code_path\n\n"
    arrayVersionsLength=${#arrayVersions[@]}
    for (( i=1; i<${arrayVersionsLength}+1; i++ ));
    do          
        version_file_path="$src_code_path/${arrayVersions[$i-1]}/$artifacts_version_file"        
        searching=1        
        while IFS= read -r line && [[ searching -eq 1 ]]
        do        
            version=$line
            version="$(grep -Po -m 1 '(?<=<version>).*(?=</version>)')"
            lengthVersion=${#version}
            if [[ lengthVersion -gt 0 ]]
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
# Run Git Command
# ----------------------------------------------
function runGitCommand() {    
    echo -e "$PROMPT Git status:"
    arrayVersionsLength=${#arrayVersions[@]}
    for (( i=1; i<${arrayVersionsLength}+1; i++ ));
    do          
        path="$src_code_path/${arrayVersions[$i-1]}"                
        cd $path
        case $1 in 
        '0')            
            echo -e "$fg_light_blue_color$PROMPT ${arrayVersions[$i-1]} > git remote -v"        
            echo -e "$fg_default_color"
            git remote -v;;
        '1')
            echo -e "$fg_light_blue_color$PROMPT ${arrayVersions[$i-1]} > git branch --list"        
            echo -e "$fg_default_color"                        
            git branch --list;;            
        '2')
            echo -e "$fg_light_blue_color$PROMPT ${arrayVersions[$i-1]} > git status -v"        
            echo -e "$fg_default_color"
            git status -v;;
        '3')
            echo -e "$fg_light_blue_color$PROMPT ${arrayVersions[$i-1]} > git fetch"        
            echo -e "$fg_default_color"            
            git fetch;;            
        '4')            
            echo -e "$fg_light_blue_color$PROMPT ${arrayVersions[$i-1]} > git pull --rebase"        
            echo -e "$fg_default_color"            
            git pull --rebase;;
        *)
            echo -e "$fg_red_color$PROMPT ERROR: unknown git command '$1'."
        esac
        echo
    done
    cd $gtools_path
}
# ----------------------------------------------
# Script Show Help:
# ----------------------------------------------
function showHelp() {
    echo -e "$PROMPT Help:"
    echo
    printf " Usage: gtools [OPTION]\n"
    printf " Options:\n"    
    printf "\t-va\tShows the version of the following artifacts:\n"
    arrayVersionsLength=${#arrayVersions[@]}
    for (( i=1; i<${arrayVersionsLength}+1; i++ ));
    do
        printf "\t\t  - ${arrayVersions[$i-1]}\n"
    done
    echo
    printf "\t-ra\tRestore the 'application-local.yml' file for the following projects:\n"
    arrayVersionsLength=${#arrayYMLRestore[@]}
    for (( i=1; i<${arrayVersionsLength}+1; i++ ));
    do
        printf "\t\t  - ${arrayYMLRestore[$i-1]}\n"
    done
    echo
    printf "\t-gr\tShows the remote repository entries stored in the Git file './.git/config'.\n"
    printf "\t\tGit command: 'git branch --list'.\n"
    printf "\t\tApplies to the same projects listed for the '-va' gTools command\n"
    echo
    printf "\t-gb\tList all branches of your Git repository.\n"
    printf "\t\tGit command: 'git branch --list'.\n"
    printf "\t\tApplies to the same projects listed for the '-va' gTools command\n"
    echo
    printf "\t-gs\tShows the current state of your Git working directory and staging area.\n"    
    printf "\t\tGit command: 'git status -v'.\n"
    printf "\t\tApplies to the same projects listed for the '-va' gTools command\n"
    echo
    printf "\t-gf\tRetrieve all files from a remote Git repository that have been modified by other users (no merge).\n"
    printf "\t\tGit command: 'git fetch'.\n"
    printf "\t\tApplies to the same projects listed for the '-va' gTools command\n"
    echo
    printf "\t-gp\tDownload content from a remote Git repository and update the local repository (fetch + merge).\n"
    printf "\t\tGit command: 'git pull --rebase'.\n"
    printf "\t\tApplies to the same projects listed for the '-va' gTools command\n"
    echo
}
# ------------------------------------------------------------------------------------------
# Script main
# ------------------------------------------------------------------------------------------

echo -e "$fg_light_blue_color$PROMPT gTools v.1.0 2020";
if [[ $# == 1 ]]
then
    case $@ in 
    '--help')
        showHelp;;
    '-va') 
        showVersionArtifacts;;    
    '-ra')
        restoreAppLocalFiles;;
    '-gr')
        runGitCommand 0;;
    '-gb')
        runGitCommand 1;;        
    '-gs')
        runGitCommand 2;;        
    '-gf')
        runGitCommand 3;;        
    '-gp')
        runGitCommand 4;;
    *)
        echo -e "$fg_red_color$PROMPT ERROR: unknown command '$@'."
        echo -e "$fg_light_blue_color$PROMPT Use the --help parameter for help.";;
    esac
else
    echo -e "$fg_red_color$PROMPT ERROR: incorrect number of arguments."
    echo -e "$fg_light_blue_color$PROMPT Use the --help parameter for help."
fi
