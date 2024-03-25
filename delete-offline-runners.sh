#!/bin/bash

GITHUB=$1
TARGET=$2
TOKEN=$3

if [[ "$#" -ne 3 ]]; then
  echo "Usage: $0 GITHUB_URL TARGET TOKEN"
  exit
fi

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

echo "Removing offline GH actions runners on https://${GITHUB}/${TARGET}..."

RUNNER_LIST=$(curl -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json" \
    https://api.${GITHUB}/${API_TARGET}/actions/runners \
    | jq '[.runners[] | select(.status | contains("offline")) | {id: .id}]')


for id in $(echo "$RUNNER_LIST" | jq -r '.[] | @base64'); do
    _jq() {
        echo ${id} | base64 --decode | jq -r ${1}
    }
    echo "Deleting $(_jq '.id')"
    curl -X DELETE -H "Accept: application/vnd.github+json" \
         -H "Authorization: token ${TOKEN}" \
         https://api.${GITHUB}/${API_TARGET}/actions/runners/$(_jq '.id')
done
