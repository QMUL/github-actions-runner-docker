# github-actions-runner-docker

A recipe to build and run docker containers serving a GitHub Actions
self-hosted runner.

## GitHub setup

1. create a fine-grain token on GitHub with the following permissions:

   * repository access: `All repositories`
   * permissions:
      * repository permissions:
         * Administration: `Read and write`
         * Metadata: `Read-only` (automatically set)
      * organisation permissions:
         *  Self-hosted runners: `Read and write`

2. Save the token string within the `TOKEN` variable in the
   `ghe-actions-docker.env` file.

## VM setup

1. create a Rocky 9 VM from a VM template

2. install docker and jq (as root):

   ```
   dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
   dnf install docker-ce docker-ce-cli containerd.io jq
   ```

3. create the local user `gherunner` (as root):

   ```
   useradd -m gherunner
   ```

4. start and enable the docker service (as root):

   ```
   systemctl start docker
   systemctl enable docker
   ```

5. add the `gherunner` user to the `docker` group (as root):

   ```
   usermod -G docker gherunner
   ```

6. as the `gherunner` user, download the latest release of this repo in
   a writable location (i.e. `/home/gherunner`)

7. set the `GITHUB`, `TARGET` and `TOKEN` settings as appropriate in the
   `ghe-actions-docker.env` file (further information and examples are
   provided in this file).

## Build

To build the container image (as the `gherunner` user):

```
docker build --tag ghe-actions-runner .
```

## Run

To run the container image (as the `gherunner` user):

```
docker compose up --scale runner=X -d
```

where `X` is the number of runners.


## Deleting stuck runners

Runners should automatically clean up after themselves once stopped, but if
a SIGKILL occurs, a container may get stuck in the "Offline" state. Should
this happen, run the `./delete-offline-runners.sh` script.

This script reads the `GITHUB`, `TARGET` and `TOKEN` settings from the
`ghe-actions-docker.env` file .

## Useful commands

* `docker image list` - view a list of built images
* `docker container list` - view a list of running containers
* `docker stop $(docker ps -a -q)` - stop all running containers
* `docker rm $(docker ps -a -q)` - delete all containers (running and stopped)
