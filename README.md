# syncthing-relaysrv
Docker Container for the global relay server for the [http://syncthing.net/](http://syncthing.net/) project. I created this container because there is no official one. This build is listening on the gihub project of the relay server and gets updated whenever there is a code change. [relaysrv GitHub repo](https://github.com/syncthing/relaysrv). The container is intended for people who like to roll their own private syncthing "cloud".

The files for this container can be found at my [GitHub repo](https://github.com/t4skforce/syncthing-relay)

[![](https://images.microbadger.com/badges/image/t4skforce/syncthing-relay.svg)](http://microbadger.com/images/t4skforce/syncthing-relay "Get your own image badge on microbadger.com") [![](https://img.shields.io/docker/automated/t4skforce/syncthing-relay.svg)](https://cloud.docker.com/repository/docker/t4skforce/syncthing-relay) [![docker-build-push](https://github.com/t4skforce/syncthing-relay/actions/workflows/main.yml/badge.svg)](https://github.com/t4skforce/syncthing-relay/actions/workflows/main.yml) [![](https://images.microbadger.com/badges/version/t4skforce/syncthing-relay.svg)](http://microbadger.com/images/t4skforce/syncthing-relay "Get your own version badge on microbadger.com") [![](https://img.shields.io/docker/pulls/t4skforce/syncthing-relay.svg)](https://cloud.docker.com/repository/docker/t4skforce/syncthing-relay) [![](https://img.shields.io/docker/stars/t4skforce/syncthing-relay.svg)](https://cloud.docker.com/repository/docker/t4skforce/syncthing-relay) [![](https://img.shields.io/github/last-commit/t4skforce/syncthing-relay.svg)](https://github.com/t4skforce/syncthing-relay) [![](https://img.shields.io/maintenance/yes/2023.svg)](https://github.com/t4skforce/syncthing-relay) [![](https://img.shields.io/github/issues-raw/t4skforce/syncthing-relay.svg)](https://github.com/t4skforce/syncthing-relay/issues) [![](https://img.shields.io/github/issues-pr-raw/t4skforce/syncthing-relay.svg)](https://github.com/t4skforce/syncthing-relay/pulls)

[![dockeri.co](http://dockeri.co/image/t4skforce/syncthing-relay)](https://hub.docker.com/r/t4skforce/syncthing-relay/)

# About the Container

This build is based on [debian:latest](https://hub.docker.com/_/debian/) and installs the latests successful build of the syncthing relay server.

# How to use this image

`docker run --name syncthing-relay -d -p 22067:22067 --restart=always t4skforce/syncthing-relay:latest`

This will store the certificates and all of the data in `/home/relaysrv/`. You will probably want to make at least the certificate folder a persistent volume (recommended):

`docker run --name syncthing-relay -d -p 22067:22067 -v /your/home:/home/relaysrv/certs --restart=always t4skforce/syncthing-relay:latest`

If you already have certificates generated and want to use them and protect the folder from being changed by the docker images use the following command:

`docker run --name syncthing-relay -d -p 22067:22067 -v /your/home:/home/relaysrv/certs:ro --restart=always t4skforce/syncthing-relay:latest`

Creating cert directory and setting permissions (docker process is required to have access):
```bash
mkdir -p /your/home/certs
chown -R 1000:1000 /your/home/certs
```

# Container Configuration

There are several configuration options available. The options are configurable via environment variables (docker default):

Example enabling debug mode:
```bash
export DEBUG=true
docker run --name syncthing-relay -d -p 22067:22067 --restart=always t4skforce/syncthing-relay:latest
```

or

```bash
docker run --name syncthing-relay -d -p 22067:22067 -e DEBUG=true --restart=always t4skforce/syncthing-relay:latest
```

## Options

* DEBUG: enable debugging (true/false) / default:false
* RATE_GLOBAL: global maximum speed for transfer / default:10000000 = 10mbps
* RATE_SESSION: maximum speed for transfer per session / default:500000 = 500kbps
* TIMEOUT_MSG: change message timeout / default: 1m45s
* TIMEOUT_NET: change net timeout / default: 3m30s
* PING_INT: change ping timeout / default: 1m15s
* PROVIDED_BY: change provided by string / default:"syncthing-relay"
* SERVER_PORT: port hte relay server listens on / default:22067
* STATUS_PORT: disable by default to enable it add `-d 22070:22070` to you `docker run` command  / default:22070
* POOLS: leave empty for private relay use "https://relays.syncthing.net/endpoint" for public relay / default: ""
* RELAY_OPTS: to provide addition options not configurable via env variables above / default: ""
  - example: `-e RELAY_OPTS='-ext-address=:443'`

Have a look at the current doc [GitHub - relaysrv](https://github.com/syncthing/relaysrv/blob/master/README.md)

# Upgrade
```bash
# download updates
docker pull t4skforce/syncthing-relay:latest
# stop current running image
docker stop syncthing-relay
# remove container
docker rm syncthing-relay
# start with new base image
docker run --name syncthing-relay -d -p 22067:22067 -e RATE_GLOBAL=6000000 -e RATE_SESSION=1000000 -v /your/home:/home/relaysrv/certs:ro --restart=always t4skforce/syncthing-relay:latest
# cleanup docker images
docker rmi -f $(docker images | grep "<none>" | awk "{print \$3}") > /dev/null 2>&1
```

# Autostart
To enable the relay server to start at system-startup we need to create a systemd service file `vim /lib/systemd/system/syncthing-relay.service`:

```ini
[Unit]
Description=Syncthing-relay-Server
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a syncthing-relay
ExecStop=/usr/bin/docker stop -t 2 syncthing-relay

[Install]
WantedBy=multi-user.target
```

To start the service manually call `systemctl start syncthing-relay`. For retrieving the current service status call `systemctl status syncthing-relay -l`

```bash
root@syncthing:~# systemctl status syncthing-relay
● syncthing-relay.service - Syncthing-relay-Server
   Loaded: loaded (/lib/systemd/system/syncthing-relay.service; disabled)
   Active: active (running) since Sun 2016-04-17 15:41:39 BST; 9min ago
 Main PID: 11010 (docker)
   CGroup: /system.slice/syncthing-relay.service
           └─11010 /usr/bin/docker start -a syncthing-relay

Apr 17 15:41:39 syncthing docker[11651]: 2016/04/17 14:41:39 main.go:89: Connection limit 838860
Apr 17 15:41:39 syncthing docker[11651]: 2016/04/17 14:41:39 main.go:147: URI: relay://0.0.0.0:22067/?id=<your server id>&pingInterval=1m15s&networkTimeout=3m30s&sessionLimitBps=1000000&globalLimitBps=6000000&statusAddr=&providedBy=syncthing-relay

```

And last but not least we need to enable our newly created service via issuing `systemctl enable syncthing-relay`:
```bash
root@syncthing:~# systemctl enable syncthing-relay
Created symlink from /etc/systemd/system/multi-user.target.wants/syncthing-relay.service to /lib/systemd/system/syncthing-relay.service.
```

# Auto Upgrade
Combine all the above and autoupgrade the container at defined times. This requires you to at least setup [Autostart](#autostart).

First we need to generate your upgrade shell script `vim /root/syncthing-relay_upgrade.sh`:

```bash
#!/bin/bash

# Directory to look for the Certificates
CERT_HOME="/your/home/certs"

# download updates
docker pull t4skforce/syncthing-relay:latest
# stop current running image
systemctl stop syncthing-relay
# remove container
docker rm syncthing-relay
# start with new base image
docker run --name syncthing-relay -d -p 22067:22067 -e RATE_GLOBAL=6000000 -e RATE_SESSION=1000000 -v ${CERT_HOME}:/home/relaysrv/certs:ro --restart=always t4skforce/syncthing-relay:latest
# stop container
docker stop syncthing-relay
# start via service
systemctl start syncthing-relay
# cleanup docker images
docker rmi -f $(docker images | grep "<none>" | awk "{print \$3}") > /dev/null 2>&1
```

Next we need to make this file executable `chmod +x /root/syncthing-relay_upgrade.sh`, and test if the upgrade script works by calling the shell-script and checking the service status afterwards:
```bash
root@syncthing:~# /root/syncthing-relay_upgrade.sh
root@syncthing:~# systemctl status syncthing-relay
● syncthing-relay.service - Syncthing-relay-Server
   Loaded: loaded (/lib/systemd/system/syncthing-relay.service; enabled)
   Active: active (running) since Sun 2016-04-17 11:42:57 BST; 2s ago
 Main PID: 2642 (docker)
   CGroup: /system.slice/syncthing-relay.service
           └─2642 /usr/bin/docker start -a syncthing-relay
```

Now we need to set the trigger for the upgrade. In this example we just setup a weekly upgrade via crontab scheduled for Sunday at midnight. We add `0 0 * * 7 root /root/syncthing-relay_upgrade.sh` to `/etc/crontab`. The resulting file looks like:

```bash
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# m h dom mon dow user  command
17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly
25 6    * * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6    * * 7   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6    1 * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
# Syncthing-relay-Server Docker Container Upgrade
0  0    * * 7   root    /root/syncthing-relay_upgrade.sh
#
```
