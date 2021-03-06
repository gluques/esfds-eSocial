####################################################################################################################################
# eTtools - eSocial Tools v.2.0 2020-21 release 20210615
#
# Created by gluques
# Barcelona, November 20, 2020.
#
# Last updated on 15/06/2021
#
####################################################################################################################################
# ------------------------------------------------------------------------------------------
# Global variables
# ------------------------------------------------------------------------------------------
# ----------------------------------------------
# Date and Time
# ----------------------------------------------
YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`
HOUR=`date +%H`
MINUTE=`date +%M`
SECOND=`date +%S`
# ----------------------------------------------
# Foreground colors
# ----------------------------------------------
FG_LIGHT_BLUE_COLOR="\e[94m"
FG_RED_COLOR="\e[31m"
FG_YELLOW_COLOR="\e[33m"
# ----------------------------------------------
# Paths
# ----------------------------------------------
ROOT_FOLDER_PATH_ARTIFACTS="C:/gluques/src"
ROOT_FOLDER_PATH_ARTIFACTS_MASTER="$ROOT_FOLDER_PATH_ARTIFACTS/master"
ROOT_FOLDER_PATH_ARTIFACTS_SUB_MASTER="$ROOT_FOLDER_PATH_ARTIFACTS/sub_master"
ROOT_FOLDER_PATH_ARTIFACTS_DEV="$ROOT_FOLDER_PATH_ARTIFACTS/dev"
# ----------------------------------------------
# File names
# ----------------------------------------------
ARTIFACTS_VERSION_FILE="pom.xml"
# ----------------------------------------------
# Arrays:
# ----------------------------------------------
declare -a arrayArtifacts=("esocial-dynamic-blocks"
                           "esocial-jpa-repositories"
                           "esocial-services" 
                           "portal-empleat-public-back" 
                           "portal-ciutada-back" 
                           "eSocial-Core-Front" 
                           "portal-empleat-public-front")
arrayArtifactsLength=${#arrayArtifacts[@]}
# ------------------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------------------
# ----------------------------------------------
# Show Version Artifacts:
# ----------------------------------------------
function showVersionArtifacts() { 
    if [[ $1 == "mas" ]]        
    then
        root_path=$ROOT_FOLDER_PATH_ARTIFACTS_MASTER
    elif [[ $1 == "sub" ]];        
    then    
        root_path=$ROOT_FOLDER_PATH_ARTIFACTS_SUB_MASTER
    else
        root_path=$ROOT_FOLDER_PATH_ARTIFACTS_DEV
    fi
    printf "$FG_LIGHT_BLUE_COLOR%s: $root_path\n" "Root folder path of artifacts"
    printf "List of artifacts:\n\n"
    printf "%0.s " {1..5}
    printf "Artifact name\t\t\tVersion\t\tBranch\n"
    printf "%0.s " {1..5}
    printf "%0.s-" {1..30} 
    printf "\t"
    printf "%0.s-" {1..14} 
    printf "\t"
    printf "%0.s-" {1..40} 
    printf "\n"    
    artifactReferenceId=1
    for (( i=1; i<${arrayArtifactsLength}+1; i++ ));
    do          
        path="$root_path/${arrayArtifacts[$i-1]}"        
        cd $path        
        branch="$(git branch --show-current)"
        version_file_path="$path/$ARTIFACTS_VERSION_FILE"        
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
        if [[ searching -ne 0 ]]
        then
            version="Unknown"
        fi                
        length=${#arrayArtifacts[$i-1]}        
        if [[ $length -lt  19 ]]
        then
            printf " (%d) %s\t\t\t%s\t\t%s\n" $artifactReferenceId "${arrayArtifacts[$i-1]}" "$version" "$branch"
        elif [[ $length -gt 26 ]]
        then
            printf " (%d) %s\t%s\t\t%s\n" $artifactReferenceId "${arrayArtifacts[$i-1]}" "$version" "$branch"
        else        
            printf " (%d) %s\t\t%s\t\t%s\n" $artifactReferenceId "${arrayArtifacts[$i-1]}" "$version" "$branch"
        fi        
        artifactReferenceId=$((artifactReferenceId+1))
    done    
}
# ----------------------------------------------
# Script Show Help:
# ----------------------------------------------
function showHelp() {    
    printf "\n$FG_LIGHT_BLUE_COLOR%s\n" " Usage: etools command"
    printf "%s\n\n" " Commands:"   
    printf "   -la enviroment\t\tDisplays the version of the artifacts available for the specified environment.\n"    
    printf "\t\t\t\tEnviroment values: 'mas', 'sub' or 'dev'\n"    
    printf "\n%s\n\n" " Internal constants:"
    printf "   Path artifacts:\t\t$ROOT_FOLDER_PATH_ARTIFACTS\n"
    printf "   Path artifacts master:\t$ROOT_FOLDER_PATH_ARTIFACTS_MASTER\n"
    printf "   Path artifacts sub_master:\t$ROOT_FOLDER_PATH_ARTIFACTS_SUB_MASTER\n"
    printf "   Path artifacts development:\t$ROOT_FOLDER_PATH_ARTIFACTS_DEV\n"
    printf "   Artifacts version file:\t$ARTIFACTS_VERSION_FILE\n"
    printf "   List of artifacts:\n"
    for (( i=1; i<${arrayArtifactsLength}+1; i++ ));
    do
        printf "   \t\t\t\t${arrayArtifacts[$i-1]}\n"
    done
}
# ----------------------------------------------
# Check command parameters
# ----------------------------------------------
function checkParametersVersionArtifacts() {    
    check=0
    if [[ $1 > 1 && $1 < 3 ]]
    then
        if [[ $2 == "mas" || $2 == "sub" || $2 == "dev" ]]
        then 
            check=1
        else 
            echo -e "$FG_RED_COLOR""Error: the environment '$2' is not correct."
            echo -e "$FG_YELLOW_COLOR""Try 'etools --help' for more information."
        fi
    else 
        echo -e "$FG_RED_COLOR""Error: wrong number of parameters."
        echo -e "$FG_YELLOW_COLOR""Try 'etools --help' for more information."
    fi
    return $check
}
# ----------------------------------------------
# Check command
# ----------------------------------------------
function checkCommand() {
    #printf "Params: $1 - $2 - $3 -$4 - $5 - $6 - $7 - $8 - $9\n"
    case $2 in 
        '--help') 
            showHelp;;
        '-la') 
            checkParametersVersionArtifacts $1 $3
            if [[ $? == 1 ]]
            then
                showVersionArtifacts $3
            fi;;
    *)
        echo -e "$FG_RED_COLOR""Error: unknown command '$2'."
        echo -e "$FG_YELLOW_COLOR""Try 'etools --help' for more information."
    esac
}
# ------------------------------------------------------------------------------------------
# Script main
# ------------------------------------------------------------------------------------------
echo -e "$FG_LIGHT_BLUE_COLOR""eTools v.2.0 release 20210615 by gluques";
if [[ $# > 0 ]]
then
    checkCommand $# $@
else
    echo -e "$FG_RED_COLOR""Error: an argument is required."
    echo -e "$FG_YELLOW_COLOR""Try 'etools --help' for more information."
fi

