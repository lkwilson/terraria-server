FROM debian:12-slim AS builder
WORKDIR /builder

# The ttyd url
ARG TTYD_URL=https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64
# The server url download
ARG TERRARIA_URL=https://terraria.org/api/download/pc-dedicated-server/terraria-server-1449.zip

RUN apt-get update && \
    apt-get install -y curl unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    curl -L -o ttyd $TTYD_URL && \
    chmod +x ./ttyd && \
    curl -L -o terraria.zip $TERRARIA_URL && \
    unzip -d terraria terraria.zip && \
    mv ./terraria/*/Linux app && \
    chmod +x ./app/TerrariaServer.bin.x86_64 && \
    rm -rf terraria.zip terraria

FROM debian:12-slim
COPY terraria /usr/local/bin/terraria
RUN apt-get update && \
    apt-get install -y tmux && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chmod +x /usr/local/bin/terraria
COPY --from=builder /builder/app /app
COPY --from=builder /builder/ttyd /usr/local/bin/ttyd

WORKDIR /app
ENV TTYD_PORT=7681
ENV SLEEP_TIME=600
CMD ["terraria"]
