if [ "$1" == "-t" ]; then
    EXCLUDE='dummy_nonexistent_12345'
    shift
else
    EXCLUDE='Total heap size$'
fi

echo
echo "  -- Heapdump Analyzer v1.00 by Tanel Poder ( http://www.tanelpoder.com )"
echo
echo "  Total_size #Chunks  Chunk_size,        From_heap,       Chunk_type,  Alloc_reason"
echo "  ---------- ------- ------------ ----------------- ----------------- -----------------"

cat $1 | awk '
     /^HEAP DUMP heap name=/ { split($0,ht,"\""); HTYPE=ht[2]; doPrintOut = 1; }
     /Chunk/{ if ( doPrintOut == 1 ) {
                split($0,sf,"\"");
                printf "%10d , %16s, %16s, %16s\n", $4, HTYPE, $5, sf[2];
              }
     }
     /Total heap size/ {
              printf "%10d , %16s, %16s, %16s\n", $5, HTYPE, "TOTAL", "Total heap size";
              doPrintOut=0;
     }
    ' | grep -v "$EXCLUDE" | sort -n | uniq -c | awk '{ printf "%12d %s\n", $1*$2, $0 }' | sort -nr

echo
