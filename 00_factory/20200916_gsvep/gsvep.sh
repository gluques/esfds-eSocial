####################################################################################################################################
# gsvep.sh
# Show Version of eSocial Projects - v.1.0 2020
#
# Created by gluques for DXC. 
# Barcelona, September 16, 2020.
####################################################################################################################################

# ------------------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------------------

# Source code root directory path:
src_root_path="C:/gluques/src"

# Version file:
version_file_name="pom.xml"
initial_tag="<version>"
final_tag="</version>"

# ------------------------------------------------------------------------------------------
# Global variables
# ------------------------------------------------------------------------------------------
Year=`date +%Y`
Month=`date +%m`
Day=`date +%d`
Hour=`date +%H`
Minute=`date +%M`
Second=`date +%S`
default_color="\e[39m"
gsvep_color="\e[94m"
declare -a arrayProjects=("eSocial-Core-Front" "esocial-dynamic-blocks" "esocial-jpa-repositories" "esocial-services" "portal-ciutada-back" "portal-empleat-public-back" "portal-empleat-public-front")

# ------------------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------------------
# Script header:
function script_header() {
    clear
    echo -e "$gsvep_color";
    echo "-----------------------------------------------------"
    echo " GSVEP v.1.0 2020"
    echo " Show Version of eSocial Projects."
    echo " Bash script by gluques.";
    echo "-----------------------------------------------------"        
    echo "> Current date is $Day-$Month-$Year, $Hour:$Minute:$Second."
    echo "> Source code root path: $src_root_path"
    echo "> List of projects and versions:"
    echo
}

# Show version of projects:
function show_version_projects() {
    arrayProjectsLength=${#arrayProjects[@]}
    for (( i=1; i<${arrayProjectsLength}+1; i++ ));
    do          
        version_file_path="$src_root_path/${arrayProjects[$i-1]}/$version_file_name"        
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
            printf "\t${arrayProjects[$i-1]} $version\n"
        else
            printf "\t${arrayProjects[$i-1]} [No version]\n"
        fi
    done
}

# ------------------------------------------------------------------------------------------
# Script main
# ------------------------------------------------------------------------------------------
script_header
show_version_projects
