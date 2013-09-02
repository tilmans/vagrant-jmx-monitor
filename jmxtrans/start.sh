if [ -f pid.txt ] 
then
	echo "pid.txt exists, assume jmxtrans running!" 
	exit -1
fi
nohup java -Djmxtrans.log.level=DEBUG -jar jmxtrans-1.0.0-SNAPSHOT-all.jar -f heapmemory.json > log.txt 2> errors.txt < /dev/null &
PID=$!
echo $PID > pid.txt