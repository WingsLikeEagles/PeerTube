FROM alpine:3.7

RUN apk -U upgrade && \
    apk add ca-certificates ffmpeg nodejs openssl yarn && \
    apk add -U vips-dev fftw-dev --repository https://dl-3.alpinelinux.org/alpine/edge/testing/ && \
    update-ca-certificates && \
    rm -rf /tmp/* /var/cache/apk/*

WORKDIR /var/www/peertube
RUN adduser -h /var/www/peertube -s /bin/sh -D peertube && \
    chown peertube:peertube /var/www/peertube

RUN apk add --virt .dep curl git g++ python make unzip && \
    export PEERTUBE_VER=$(curl -s https://api.github.com/repos/chocobozzz/peertube/releases/latest | grep tag_name | cut -d '"' -f 4) && echo "Latest Peertube version is $PEERTUBE_VER" && \
    su peertube -c 'curl -sL "https://github.com/Chocobozzz/PeerTube/releases/download/$PEERTUBE_VER/peertube-$PEERTUBE_VER.zip" > peertube-$PEERTUBE_VER.zip && \
    unzip -q peertube-$PEERTUBE_VER.zip && \
    rm peertube-$PEERTUBE_VER.zip && \
    mv peertube-$PEERTUBE_VER peertube-latest && \
    cd peertube-latest && \
    yarn install --production --pure-lockfile && \
    yarn cache clean' && \
    apk del .dep && \
    rm -rf /tmp/* /var/cache/apk/*

USER peertube
WORKDIR /var/www/peertube/peertube-latest

ENV NODE_ENV=production
ENV NODE_CONFIG_DIR=/var/www/peertube/config
VOLUME [ "/var/www/peertube/config", "/var/www/peertube/storage" ]

CMD [ "/usr/bin/npm", "start" ]
