     By Puppet
####################################################

# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin

export PATH

#########################################################
ORACLE_BASE=/usr/local/oracle
ORACLE_HOME=$ORACLE_BASE/product/10.2.0
ORACLE_TERM=xterm
NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
NLS_DATE_FORMAT=DD/MM/YYYY
ORA_NLS33=$ORACLE_HOME/ocommon/nls/admin/data
LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib:/usr/local/lib
PATH=$PATH:$ORACLE_HOME/bin:/sbin:/usr/sbin:/usr/bin/X11:/usr/local/bin:/usr/local/sbin:/root/bin:$ORACLE_BASE/OPatch
OH=$ORACLE_HOME
ADM=$ORACLE_BASE/oracledba
DBA=$ORACLE_BASE/admin/$ORACLE_SID
# ATENCAO: manter os exports separados das definicoes
export ORACLE_BASE ORACLE_HOME ORACLE_SID ORACLE_TERM
export NLS_LANG NLS_DATE_FORMAT ORA_NLS33
export LD_LIBRARY_PATH PATH
export OH ADM DBA

#!/bin/sh

show_menu(){
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Blue
    NUMBER=`echo "\033[33m"` #yellow
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${MENU}Qual variavel de ambiente deve ser carregada? Escolha entre 1 e 7. ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} ORAHLG01 (10G) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} ORAHLG02 (10G) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} ORAHLG04 (10G) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} ORAHLG05 (10G) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} SIGDSV (10G) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 6)${MENU} HLG11G02 (11G) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 7)${MENU} HLG11G (11G) ${NORMAL}"
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${ENTER_LINE}Por favor escolha uma opÃ§Ã£o ou ${RED_TEXT} pressione enter para continuar. ${NORMAL}"
    read opt
}
function option_picked() {
    COLOR='\033[01;31m' # bold red
    RESET='\033[00;00m' # normal white
    MESSAGE=${@:-"${RESET}Error: No message passed"}
    echo -e "${COLOR}${MESSAGE}${RESET}"
}

clear
show_menu
while [ opt != '' ]
    do
    if [[ $opt = "" ]]; then
            break;
    else
        case $opt in
        1) clear;
        option_picked "OpÃ§Ã£o 1 Escolhida!";
           export ORACLE_BASE=/usr/local/oracle;
           export ORACLE_HOME=/usr/local/oracle/product/10.2.0;
           export ORACLE_SID=orahlg01;
           export ORACLE_TERM=xterm;
            break;

        ;;

        2) clear;
            option_picked "OpÃ§Ã£o 2 Escolhida!";
                export ORACLE_BASE=/usr/local/oracle;
                export ORACLE_HOME=/usr/local/oracle/product/10.2.0;
                export ORACLE_SID=orahlg02;
                export ORACLE_TERM=xterm;
        break;
            ;;

        3) clear;
            option_picked "OpÃ§Ã£o 3 Escolhida!";
                export ORACLE_BASE=/usr/local/oracle;
                export ORACLE_HOME=/usr/local/oracle/product/10.2.0;
                export ORACLE_SID=orahlg04;
                export ORACLE_TERM=xterm;
        break;
            ;;

        4) clear;
            option_picked "OpÃ§Ã£o 4 Escolhida!";
                export ORACLE_BASE=/usr/local/oracle;
                export ORACLE_HOME=/usr/local/oracle/product/10.2.0;
                export ORACLE_SID=orahlg05;
                export ORACLE_TERM=xterm;
        break
            ;;

         5) clear;
            option_picked "OpÃ§Ã£o 5 Escolhida!";
                export ORACLE_BASE=/usr/local/oracle;
                export ORACLE_HOME=/usr/local/oracle/product/10.2.0;
                export ORACLE_SID=sigdsv;
                export ORACLE_TERM=xterm;
                break;
                ;;

        6) clear;
            option_picked "OpÃ§Ã£o 6 Escolhida!";
                export ORACLE_BASE=/usr/local/oracle;
                export ORACLE_HOME=/usr/local/oracle/product/11.2.0;
                export ORACLE_SID=hlg11g02;
                export ORACLE_TERM=xterm;
                export PATH=$ORACLE_HOME/bin:$PATH
                break;
                ;;

        7) clear;
            option_picked "Opcao 7 Escolhida!";
                export ORACLE_BASE=/usr/local/oracle;
                export ORACLE_HOME=/usr/local/oracle/product/11.2.0;
                export ORACLE_SID=hlg11g;
                export ORACLE_TERM=xterm;
                export PATH=$ORACLE_HOME/bin:$PATH
                break;
                ;;

        \n)break;
        ;;

        *)clear;
        option_picked "Escolha uma opÃ§Ã£o do menu!";
        show_menu;
        ;;
    esac
fi
done

#########################################################
if [ -t 0 ]; then
   stty intr ^C
fi
