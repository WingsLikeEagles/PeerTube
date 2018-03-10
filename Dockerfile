FROM ubuntu

RUN apt update && apt install -y ffmpeg openssl g++ make redis-server git curl unzip && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt update && apt install -y nodejs yarn

WORKDIR /var/www/peertube
RUN useradd -b /var/www/peertube -s /bin/sh peertube && \
    chown peertube:peertube /var/www/peertube
USER peertube

RUN PEERTUBE_VER=$(curl -s https://api.github.com/repos/chocobozzz/peertube/releases/latest | grep tag_name | cut -d '"' -f 4) && echo "Latest Peertube version is $PEERTUBE_VER" && \
    curl -sL "https://github.com/Chocobozzz/PeerTube/releases/download/$PEERTUBE_VER/peertube-$PEERTUBE_VER.zip" > peertube-$PEERTUBE_VER.zip && \
    unzip -q peertube-$PEERTUBE_VER.zip && \
    rm peertube-$PEERTUBE_VER.zip && \
    mv peertube-$PEERTUBE_VER peertube-latest

WORKDIR /var/www/peertube/peertube-latest
    
RUN yarn install --production --pure-lockfile && \
    yarn cache clean

ENV NODE_ENV=production
ENV NODE_CONFIG_DIR=/var/www/peertube/config
VOLUME [ "/var/www/peertube/config", "/var/www/peertube/storage" ]

CMD [ "/usr/bin/npm", "start" ]
