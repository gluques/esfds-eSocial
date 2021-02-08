# T3mp0r@l
[ $# -eq 0 ] && { echo "Ha d'informar la data (yyyy-mm-dd) "; exit 1; }
scp sftphpvass@lclasjx70.cpd1.intranet.gencat.cat:/serveis/log/pro/esocial/jboss/esocial/archive/*$1* ./PRO/.
scp sftphpvass@lclasjx71.cpd1.intranet.gencat.cat:/serveis/log/pro/esocial/jboss/esocial/archive/*$1* ./PRO/.
scp sftphpvass@lclasjx72.cpd1.intranet.gencat.cat:/serveis/log/pro/esocial/jboss/esocial/archive/*$1* ./PRO/.
scp sftphpvass@lclasjx73.cpd1.intranet.gencat.cat:/serveis/log/pro/esocial/jboss/esocial/archive/*$1* ./PRO/.

#Carlos:
#deja un punto al final, asi no hace falta q hagas un directorio
#scp sftphpvass@lclasjx70.cpd1.intranet.gencat.cat:/serveis/log/pro/esocial/jboss/esocial/* .
#o como veas