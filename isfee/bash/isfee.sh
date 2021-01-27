####################################################################################################################################
# isfee.sh
# Install Start Front eSocial Empleat - v.3.0 2020
#
# Created by gluques.
# Barcelona, September 10, 2020.
####################################################################################################################################

# ------------------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------------------

# Windows user directory:
windows_user_directory="C:/Users/59002704"

# Dependencies file name:
dependency_file_name=".npmrc"
dependency_file_path="$windows_user_directory/$dependency_file_name"
dependency_repository_url="http://nexus.gala-svc.net/repository/npm-public/"

# Directory where the front end source code is hosted:
source_code_base_directory="C:/gluques/src"

# Directories "eSocial-Core-Front":
core_front_folder="eSocial-Core-Front"
core_front_root_path="$source_code_base_directory/$core_front_folder"
core_front_src_path="$core_front_root_path/src"
core_front_app_path="$core_front_src_path/app"
core_front_assets_path="$core_front_src_path/assets"

# Directories "portal-empleat-public-front":
public_front_folder="portal-empleat-public-front"
public_front_root_path="$source_code_base_directory/$public_front_folder"
public_front_src_path="$public_front_root_path/node_modules/$core_front_folder/src"
public_front_app_path="$public_front_src_path/app"
public_front_assets_path="$public_front_src_path/assets"

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
isfee_color="\e[94m"
error_color="\e[31m"
attention_color="\e[33m"
prompt_isfee="[isfee-$Hour:$Minute:$Second]"
correct_process=true

# ------------------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------------------
# Script header:
function script_header() {
    clear
    echo -e "$isfee_color";
    echo "-----------------------------------------------------"
    echo " ISFeE v.3.1 2021"
    echo " Install-Start Front eSocial Empleat bash script."
    echo "-----------------------------------------------------"
    echo
    echo "$prompt_isfee ISFEE started..."
    echo "$prompt_isfee Current date is $Day-$Month-$Year."  
    echo -e "$attention_color$prompt_isfee Remember that it is necessary to have a connection to the Gala VPN."
}

# Exit the process
function exit_script() {  
  
    if [[ $correct_process == true ]]
    then
      echo
      echo
      echo -e "$isfee_color$prompt_isfee Process completed."  
    else        
        echo -e "$attention_color$prompt_isfee ATTENTION: Process not completed."
        echo -e "$attention_color$prompt_isfee ATTENTION: In order to continue with the process, it is necessary to correct the errors detected."
    fi    
    echo -e "$isfee_color$prompt_isfee Press RETURN to end the ISFEE script...";
    read
    exit
}

# Checking the base directories:
function check_base_directories() { 
    echo -e "$isfee_color$prompt_isfee Checking the base directories..."
    if [[ -d "$windows_user_directory" ]]
    then        
        echo -e "$prompt_isfee Directory $windows_user_directory exists."
    else
        echo -e "$error_color$prompt_isfee ERROR: Directory $windows_user_directory does not exists."
        correct_process=false
    fi
    if [[ -d "$core_front_root_path" ]]
    then        
        echo -e "$isfee_color$prompt_isfee Directory $core_front_root_path exists."
    else
        echo -e "$error_color$prompt_isfee ERROR: Directory $core_front_root_path does not exists."
        correct_process=false
    fi
    if [[ -d "$public_front_root_path" ]]
    then        
        echo -e "$isfee_color$prompt_isfee Directory $public_front_root_path exists."
    else
        echo -e "$error_color$prompt_isfee ERROR: Directory $public_front_root_path does not exists."
        correct_process=false
    fi   
}

# Checking dependencies file:
function check_dependencies_file() {
    echo -e "$isfee_color$prompt_isfee Checking dependencies file..."
    if [[ -f "$dependency_file_path" ]]
    then        
        echo -e "$prompt_isfee File $dependency_file_path exists."
    else
        echo -e "$attention_color$prompt_isfee ATTENTION: File $dependency_file_path does not exists, it will be created."
        echo -e "$attention_color$prompt_isfee ATTENTION: Remember that in order to download dependencies from the front repository, this file must exist and have a connection to Gala's VPN."
        cd $windows_user_directory
        echo registry="$dependency_repository_url" > $dependency_file_name
        if [[ -f "$dependency_file_path" ]]
        then
            echo -e "$isfee_color$prompt_isfee File $dependency_file_path created."
        else
            echo -e "$error_color$prompt_isfee ERROR: It is not possible to create the dependencies file."
            correct_process=false
        fi
    fi
}

