FROM debian:latest
########################################
#              Settings                #
########################################
# Syncthing-Relay Server
ENV DEBUG           false

ENV SERVER_PORT     22067
ENV RELAY_OPTS      ""

# to enable the status interface add ' -p 22070:22070' to you docker command
ENV STATUS_PORT     22070

# 10 mbps
ENV RATE_GLOBAL     10000000
# 500 kbps
ENV RATE_SESSION    500000

ENV TIMEOUT_MSG     1m45s
ENV TIMEOUT_NET     3m30s
ENV PING_INT        1m15s

ENV PROVIDED_BY     "syncthing-relay"
# leave empty for private relay use "https://relays.syncthing.net/endpoint" for public relay
ENV POOLS           ""

########################################
#               Setup                  #
########################################
ARG USERNAME=relaysrv
ARG USERGROUP=relaysrv
ARG APPUID=1000
ARG APPGID=1000
ENV USER_HOME /home/relaysrv
ARG BUILD_REQUIREMENTS="curl"
ARG REQUIREMENTS="openssl ca-certificates"
########################################

########################################
#               Build                  #
########################################
ARG VERSION="v1.15.0"
ARG DOWNLOADURL="https://github.com/syncthing/relaysrv/releases/download/v1.15.0/strelaysrv-linux-amd64-v1.15.0.tar.gz"
ARG BUILD_DATE="2021-11-05T13:41:06Z"
########################################

USER root
ARG DEBIAN_FRONTEND=noninteractive
# setup
RUN apt-get update -qqy \
	&& apt-get -qqy --no-install-recommends install ${BUILD_REQUIREMENTS} ${REQUIREMENTS} \
	&& mkdir -p ${USER_HOME} \
	&& groupadd --system --gid ${APPGID} ${USERGROUP} \
	&& useradd --system --uid ${APPUID} -g ${USERGROUP} ${USERNAME} --home ${USER_HOME} \
	&& echo "${USERNAME}:$(openssl rand 512 | openssl sha256 | awk '{print $2}')" | chpasswd \
	&& chown -R ${USERNAME}:${USERGROUP} ${USER_HOME}

# install relay
WORKDIR /tmp/
RUN curl -Ls ${DOWNLOADURL} --output relaysrv.tar.gz \
	&& tar -zxf relaysrv.tar.gz \
	&& rm relaysrv.tar.gz \
	&& mkdir -p ${USER_HOME}/server ${USER_HOME}/certs \
	&& cp /tmp/*relaysrv*/*relaysrv ${USER_HOME}/server/relaysrv \
	&& chown -R ${USERNAME}:${USERGROUP} ${USER_HOME}

# cleanup
RUN apt-get --auto-remove -y purge ${BUILD_REQUIREMENTS} \
  	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/*

EXPOSE ${STATUS_PORT} ${SERVER_PORT}

USER $USERNAME
VOLUME ${USER_HOME}/certs

CMD ${USER_HOME}/server/relaysrv \
    -keys="${USER_HOME}/certs" \
    -listen=":${SERVER_PORT}" \
    -status-srv=":${STATUS_PORT}" \
    -debug="${DEBUG}" \
    -global-rate="${RATE_GLOBAL}" \
    -per-session-rate="${RATE_SESSION}" \
    -message-timeout="${TIMEOUT_MSG}" \
    -network-timeout="${TIMEOUT_NET}" \
    -ping-interval="${PING_INT}" \
    -provided-by="${PROVIDED_BY}" \
    -pools="${POOLS}" ${RELAY_OPTS}
