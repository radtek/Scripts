####################
# Objetivo:  Copiar os archives para outra maquina para ter mais uma copia
#            alem a do backup para fitas
#
# Autor...: Junior (Advanced)
# Data....: 11/08/2003
# Versão..: 0.1
####################
function test_machine {
MACHINE=`uname -n | cut -d . -f 1`

if [ "$MACHINE" = "cedral" ]
then
	MACHINE=imbe
else
	MACHINE=cedral
fi
} 

# Variaveis
HORA_BACKUP=`date +%d/%m/%Y'    '%H:%M`

# Chamada de funcao
test_machine

# Corpo do Programa
rm /tmp/ARC_bkp.lock 2> /dev/null
ls -1 ORADB1*.ARC | while read ARC
do
        if [ -f "/tmp/ARC_bkp.lock" ]
        then
                echo "BACKUP ${ARC} ${HORA_BACKUP}" >> backup_$MACHINE_log
		cp ${ARC} BKP1
                echo "${ARC}" > lock
        else
                if [ "${ARC}" == "`cat lock`" ]
                then
                        touch /tmp/ARC_bkp.lock
                fi
        fi
done

