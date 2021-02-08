##################################################################
# cibee.pl
# Clean Install Backend eSocial Empleat - v.1.0 2020
# Perl Script by gluques 
##################################################################
system("cls");
print "-----------------------------------------------------\n";
print " CIBEE v.1.0 2020\n";
print " Clean Install Backend eSocial Empleat.\n";
print " Perl Script by gluques.\n";
print "-----------------------------------------------------\n";
chdir "C:\\gluques\\src\\esocial-jpa-repositories";
if (system("mvn clean install")==0) {
    print "\n\n";
    chdir "C:\\gluques\\src\\esocial-services";
    if (system("mvn clean install")==0) {
        print "\n\n";
        chdir "C:\\gluques\\src\\portal-ciutada-back";
        if (system("mvn clean install")==0) {
            print "\n\n";
            chdir "C:\\gluques\\src\\portal-empleat-public-back";
            if (system("mvn clean install")==0) {
                print "\n[CIBEE] Compilacion correcta.\n";                
            }
            else {
                print "\n[CIBEE] Error de compilación en portal-ciutada-back.\n";                
            }
        }
        else {
            print "\n[CIBEE] Error de compilacion en portal-ciutada-back.\n";            
        }
    }
    else {
        print "\n[CIBEE] Error de compilacion en esocial-services.\n";        
    }
}
else {
    print "\n[CIBEE] Error de compilacion en esocial-jpa-repositories.\n";    
}
print "[CIBEE] Script finalizado.\n\n";