[ $# -eq 0 ] && { echo "Ha d'informar la data (yyyy-mm-dd) "; exit 1; }
scp sftphpvass@lclasjx70.cpd1.intranet.gencat.cat:/serveis/log/pro/esocial/jboss/esocial/archive/*empleat*$1* .
scp sftphpvass@lclasjx71.cpd1.intranet.gencat.cat:/serveis/log/pro/esocial/jboss/esocial/archive/*empleat*$1* .
scp sftphpvass@lclasjx72.cpd1.intranet.gencat.cat:/serveis/log/pro/esocial/jboss/esocial/archive/*empleat*$1* .
scp sftphpvass@lclasjx73.cpd1.intranet.gencat.cat:/serveis/log/pro/esocial/jboss/esocial/archive/*empleat*$1* .
