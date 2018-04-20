# 多进程
echo "No individual test environment specified running tests for all $ENV_COUNT environments."
# Run all test environments
pids=()
for t in $(seq 0 "$(($ENV_COUNT - 1))")
do
    $0 $t 2>&1 > /dev/null &
    # add PID to list
    pids+=($!)
done

echo "Started all tests. Follow logs in ${OUTPUT_DIR}. Waiting..."

# Wait for all tests to finish
for pid in "${pids[@]}"
do
    wait $pid
    rc=$(($? + $rc))
done

# Check if all tests passed
if [ $rc -eq 0 ]
then
    echo "All test have passed"
else
    echo "Some tests failed check logs in $OUTPUT_DIR for results"
fi


# for 循环
for (( i = 0; i < 2160; i++ )); do
	sleep 120
done

# while read
loop_i=0
loop_j=0
cat bike_no.txt | while read -r line;
do
    if [ ! -z "${line}" ]; then
        psql -t --no-align --field-separator=, "xxx" -c "SELECT bike_no,produce_time from t_bike_info WHERE bike_no = '$line'" >> t_bike_info.csv
    fi

    loop_i=`expr $loop_i + 1`
    if [ "${loop_i}" -ge 1000 ]; then
        loop_i=0
        loop_j=`expr $loop_j + 1`
        echo "`date`: $loop_j"
    fi
done

((i=$j+$k))    等价于 i=`expr $j + $k`
((i=$j-$k))     等价于   i=`expr $j -$k`
((i=$j*$k))     等价于   i=`expr $j \*$k`
((i=$j/$k))     等价于   i=`expr $j /$k`