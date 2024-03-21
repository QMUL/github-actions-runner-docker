#!/bin/bash

echo "GITHUB ${GITHUB}"
echo "TARGET ${TARGET}"
echo "TOKEN ${TOKEN}"

REG_TOKEN=$(curl -k -X POST -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json" \
	https://api.${GITHUB}/${TARGET}/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker/actions-runner

./config.sh --url https://$GITHUB/${TARGET} --token ${REG_TOKEN} --unattended

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
