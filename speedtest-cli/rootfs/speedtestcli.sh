if [ "$SUPERVISOR_TOKEN" = "" ];
then
    echo "$(date) - Error token is empty"
    exit 2
fi

for SERVER in $SERVERS;
do
    echo "$(date) - Starting speedtest server ${SERVER}"
    JSON=`speedtest -s ${SERVER} --f json-pretty`
    if [ $? = 0 ];
    then
        echo "$(date) - Finished speedtest"
        ATTRIBUTES="{\"unit_of_measurement\": \"Mbit/s\", \"state_class\": \"measurement\", \"icon\": \"mdi:speedometer\"}"
        DOWNLOADVALUE=`echo $JSON | jq '.download.bandwidth'`
        DOWNLOADVALUEFINAL=`expr $DOWNLOADVALUE \* 8 / 1024 / 1024`
        UPLOADVALUE=`echo $JSON | jq '.upload.bandwidth'`
        UPLOADVALUEFINAL=`expr $UPLOADVALUE \* 8 / 1024 / 1024`
        DOWNLOAD="{\"state\": \"${DOWNLOADVALUEFINAL}\", \"attributes\": ${ATTRIBUTES} }"
        UPLOAD="{\"state\": \"${UPLOADVALUEFINAL}\", \"attributes\": ${ATTRIBUTES} }"
        PING="{\"state\": \"`echo $JSON | jq '.ping.latency'`\", \"attributes\": ${ATTRIBUTES} }"
        echo "$(date) - DL: $DOWNLOADVALUE, UP: $UPLOADVALUE, PING: $(echo $JSON | jq '.ping.latency')"

        curl -s -X POST -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" -H "Content-Type: application/json" http://supervisor/core/api/states/sensor.speedtestcli_download -d "${DOWNLOAD}"
        sleep 2
        curl -s -X POST -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" -H "Content-Type: application/json" http://supervisor/core/api/states/sensor.speedtestcli_upload -d "${UPLOAD}"
        sleep 2
        curl -s -X POST -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" -H "Content-Type: application/json" http://supervisor/core/api/states/sensor.speedtestcli_ping -d "${PING}"
        exit 0
    else
        echo "$(date) - Error connect server ${SERVER}, trying other..."
    fi
done

