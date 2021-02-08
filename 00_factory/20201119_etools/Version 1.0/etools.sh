####################################################################################################################################
# eTtools - eSocial Tools v.2.0 release 25122020
#
# Created by gluques
# Barcelona, November 20, 2020.
#
####################################################################################################################################
#
# Add the path and alias 'etools' to the bash console: 
#   
#   $ nano ~/.bashrc
#   ...
#   ###-etools-###
#   PATH=/c/gluques/srcown/esfds-eSocial/etools/.:$PATH
#   alias etools="sh etools.sh"
#   ###-etools-###
#   ...
#
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
root_folder_path_gtools="C:/gluques/srcown/esfds-eSocial/etools"
root_folder_path_artifacts="C:/gluques/src"

yml_jpa_path_backup_file="$root_folder_path_gtools/bckyml/application-local_jpa.yml"
yml_jpa_path_restore_file="$root_folder_path_artifacts/esocial-jpa-repositories/src/main/resources/application-local.yml"
yml_back_path_backup_file="$root_folder_path_gtools/bckyml/application-local_back.yml"
yml_back_path_restore_file="$root_folder_path_artifacts/portal-empleat-public-back/src/main/resources/config/application-local.yml"

# Arrays:
declare -a arrayArtifacts=("eSocial-Core-Front" 
                           "esocial-dynamic-blocks" 
                           "esocial-jpa-repositories" 
                           "esocial-services" 
                           "portal-ciutada-back" 
                           "portal-empleat-public-back" 
                           "portal-empleat-public-front")
