#!/bin/bash

#GITHUB=$GITHUB
#REPOSITORY=$REPO
#ACCESS_TOKEN=$TOKEN

#echo "GITHUB ${GITHUB}"
#echo "REPO ${REPOSITORY}"
#echo "ACCESS_TOKEN ${ACCESS_TOKEN}"

echo "GITHUB ${GITHUB}"
echo "REPOS ${REPO}"
echo "ACCESS_TOKEN ${TOKEN}"

REG_TOKEN=$(curl -k -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" \
	https://api.${GITHUB}/repos/${REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker/actions-runner

./config.sh --url https://$GITHUB/${REPOSITORY} --token ${REG_TOKEN} --unattended

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
