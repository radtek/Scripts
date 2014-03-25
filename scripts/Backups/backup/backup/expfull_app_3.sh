# Instancia as variaveis de ambiente
. /home/oracle/.bash_profile

# Configura as variaveis locais
DIR_DEST=/home/oracle/bkp/bkp_dmp
DIR_LOG=/home/oracle/bkp/bkp_dmp/logs
USER_BD=bkp
SENHA_BD=bkporadb1
CONN_STR=base03

export ORACLE_SID=$CONN_STR

# Gera comando de export de todos os owners
sqlplus -s $USER_BD/$SENHA_BD <<eof
set lines 1000;
col comando for a900;
set feed off;
set pages 0
set term off
set trimspool on

spool /tmp/exp_owners.sh
select 'rm $DIR_DEST/expfull_'||username||'.dmp.*'||chr(10)|| 
       'mknod $DIR_DEST/pipe p'||chr(10)||
       'nohup gzip <$DIR_DEST/pipe >$DIR_DEST/expfull_'||username||'.dmp.gz &'||chr(10)||
--       'exp $USER_BD/$SENHA_BD filesize=2000m file=$DIR_DEST/expfull_'||username||'.dmp.1,'||
--       '$DIR_DEST/expfull_'||username||'.dmp.2,' ||
--       '$DIR_DEST/expfull_'||username||'.dmp.3,' ||
--       '$DIR_DEST/expfull_'||username||'.dmp.4,' ||
--       '$DIR_DEST/expfull_'||username||'.dmp.5,' ||
--       '$DIR_DEST/expfull_'||username||'.dmp.6,' ||
--       '$DIR_DEST/expfull_'||username||'.dmp.7,' ||
--       '$DIR_DEST/expfull_'||username||'.dmp.8,' ||
--       '$DIR_DEST/expfull_'||username||'.dmp.9,' ||
--       '$DIR_DEST/expfull_'||username||'.dmp.10 '||
       'exp $USER_BD/$SENHA_BD filesize=2000m file=$DIR_DEST/pipe,'||
       ' owner='||username||' log=$DIR_LOG/expfull_'||username||'.log consistent=y rows=y' ||chr(10)||
       'rm $DIR_DEST/pipe' comando
--       'gzip $DIR_DEST/expfull_'||username||'.dmp.*' comando
  from dba_users
 where username in ('SUAT');
spool off;
exit;
eof

chmod u+x /tmp/exp_owners.sh

# Executa o export de todos os owners;
/tmp/exp_owners.sh
