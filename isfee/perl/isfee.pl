##################################################################
# isfee.pl
# Install Start Front eSocial Empleat - v.2.0 2020
# Perl Script by gluques 
##################################################################
my $path_base_src        = "C:\\gluques\\src";
my $folder_core_front    = "eSocial-Core-Front";
my $path_core_base       = "$path_base_src\\$folder_core_front";
my $path_core_src        = "$path_core_base\\src";
my $path_core_app        = "$path_core_src\\app";
my $path_core_assets     = "$path_core_src\\assets";
my $folder_public_front  = "portal-empleat-public-front";
my $path_public_base     = "$path_base_src\\$folder_public_front";
my $path_public_src      = "$path_public_base\\node_modules\\eSocial-Core-Front\\src";
my $path_public_app      = "$path_public_src\\app";
my $path_public_assets   = "$path_public_src\\assets";

system("cls");
print "-----------------------------------------------------\n";
print " ISFEE v.2.0 2020\n";
print " Install Start Front eSocial Empleat.\n";
print " Perl Script by gluques.\n";
print "-----------------------------------------------------\n";
print "\n[ISFEE] Instalando '$folder_core_front':\n\n";
chdir "$path_core_base";
if (system("npm install")==0) {
    print "[ISFEE] Ejecutando 'gulp':\n\n";
    #system("npm install gulp");
    if (system("gulp")==0) {
        print "\n[ISFEE] Instalando '$folder_public_front':\n\n";
        chdir "$path_public_front";
        if (system("npm install")==0) {
            chdir "$path_public_base";
            print "\n[ISFEE] Regenerando directorio '$path_public_app':";            
            if (-d "$path_public_app") {
                print "\n[ISFEE] > Eliminando...";
                system("rmdir /S /Q $path_public_app");
            }    
            print "\n[ISFEE] > Creando...";
            if (system("mkdir $path_public_app")!=0) {
                print "\n[ISFEE] ERROR al crear el directorio '$path_public_app'\n";
            }
            print "\n[ISFEE] > Copiando...\n\n";            
            system("xcopy $path_core_app $path_public_app /E/H/Q");
            
            print "\n[ISFEE] Regenerando directorio '$path_public_assets':"; 
            if (-d "$path_public_assets") {
                print "\n[ISFEE] > Eliminando...";
                system("rmdir /S /Q $path_public_assets");
            }    
            print "\n[ISFEE] > Creando...'";            
            if (system("mkdir $path_public_assets")!=0) {
                print "\n[ISFEE] ERROR no es posible crear el directorio '$path_public_assets'\n";
            }
            print "\n[ISFEE] > Copiando...\n\n";            
            system("xcopy $path_core_assets $path_public_assets /E/H/Q");
            print "\n[ISFEE] Iniciando el portal:\n";
            if (system("npm start")!=0) {
                print "\n[ISFEE] Error al iniciar el portal.\n";
            }
        }
        else {
            print "\n[ISFEE] Error al instalar el '$folder_public_front'.\n";
        }
    }
    else {
        print "\n[ISFEE] Error al ejecutar gulp.\n";    
    } 
}
else {
    print "\n[ISFEE] Error al instalar '$folder_core_front'\n";
}
print "\n[ISFEE] Script finalizado.\n\n";
print "[ISFEE] Pulse RETURN para finalizar el script...\n";
my $name = <STDIN>;


