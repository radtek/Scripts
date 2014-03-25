RET=0
for i in `cat /etc/oratab | awk -F: '{print" "$1}'`
        do
                 TMP=/tmp/${i}.ck
     NAME=bkp_${i}.out
     find /tmp -ctime -1 -name $NAME -exec cat {} \; > $TMP

                                                                if [ -s $TMP ] ; then
                                                                                        grep SUCCESS /tmp/${i}.ck  > /dev/null
                                                                                        RT=$?
                                                                                      if [ $RT -eq 0 ] ; then
                                                                                                echo "BACKUP $i OK"
                                                                                else
                                                                                                echo "BACKUP $i FAIL"
                                                                                RET=1
                                                fi
                                                else
                                                                        echo "FAIL TO CHECK BACKUP OF DATABASE $i "
                                                                RET=1
                                                fi

rm  /tmp/${i}.ck
done
exit $RET
