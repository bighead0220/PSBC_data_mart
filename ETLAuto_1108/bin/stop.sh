pid=`cat ${AUTO_HOME}/lock/etlagent.lock`
kill $pid
pid=`cat ${AUTO_HOME}/lock/etlclean.lock`
kill $pid
pid=`cat ${AUTO_HOME}/lock/etlrcv.lock`
kill $pid
pid=`cat ${AUTO_HOME}/lock/etlmaster.lock`
kill $pid
pid=`cat ${AUTO_HOME}/lock/etlmsg.lock`
kill $pid
pid=`cat ${AUTO_HOME}/lock/etlschedule.lock`
kill $pid