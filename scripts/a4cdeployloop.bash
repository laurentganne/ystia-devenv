#!/bin/bash

#
# a4cdeployloop - Deploy/Undeploy an existing application in Alien4Cloud
#
# Expecting 3 arguments :
# - number of deploy/undeploy loops to perform
# - ApplicationName
#
# Example:
# a4cdeployloop  http://myhost.example.com:8088 20 MyApp
#

usage() {
    echo "a4cdeployloop <Alien4Cloud URL> <number of loops> <application name>"
    exit 1
}

if [ $# -ne 3 ]
then
    usage
fi

a4cURL=$1
nbLoops=$2
appName=$3

# waitForDeploymentStatus waits for a given deployment to reach a given
# deployment status.
#
# First argument:  expected status
#
# Returns 0 if the status was found
# Returns 1 if it was not found after 100 seconds
#
waitForDeploymentStatus() {
	start_time="$(date -u +%s)"
	expectedStatus=$1
	i=0
	while [ $i -lt 100 ]
	do
	    curl --request POST \
             --url $a4cURL/rest/latest/applications/statuses \
             --header 'content-type: application/json' \
             --silent \
             --cookie cookies.a4c \
             --data  "[\"$appName\"]" | grep -q "\"${expectedStatus}\""
        res=$?
		if [ $res -eq 0 ]
		then
			end_time="$(date -u +%s)"
			elapsed="$(($end_time-$start_time))"
			echo "Reached status $expectedStatus in $elapsed seconds"
		    return 0
		fi
	    sleep 1
	    ((i++))
	done
	
	return 1
}

getJsonval() {
	jsonKey=$1
	jsonContent=$2
    temp=`echo "$jsonContent" | awk -F"[{,:}]" '{for(i=1;i<=NF;i++){if($i~/'$jsonKey'\042/){print $(i+2)}}}' | tr -d '"' | sed -n 1p`
    echo $temp
}


getAppEnvID() {

	res=`curl --request POST \
              --url $a4cURL/rest/latest/applications/statuses \
              --header 'content-type: application/json' \
              --cookie cookies.a4c \
              --silent \
              --data  "[\"$appName\"]"`

    valueFound=`getJsonval $appName $res`
	echo $valueFound
}

# Main

nbDep=1

# First, login and store the cookie
curl -d "username=admin&password=admin&submit=Login"  \
     --url  $a4cURL/login \
     --dump-header headers \
	 --silent \
     --cookie-jar cookies.a4c

while [ $nbDep -le $nbLoops ]
do
    curl --request POST \
         --url $a4cURL/rest/latest/applications/deployment \
         --header 'content-type: application/json' \
         --cookie cookies.a4c \
         --silent \
         --data "{\"applicationId\": \"$appName\"}" > /dev/null

    res=$?
    if [ $res -ne 0 ]
    then
        echo "Exiting on error sending deployment request"
        exit 1
    fi

    echo "Deployment $nbDep in progress ..."
    waitForDeploymentStatus "DEPLOYED"

    res=$?
    if [ $res -ne 0 ]
    then
        echo "Exiting on error waiting for end of deployment"
        exit 1
    fi
	sleep 1
    echo "Deployment done, undeploying..."
	
	appEnvID=`getAppEnvID`

    curl --request DELETE \
         --url $a4cURL/rest/v1/applications/$appName/environments/$appEnvID/deployment \
         --header 'accept: application/json' --header 'content-type: application/json' \
         --silent \
         --cookie cookies.a4c > /dev/null

    res=$?
    if [ $res -ne 0 ]
    then
        echo "Exiting on error sending undeployment request"
        exit 1
    fi

    waitForDeploymentStatus "UNDEPLOYED"
    res=$?
    if [ $res -ne 0 ]
    then
        echo "Exiting on error waiting for end of undeployment"
        exit 1
    fi
	((nbDep++))
done

