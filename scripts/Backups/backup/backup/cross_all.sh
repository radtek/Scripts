rman target / catalog rman/rman@orarep <<eof
allocate channel for maintenance type 'sbt_tape';
crosscheck backup;
exit;
eof

