#!/bin/sh
ORACLE_BASE=/usr/local/oracle
ORACLE_HOME=/usr/local/oracle/product/10.2.0
ORACLE_SID=orahlg06
ORADATA=/d12/oradata/orahlg06
SCRIPTS=$ORACLE_HOME/admin/$ORACLE_SID/create

export ORACLE_BASE ORACLE_HOME ORACLE_SID ORADATA SCRIPTS

mkdir $ORACLE_BASE/admin
mkdir $ORACLE_BASE/admin/$ORACLE_SID
mkdir $ORACLE_BASE/admin/$ORACLE_SID/bdump
mkdir $ORACLE_BASE/admin/$ORACLE_SID/cdump
mkdir $ORACLE_BASE/admin/$ORACLE_SID/pfile
mkdir $ORACLE_BASE/admin/$ORACLE_SID/udump
mkdir $ORADATA

cp $SCRIPTS/init.ora $ORACLE_BASE/admin/$ORACLE_SID/pfile/init$ORACLE_SID.ora
ln -s $ORACLE_BASE/admin/$ORACLE_SID/pfile/init$ORACLE_SID.ora $ORACLE_HOME/dbs
sleep 10

$ORACLE_HOME/bin/orapwd file=$ORACLE_HOME/dbs/orapw$ORACLE_SID password=change_on_install
sleep 10
$ORACLE_HOME/bin/sqlplus /nolog @$SCRIPTS/CreateDB.sql		$SCRIPTS $ORADATA $ORACLE_SID
sleep 10
$ORACLE_HOME/bin/sqlplus /nolog @$SCRIPTS/CreateDBFiles.sql	$SCRIPTS $ORADATA
sleep 10
$ORACLE_HOME/bin/sqlplus /nolog @$SCRIPTS/CreateDBCatalog.sql	$SCRIPTS
sleep 10
#$ORACLE_HOME/bin/sqlplus /nolog @$SCRIPTS/JServer.sql		$SCRIPTS
#sleep 10
#$ORACLE_HOME/bin/sqlplus /nolog @$SCRIPTS/ordinst.sql		$SCRIPTS
#sleep 10
#$ORACLE_HOME/bin/sqlplus /nolog @$SCRIPTS/interMedia.sql	$SCRIPTS
#sleep 10
#$ORACLE_HOME/bin/sqlplus /nolog @$SCRIPTS/context.sql		$SCRIPTS
#sleep 10
#$ORACLE_HOME/bin/sqlplus /nolog @$SCRIPTS/xdb_protocol.sql	$SCRIPTS
#sleep 10
$ORACLE_HOME/bin/sqlplus /nolog @$SCRIPTS/postDBCreation.sql	$SCRIPTS
