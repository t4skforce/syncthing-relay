FROM ubuntu:latest
# Syncthing-Relay Server
ENV DEBUG           false

ENV SERVER_PORT     22067
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

RUN apt-get update && \
    apt-get install ca-certificates wget -y && \
    apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
	wget $(wget -q https://api.github.com/repos/syncthing/relaysrv/releases/latest -O- | egrep "browser_download_url.*relaysrv-linux-amd64.*.gz" | cut -d'"' -f4) -O /tmp/relaysrv.tar.gz && \
	apt-get remove wget -y && \
    tar -xzvf /tmp/relaysrv.tar.gz && \
    rm /tmp/relaysrv.tar.gz

EXPOSE ${STATUS_PORT} ${SERVER_PORT}

RUN groupadd -r relaysrv && \
    useradd -r -m -g relaysrv relaysrv && \
    mv relaysrv* /home/relaysrv/relaysrv && \
    mkdir -p /home/relaysrv/certs && \
    chown -R relaysrv:relaysrv /home/relaysrv

USER relaysrv
VOLUME /home/relaysrv

CMD /home/relaysrv/relaysrv/relaysrv \
    -keys="/home/relaysrv/certs" \
    -listen="0.0.0.0:${SERVER_PORT}" \
    -status-srv="0.0.0.0:${STATUS_PORT}" \
    -debug="${DEBUG}" \
    -global-rate="${RATE_GLOBAL}" \
    -per-session-rate="${RATE_SESSION}" \
    -message-timeout="${TIMEOUT_MSG}" \
    -network-timeout="${TIMEOUT_NET}" \
    -ping-interval="${PING_INT}" \
    -provided-by="${PROVIDED_BY}" \
    -pools="${POOLS}"
