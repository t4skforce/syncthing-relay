FROM ubuntu:latest
# Syncthing-Relay Server
ENV DEBUG           false

# 10 mbps
ENV RATE_GLOBAL     10000000
# 500 kbps
ENV RATE_SESSION    500000

ENV TIMEOUT_MSG     1m45s
ENV TIMEOUT_NET     3m30s
ENV PING_INT        1m15s

ENV PROVIDED_BY     "syncthing-relay"
ENV SERVER          "0.0.0.0:22067"
# disable status interface. for enablin it use 0.0.0.0:22070 and add ' -p 22070:22070' to you docker command
ENV STATUS          ""
# leave empty for private relay use "https://relays.syncthing.net/endpoint" for public relay
ENV POOLS           ""

ADD http://build.syncthing.net/job/relaysrv/lastSuccessfulBuild/artifact/relaysrv-linux-amd64.tar.gz /tmp/relaysrv.tar.gz
RUN apt-get update && \
    apt-get install ca-certificates -y && \
    apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    tar -xzvf /tmp/relaysrv.tar.gz && \
    rm /tmp/relaysrv.tar.gz

EXPOSE 22070 ${SERV_PORT}

RUN groupadd -r relaysrv && \
    useradd -r -m -g relaysrv relaysrv && \
    mv relaysrv* /home/relaysrv/relaysrv && \
    mkdir -p /home/relaysrv/certs && \
    chown -R relaysrv:relaysrv /home/relaysrv

USER relaysrv
VOLUME /home/relaysrv

CMD /home/relaysrv/relaysrv/relaysrv \
    -keys="/home/relaysrv/certs" \
    -listen="${SERVER}" \
    -status-srv="${STATUS}" \
    -debug="${DEBUG}" \
    -global-rate="${RATE_GLOBAL}" \
    -per-session-rate="${RATE_SESSION}" \
    -message-timeout="${TIMEOUT_MSG}" \
    -network-timeout="${TIMEOUT_NET}" \
    -ping-interval="${PING_INT}" \
    -provided-by="${PROVIDED_BY}" \
    -pools="${POOLS}"
