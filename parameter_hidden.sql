select x.ksppinm name,
  y.ksppstvl value,
  ksppdesc description
  from x$ksppi x,
  x$ksppcv y
  where x.inst_id = userenv('Instance')
  and y.inst_id = userenv('Instance')
  and x.indx = y.indx
  and x.ksppinm = '&param_name';