# Install Core Front
function install_core_front() {
    echo -e "$isfee_color$prompt_isfee Installing '$core_front_folder'..."
    echo -e "$default_color"
    cd $core_front_root_path
    npm install
    if [[ $? -eq 0 ]]
    then                
        echo -e "$isfee_color$prompt_isfee '$core_front_folder' installation was successful."
    else
        echo
        echo -e "$error_color$prompt_isfee ERROR: It was not possible to install '$core_front_folder'."
        correct_process=false
    fi    
}

# Running Gulp:
function run_gulp() {
    echo -e "$isfee_color$prompt_isfee Running Gulp..."    
    echo -e "$default_color"
    cd $core_front_root_path       
    gulp    
    if [[ $? -eq 0 ]]
    then        
        echo 
        echo -e "$isfee_color$prompt_isfee Gulp executed correctly."
        correct_process=true        
    elif [[ $correct_process ]]
    then
        correct_process=false        
        echo 
        echo -e "$attention_color$prompt_isfee ATTENTION: The 'gulp' command did not execute correctly."
        echo -e "$attention_color$prompt_isfee ATTENTION: Trying to install 'gulp' globally..."
        echo -e "$default_color"                    
        npm install gulp –g
        if [[ $? -eq 0 ]]
        then
            run_gulp 
        else 
            echo             
            echo -e "$error_color$prompt_isfee ERROR: Can't install 'gulp'."
        fi
    else
        echo 
        echo -e "$error_color$prompt_isfee ERROR: Unable to run the 'gulp' command."
    fi
}

# Install Public Front
function install_public_front() {
    echo -e "$isfee_color$prompt_isfee Installing '$public_front_folder'..."
    echo -e "$default_color"
    cd $public_front_root_path
    npm install
    if [[ $? -eq 0 ]]
    then 
        echo -e "$isfee_color$prompt_isfee '$public_front_folder' installation was successful."        
    else
        echo
        echo -e "$error_color$prompt_isfee ERROR: It was not possible to install '$public_front_folder'."
        correct_process=false
    fi    
}

# Regenerating directories Public Front
function regenerate_directories() {
    echo -e "$isfee_color$prompt_isfee Regenerating directory '$public_front_app_path':"    
    cd $public_front_src_path
    if [[ -d "$public_front_app_path" ]]        
    then
        echo -e "$isfee_color$prompt_isfee > Deleting directory...$default_color"        
        rm -r $public_front_app_path
        if [[ ! $? -eq 0 ]]
        then
            echo -e "$error_color$prompt_isfee ERROR: Cannot delete directory '$public_front_app_path'."
            correct_process=false
        fi
    fi    
    [[ $correct_process == false ]] && exit_script    
    echo -e "$isfee_color$prompt_isfee > Creating directory and copying new files...$default_color"        
    cp -r $core_front_app_path $public_front_app_path
    if [[ ! $? -eq 0 ]]
    then
        echo -e "$error_color$prompt_isfee ERROR: Files cannot be copied to '$public_front_app_path'."
        correct_process=false
    fi
    [[ $correct_process == false ]] && exit_script
    echo -e "$isfee_color$prompt_isfee Regenerating directory '$public_front_assets_path':"    
    if [[ -d "$public_front_assets_path" ]]        
    then
        echo -e "$isfee_color$prompt_isfee > Deleting directory...$default_color"        
        rm -r $public_front_assets_path
        if [[ ! $? -eq 0 ]]
        then
            echo -e "$error_color$prompt_isfee ERROR: Cannot delete directory '$public_front_assets_path'."
            correct_process=false
        fi
    fi        
    [[ $correct_process == false ]] && exit_script
    echo -e "$isfee_color$prompt_isfee > Creating directory and copying new files...$default_color"     
    cp -r $core_front_assets_path $public_front_assets_path
    if [[ ! $? -eq 0 ]]
    then
        echo -e "$error_color$prompt_isfee ERROR: Files cannot be copied to '$public_front_assets_path'."
        correct_process=false    
    fi
}

# Start Public Front:
function start_public_front() {
    echo -e "$isfee_color$prompt_isfee Starting '$public_front_folder':$default_color"    
    npm start --prefix $public_front_root_path
}

# ------------------------------------------------------------------------------------------
# Script main
# ------------------------------------------------------------------------------------------
script_header
check_base_directories
[[ $correct_process == false ]] && exit_script
check_dependencies_file
[[ $correct_process == false ]] && exit_script
install_core_front 
[[ $correct_process == false ]] && exit_script
run_gulp
[[ $correct_process == false ]] && exit_script
install_public_front
[[ $correct_process == false ]] && exit_script
regenerate_directories
[[ $correct_process == false ]] && exit_script
start_public_front
exit_script
