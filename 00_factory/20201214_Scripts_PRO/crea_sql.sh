#!/bin/bash
clear
[ $# -eq 0 ] && { echo "";	echo "Parametro 1.- N. Jira ";
							echo "";
							exit 1; }

DATA=$(date +%F)
JIRA=$1
if [ ! -z "$2" ]
  then
    VER=-v$2
fi

mkdir 'ESOCIAL-'$JIRA''

cat headerSQL.txt bodySQL.txt footerSQL.txt > ./'ESOCIAL-'$JIRA''/ESOCIAL-$JIRA$VER.sql

sed -i -e 's/$JIRA/'$JIRA'/g' ./'ESOCIAL-'$JIRA''/ESOCIAL-$JIRA$VER.sql
sed -i -e 's/$VER/'$VER'/g' ./'ESOCIAL-'$JIRA''/ESOCIAL-$JIRA$VER.sql
sed -i -e 's/$DATA/'$DATA'/g' ./'ESOCIAL-'$JIRA''/ESOCIAL-$JIRA$VER.sql

echo ""
echo "----------------------------------------------------------------------"
echo "Creat fitxer sql a :  ./'ESOCIAL-'$JIRA''/ESOCIAL-$JIRA$VER.sql "
echo "----------------------------------------------------------------------"
echo ""
cat ./'ESOCIAL-'$JIRA''/ESOCIAL-$JIRA$VER.sql
echo ""