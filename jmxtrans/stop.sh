PID=$(cat pid.txt)
kill $PID
rm pid.txt