#Create this function to have a clear idea of the SCN order
CREATE OR REPLACE function sortScn(startScn number, capturedScn number, 
  appliedScn number, firstScn number, sourceResetlogsScn number, 
  maxCheckpointScn number, requiredCheckpointScn number, lastEnqueuedScn number) 
  return varchar2 is
  type tRec is record(name varchar2(50), value number);
  r tRec;
  TYPE nestTable IS TABLE OF tRec;
  n nestTable;
  tmpvalue tRec;
  i number;
  result varchar2(1000) := '';
begin
  n := nestTable();
  --Add start SCN
  r.name := 'Start SCN                '; r.value := startScn;
  n.extend(); n(n.count()) := r;
  --Add captured SCN
  r.name := 'Captured SCN             '; r.value := capturedScn;
  n.extend(); n(n.count()) := r;
  --Add applied SCN
  r.name := 'Applied SCN              '; r.value := appliedScn;
  n.extend(); n(n.count()) := r;
  --Add first SCN
  r.name := 'First SCN                '; r.value := firstScn;
  n.extend(); n(n.count()) := r;
  --Add source resetlogs SCN
  r.name := 'Source resetlogs SCN     '; r.value := sourceResetlogsScn;
  n.extend(); n(n.count()) := r;
  --Add start SCN
  r.name := 'Max Checkpoint SCN       '; r.value := maxCheckpointScn;
  n.extend(); n(n.count()) := r;
  --Add required checkpoint SCN
  r.name := 'Required checkpoint SCN  '; r.value := requiredCheckpointScn;
  n.extend(); n(n.count()) := r;
  --Add last enqueued SCN SCN
  r.name := 'Last enqueued SCN        '; r.value := lastEnqueuedScn;
  n.extend(); n(n.count()) := r;
  --Add current SCN
  r.name := 'Current SCN              '; r.value := DBMS_FLASHBACK.GET_SYSTEM_CHANGE_NUMBER();
  n.extend(); n(n.count()) := r;
  begin
    --Sort 
    i := n.first;
    while(i<n.last-1) loop
      --DBMS_OUTPUT.PUT_LINE(i);
      --for i in n.first..n.last-1 loop
      if(n(i).value>n(i+1).value) then
        --DBMS_OUTPUT.PUT_LINE('found');
        tmpvalue := n(i);
        n(i) := n(i+1);
        n(i+1) := tmpvalue;
        i := n.first;
      else i := i+1;
      end if;
    end loop;
  end;
  for i in n.first..n.last loop
    result := result || (n(i).name || ' ' || n(i).value);
    if(i<n.last) then
      result := result || chr(13) || chr(10);
    end if;
  end loop;
  return result;
end;
/
#Query DBA_STREAMS_RULES to lookup RULE_SET_NAME
select c.*, sortScn(start_scn, captured_Scn, applied_Scn, first_Scn, 
  source_Resetlogs_Scn, max_Checkpoint_Scn, required_Checkpoint_Scn, 
  last_Enqueued_Scn) scn_order from dba_capture c;