arrayArtifactsLength=${#arrayArtifacts[@]}                          
                          
declare -a arrayYMLRestore=("esocial-jpa-repositories"
                            "portal-empleat-public-back")

# Artifacts version file and tags:
artifacts_version_file="pom.xml"
artifacts_version_initial_tag="<version>"
artifacts_version_final_tag="</version>"

# Logs eScoail
log_param_env='.'
log_param_all=0
log_param_folder='.'
log_param_dat='.'
log_pattern_files_empleat="*empleat*"
log_host_path_int="esocial@10.49.56.56:/serveis/log/int/esocial/jboss/esocial/"
log_host_user_int="sftphpvass"
log_host_pass_int="T3mp0r@l"

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
    printf "Root folder path of artifacts $root_folder_path_artifacts\n"
    echo -e "Version of the artifacts:"
    echo        
    for (( i=1; i<${arrayArtifactsLength}+1; i++ ));
    do          
        version_file_path="$root_folder_path_artifacts/${arrayArtifacts[$i-1]}/$artifacts_version_file"        
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
            printf "\t> ${arrayArtifacts[$i-1]} $version\n"
        else
            printf "\t> ${arrayArtifacts[$i-1]} [No version]\n"
        fi
    done
}
# ----------------------------------------------
# Restore Application Local Files
# ----------------------------------------------
function restoreAppLocalFiles() {
    echo "Restore application local YML files:"
    echo
    printf "\t> Application file for Back:\t$yml_back_path_backup_file\n"
    printf "\t> Destination path Back file:\t$yml_back_path_restore_file\n"
    cp -r $yml_back_path_backup_file $yml_back_path_restore_file
    if [[ ! $? -eq 0 ]]
    then
        echo -e "$fg_red_color\t> ERROR: file cannot be copied."                
    else     
        echo -e "\t> File copied successfully."                    
    fi
    echo
    printf "$fg_light_blue_color\t> Application file for JPA:\t$yml_jpa_path_backup_file\n"
    printf "\t> Destination path JPA file:\t$yml_jpa_path_restore_file\n"
    cp -r $yml_jpa_path_backup_file $yml_jpa_path_restore_file
    if [[ ! $? -eq 0 ]]
    then        
        echo -e "$fg_red_color\t> ERROR: file cannot be copied."                
    else     
        echo -e "\t> File copied successfully."                    
    fi
}
# ----------------------------------------------
# Get Log Empleat:
# ----------------------------------------------
function getLogEmpleat() {        
    checkLogArguments $1 $2 $3 $4 $5 $6 $7        
    if [[ $? == 0 ]]
    then
        echo "Enviroment.........: $log_param_env"        
        if [[ $log_param_all == 1 ]]
        then        
            echo "Download all files.: Yes"
        else
            echo "Download all files.: No"
        fi
        echo "Destination folder.: $log_param_folder"
        echo "Date of files......: $log_param_dat"
        if [[ 
        if [[ $log_param_folder == "." ]]
        then
            log_param_folder=$PWD
        fi                
        if [[ $log_param_env == "INT" ]]
        then
            echo "Downloading log files from the integration environment..."
            
            echo "Local destination folder $log_param_folder"
            
            curl --insecure --user sftphpvass:T3mp0r@l -T esocial@10.49.56.56:/serveis/log/int/esocial/jboss/esocial/*empleat* sftp::C:/gluques
            
            #scp $log_host_path_int 
            
            #scp -o PreferredAuthentications="T3mp0r@l" esocial@10.49.56.56:/serveis/log/int/esocial/jboss/esocial/empleat_1.log .
            #curl --insecure --user username:password -T /path/to/sourcefile sftp://desthost/path/
            #log_pattern_files_empleat="*empleat*"
            #log_host_path_int="esocial@10.49.56.56:/serveis/log/int/esocial/jboss/esocial/"
            #log_host_user_int="sftphpvass"
            #log_host_pass_int="T3mp0r@l"            
            #log_param_env='.'
            #log_param_all=0
            #log_param_folder='.'
            #log_param_dat='.'
            
        else
            echo "Downloading log files from the production environment..."
            echo "Local destination folder $log_param_folder"
        fi
    fi
}
# ----------------------------------------------
# Check log command arguments
#
#   -log {INT, PRO}                                                 2
#   -log {INT, PRO} [-all]                                          3
#
# ----------------------------------------------
checkLogArguments() {
    retVal=0
    
    echo
    echo "checkLogArguments"    
    echo "1 - $1"
    echo "2 - $2"
    echo "3 - $3"
    echo "4 - $4"
    echo "5 - $5"
    echo "6 - $6"
    echo "7 - $7"
        
    if [[ $1 > 1 && $1 < 8 ]]
    then
        if [[ $2 == "INT" || $2 == "PRO" ]]
        then    
            log_param_env=$2
        else
           echo -e "$fg_red_color""Error: the environment '$2' is not correct."           
           retVal=2
        fi
        if [[ $retVal == 0 && $1 > 2 ]]
        then
            if [[ $3 == "-f" || $3 == "-d" || $3 == "-all" ]]                
            then            
                if [[ $3 == '-all' ]]
                then 
                    log_param_all=1
                    if [[ $1 > 3 ]]
                    then
                        echo -e "$fg_red_color""Error: syntax error."
                        retVal=4
                    fi
                else 
                    if [[ $1 > 3 ]]
                    then
                        if [[ $3 == "-f" ]]
                        then 
                            checkLogArgumentsFirstFolder $1 $4 $5 $6 $7 $8
                        else
                            checkLogArgumentsFirstDate $1 $4 $5 $6
                        fi
                    else
                        if [[ $3 == "-f" ]]
                        then 
                            echo -e "$fg_red_color""Error: destination folder not specified."
                            retVal=5
                        else
                            echo -e "$fg_red_color""Error: no date has been specified."
                            retVal=6
                        fi                        
                    fi
                fi
            else
                echo -e "$fg_red_color""Error: parameter '$4' unknown."
                retVal=3
            fi
            
        fi
    else
        echo -e "$fg_red_color""Error: wrong number of arguments."
        retVal=1
    fi
    if [[ $retVal > 0 ]] 
    then
        echo -e "$fg_yellow_color""Try 'etools --help' for more information."
    fi
    return $retVal
}
#
#   -log {INT, PRO} [-f destination_folder]                         4
#   -log {INT, PRO} [-f destination_folder] [-all]                  5
#   -log {INT, PRO} [-f destination_folder] [-d date]               6
#   -log {INT, PRO} [-f destination_folder] [-d date] [-all]        7
#
function checkLogArgumentsFirstFolder() {
    echo
    echo "Firs Folder"    
    echo "1 - $1"
    echo "2 - $2"
    echo "3 - $3"
    echo "4 - $4"
    echo "5 - $5"
    echo "6 - $6"
    echo "7 - $7"    
}
#
#   -log {INT, PRO} [-d date]                                       4
#   -log {INT, PRO} [-d date] [-all]                                5
#
function checkLogArgumentsFirstDate() {
    echo
    echo "Firs Date"
    echo "1 - $1"
    echo "2 - $2"
    echo "3 - $3"
    echo "4 - $4"
    echo "5 - $5"
    echo "6 - $6"
    echo "7 - $7"
    
    retVal=0    
    case $1 in 
        4) log_param_dat=$2;;
        5) log_param_dat=$2
           if [[ $3 == "-all" ]]
           then
            log_param_all=1
           else
            echo -e "$fg_red_color""Error: parameter '$3' unknown."
            retVal=8
           fi;;            
    *)
        echo -e "$fg_red_color""Error: wrong number of arguments."
        retVal=7
    esac    
    return $retVal
}
# ----------------------------------------------
# Script Show Help:
# ----------------------------------------------
function showHelp() {    
    echo
    printf " Usage: etools command\n"
    printf " Commands:\n"   
    echo    
    printf "   -av\t\t    Show the version of the following artifacts in the locale:\n" 
    echo
    for (( i=1; i<${arrayArtifactsLength}+1; i++ ));
    do          
        printf "\t\t      > ${arrayArtifacts[$i-1]}\n"
    done
    echo
    printf "   -ry\t\t    Restore the 'application-local.yml' file for the following projects:\n"
    echo
    arrayYMLRestoreLength=${#arrayYMLRestore[@]}
    for (( i=1; i<${arrayYMLRestoreLength}+1; i++ ));
    do
        printf "\t\t      > ${arrayYMLRestore[$i-1]}\n"
    done
    echo
    printf "   -log arguments   Download log files using Secure Copy Protocol (SCP).\n"  
    printf "\t\t    Usage: -log {INT, PRO} [-f destination_folder] [-d date] [-all]\n"
    echo
    printf "\t\t      {INT, PRO}    Environment of the log file to download.\n"    
    printf "\t\t      -f            Folder where the logs will be downloaded. If not specified, it\n"
    printf "\t\t                    will be downloaded to the current folder.\n"
    printf "\t\t      -d            Date of the log file in the format 'yyyy-mm-dd'. If not indicated,\n"
    printf "\t\t                    the file corresponding to the current date will be downloaded.\n"
    printf "\t\t      -all          Indicates that you want to download all the log files. If not\n"
    printf "\t\t                    specified, only log files that contain the word 'empleat' as part\n"
    printf "\t\t                    of their name will be downloaded.\n"
    echo
}
# ----------------------------------------------
# Check command
# ----------------------------------------------
function checkCommand() {        
    echo "1 - $1"
    echo "2 - $2"
    echo "3 - $3"
    echo "4 - $4"
    echo "5 - $5"
    echo "6 - $6"
    echo "7 - $7"
    echo "8 - $8"
    case $2 in 
        '--help') showHelp;;
        '-av') showVersionArtifacts;;    
        '-ry') restoreAppLocalFiles;; 
        '-log') getLogEmpleat $1 $3 $4 $5 $6 $7 $8;; 
    *)
        echo -e "$fg_red_color""Error: unknown command '$2'."
        echo -e "$fg_yellow_color""Try 'etools --help' for more information."
    esac
}
# ------------------------------------------------------------------------------------------
# Script main
# ------------------------------------------------------------------------------------------
echo -e "$fg_light_blue_color""eTools v.2.0 release 20201225 by gluques";
    if [[ $# > 0 ]]
    then
    checkCommand $# $@    
else
    echo -e "$fg_red_color""Error: an argument is required."
    echo -e "$fg_yellow_color""Try 'etools --help' for more information."
fi


