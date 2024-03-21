#!/bin/bash

echo "GITHUB ${GITHUB}"
echo "TARGET ${TARGET}"
echo "TOKEN ${TOKEN}"

# test if the target is a repo, prepend /repos for the api
curl --fail --silent -k -X GET -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json" \
  https://api.${GITHUB}/repos/${TARGET} > /dev/null && API_TARGET=repos/${TARGET}

# test if the target is an org, prepend /orgs for the api
curl --fail --silent -k -X GET -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json" \
  https://api.${GITHUB}/orgs/${TARGET} > /dev/null && API_TARGET=orgs/${TARGET}

if [[ -z ${API_TARGET} ]]; then
    echo "The target provided (${TARGET}) is neither a repo nor an org, exiting"
    exit 1
fi

REG_TOKEN=$(curl -k -X POST -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json" \
	"https://api.${GITHUB}/${API_TARGET}/actions/runners/registration-token" | jq .token --raw-output)

cd /home/docker/actions-runner

./config.sh --url "https://${GITHUB}/${TARGET}" --token "${REG_TOKEN}" --unattended

cleanup() {
    echo 'Removing runner...'
    ./config.sh remove --unattended --token "${REG_TOKEN}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
