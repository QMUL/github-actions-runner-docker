# GitHub Actions Runner Docker Changelog

## 1.2.0

* updated the github actions runner version to 2.3.19.1 to support
  GHE series 3.14
* read env settings in the delete-offline-runners.sh script
* added -k to curl commands in delete-offline-runners.sh to
  workaround ssl wildcard insecure messages
* improved VM setup instructions in the readme

## 1.1.1

* Added quotes around cpus field in `compose.yml` to fix a docker
  compose issue

## 1.1.0

* Added the `delete-offline-runners.sh` script to manually delete
  runners stuck in the 'Offline' state

## 1.0.0

Initial release
