##################################################################
# isfee.pl
# Install Start Front eSocial Empleat - v.1.0 2020
# Perl Script by gluques 
##################################################################
system("cls");
print "-----------------------------------------------------\n";
print " ISFEE v.1.0 2020\n";
print " Install Start Front eSocial Empleat.\n";
print " Perl Script by gluques.\n";
print "-----------------------------------------------------\n";
chdir "C:\\gluques\\src\\portal-empleat-public-front";
if (system("npm install")==0) {
    if (system("npm start")!=0) {        
        print "\n[CIBEE] Error al iniciar el portal-empleat-public-front.\n";
    }
}
else {
    print "\n[CIBEE] Error al instalar el portal-empleat-public-front.\n";
}
print "[CIBEE] Script finalizado.\n\n";
print "[CIBEE] Pulse RETURN para finalizar el script...\n";
my $name = <STDIN>;
