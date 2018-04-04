#!/bin/bash

#
# deployloop - Deploy/Undeploy an archive in loop
#
# Expecting 2 arguments :
# - number of deploy/undeploy loops to perform
# - zip file of an archive t deploy/undeploy

usage() {
    echo "deployloop <number of loops> <deployment zip>"
    exit 1
}

if [ $# -ne 2 ]
then
    usage
fi

nbLoops=$1
zipFile=$2

# waitForDeploymentStatus waits for a given deployment to reach a given
# deployment status.
#
# First argument:  deployment ID
# Second argument: expected status
#
# Returns 0 if the status was found
# Returns 1 if it was not found after 100 seconds
#
waitForDeploymentStatus() {
    depID=$1
	expectedStatus=$2
	i=0
	while [ $i -lt 100 ]
	do
	    depStatus=`yorc d list | grep $depID | awk '{print $4}'`
		if [ "$depStatus" == "$expectedStatus" ]
		then
		    return 0
		fi
	    sleep 1
	    ((i++))
	done
	
	return 1
}

# getDeploymentIdForStatus gets the deployment ID for a deployment
# having the status in argument.
#
# Argument: expected status
#
# Outputs the deployment ID if it was found
# else outputs "Not found"
#
getDeploymentIdForStatus() {
	expectedStatus=$1
	result="Not found"
	i=0
	while [ $i -lt 15 ]
	do
	    depID=`yorc d list | grep " $expectedStatus" | awk '{print $2}'`
		if [ -n "$depID" ]
		then
		    result="$depID"
			break
		fi
	    sleep 1
	    ((i++))
	done
	
	echo "$result"
}

# Main

nbDep=0
while [ $nbDep -lt $nbLoops ]
do
    echo "Deployment $nbDep ..."
    yorc d deploy $zipFile

    depID=`getDeploymentIdForStatus "DEPLOYMENT_IN_PROGRESS"`
	
    if [ "$depID" == "Not found" ]
    then
        echo "Exiting on error find a deployment in progress"
        exit 1
    fi

    waitForDeploymentStatus $depID "DEPLOYED"
    res=$?
    if [ $res -ne 0 ]
    then
        echo "Exiting on error waiting for end of deployment"
        exit 1
    fi

    echo "...Deployment done, undeploying..."
	
    yorc d undeploy $depID
    waitForDeploymentStatus $depID "UNDEPLOYED"
    res=$?
    if [ $res -ne 0 ]
    then
        echo "Exiting on error waiting for end of undeployment"
        exit 1
    fi
	((nbDep++))
done

