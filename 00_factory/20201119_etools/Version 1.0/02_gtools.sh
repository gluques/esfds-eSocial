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
base_root_path="C:/gluques"
gtools_path="$base_root_path/tools/global/personal/factory/20201119_gtools/v1.0"
src_code_path="$base_root_path/src"
yml_local_jpa_bck_file="$base_root_path/mgm/01_Entornos/02_eSocial/application-local_jpa.yml"
yml_local_jpa_restore_path="$src_code_path/esocial-jpa-repositories/src/main/resources/application-local.yml"
yml_local_back_bck_file="$base_root_path/mgm/01_Entornos/02_eSocial/application-local_back.yml"
yml_local_back_restore_path="$src_code_path/portal-empleat-public-back/src/main/resources/config/application-local.yml"

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
# Option selector:
# ----------------------------------------------
function optionSelector() {    
    echo
    echo -e "$fg_light_blue_color  Available options:"
    echo        
    i=1
    for ((; i<${arrayVersionsLength}+1; i++ ));
    do
        echo "    $i - ${arrayVersions[$i-1]}"
    done    
    echo "    $i - All projects"
    optionAll=$i
    i=$(( $i + 1 ))
    echo "    $i - Cancel"    
    optionCancel=$i
    echo    
    printf "  > Select an option: "
    read option;
    if [[ $option -lt 1 || $option -gt $optionCancel ]]
    then
        echo -e "$fg_red_color  > Wrong option!"
        optionSelector
        option=$?
    fi
    return $option
}
# ----------------------------------------------
# Show Version Artifacts:
# ----------------------------------------------
function showVersionArtifacts() {    
    echo -e "$PROMPT Version of the artifacts:"
    echo
    printf "\t> Source code root path: $src_code_path\n\n"    
    for (( i=1; i<${arrayVersionsLength}+1; i++ ));
    do          
        version_file_path="$src_code_path/${arrayVersions[$i-1]}/$artifacts_version_file"        
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
# Git Config Command
# ----------------------------------------------
function gitConfigCommand() {
    echo -e "$fg_light_blue_color$PROMPT Git config command:"
    optionSelector
    optionSelect=$?         
    if [[ ! $optionSelect -eq $optionCancel ]]
    then            
        for (( i=1; i<${arrayVersionsLength}+1; i++ ));
        do 
            if [[ $optionSelect -eq $optionAll || $optionSelect -eq $i ]]
            then            
                path="$src_code_path/${arrayVersions[$i-1]}"                
                cd $path
                echo -e "$fg_light_blue_color"
                echo -e "$PROMPT ${arrayVersions[$i-1]} > git config --list"
                echo -e "$fg_default_color"
                git config --list
            fi  
        done
        cd $gtools_path        
    fi
}
# ----------------------------------------------
# Git Clone Command
# ----------------------------------------------
function gitCloneCommand() {
    return
}
# ----------------------------------------------
# Run Git Command
# ----------------------------------------------
function runGitCommand() {            
    for (( i=1; i<${arrayVersionsLength}+1; i++ ));
    do          
        path="$src_code_path/${arrayVersions[$i-1]}"                
        cd $path
        case $1 in 
        '0') 
            echo -e "$fg_light_blue_color$PROMPT ${arrayVersions[$i-1]} > git config --list"
            echo -e "$fg_default_color"
            git config --list;;
        '1')            
            echo -e "$fg_light_blue_color$PROMPT ${arrayVersions[$i-1]} > git remote -v"        
            echo -e "$fg_default_color"
            git remote -v;;
        '2')
            echo -e "$fg_light_blue_color$PROMPT ${arrayVersions[$i-1]} > git branch --list"        
            echo -e "$fg_default_color"                        
            git branch --list;;            
        '3')
            echo -e "$fg_light_blue_color$PROMPT ${arrayVersions[$i-1]} > git status -v"        
            echo -e "$fg_default_color"
            git status -v;;
        '4')
            echo -e "$fg_light_blue_color$PROMPT ${arrayVersions[$i-1]} > git fetch"        
            echo -e "$fg_default_color"            
            git fetch;;            
        '5')            
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
    echo -e "$PROMPT gTools Help:"
    echo
    printf " Usage: gtools [OPTION]\n"
    printf " Options:\n"    
    printf "\t-aver\t\tShow artifact version.\n"    
    echo
    printf "\t-ryml\t\tRestore the 'application-local.yml' file for the following projects:\n"
    arrayVersionsLength=${#arrayYMLRestore[@]}
    for (( i=1; i<${arrayVersionsLength}+1; i++ ));
    do
        printf "\t\t\t  - ${arrayYMLRestore[$i-1]}\n"
    done
    echo
    printf "\t-gconfig\tShow all properties configured by Git.\n"    
    printf "\t\t\tGit command: 'git config --list'.\n"
    echo
    printf "\t-gclone\t\tNot description.\n"
    printf "\t\t\tGit command: Not command.\n"
    echo    
    printf "\t-gr\t\tShows the remote repository entries stored in the Git file './.git/config'.\n"
    printf "\t\t\tGit command: 'git branch --list'.\n"    
    echo
    printf "\t-gb\t\tList all branches of your Git repository.\n"
    printf "\t\t\tGit command: 'git branch --list'.\n"    
    echo
    printf "\t-gs\t\tShows the current state of your Git working directory and staging area.\n"    
    printf "\t\t\tGit command: 'git status -v'.\n"    
    echo
    printf "\t-gf\t\tRetrieve all files from a remote Git repository that have been modified by other users (no merge).\n"
    printf "\t\t\tGit command: 'git fetch'.\n"    
    echo
    printf "\t-gp\t\tDownload content from a remote Git repository and update the local repository (fetch + merge).\n"
    printf "\t\t\tGit command: 'git pull --rebase'.\n"    
    echo
    printf " Notes:\n\n"
    printf "\t\t(*) 'git help <verb>' displays the help manual page for the '<verb>' command.\n"
    echo
}
# ------------------------------------------------------------------------------------------
# Script main
# ------------------------------------------------------------------------------------------

echo -e "$fg_light_blue_color$PROMPT gTools v.1.0 2020 by gluques";
if [[ $# == 1 ]]
then
    case $@ in 
    '--help')
        showHelp;;
    '-aver') 
        showVersionArtifacts;;    
    '-ryml')
        restoreAppLocalFiles;;
    #
    # Git commands:
    #
    '-gconfig')
        gitConfigCommand;;
    '-gclone')
        gitCloneCommand;;    
    '-gr')
        runGitCommand 1;;
    '-gb')
        runGitCommand 2;;        
    '-gs')
        runGitCommand 3;;        
    '-gf')
        runGitCommand 4;;        
    '-gp')
        runGitCommand 5;;
    *)
        echo -e "$fg_red_color$PROMPT ERROR: unknown command '$@'."
        echo -e "$fg_light_blue_color$PROMPT Use the --help parameter for help.";;
    esac
else
    echo -e "$fg_red_color$PROMPT ERROR: incorrect number of arguments."
    echo -e "$fg_light_blue_color$PROMPT Use the --help parameter for help."
fi

