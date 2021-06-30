FROM debian:stable-slim@sha256:463cabea60abc361ab670570fe30549a6531cd9af4a1b8577b1c93e9b5a1d369

ENV NODE_VERSION 14.17.1
ENV YARN_VERSION 1.22.5
ENV NPM_VERSION 7.19.0

############### env setup ###############
# always behave as CI
ENV CI true
# disable next.js telemetry
ENV NEXT_TELEMETRY_DISABLED 1
# no interactive frontend during docker build
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
# good colors for most applications
ENV TERM xterm

# skip husky on CI - https://github.com/typicode/husky/issues/821
ENV HUSKY 0
ENV HUSKY_SKIP_INSTALL 1

# install deps
RUN apt-get update && \
  apt-get install -y \
  curl \
  python3 \
  python3-distutils \
  python3-apt \
  make \
  g++ \
  gcc \
  git \
  clang \
  unzip \
  binutils-gold \
  gnupg \
  ca-certificates \
  wget \
  dirmngr \
  xz-utils \
  libatomic1 \
  # mozjpeg dependencies
  autoconf \
  automake \
  libtool \
  pkgconf \
  nasm \
  file \
  musl-dev \
  && rm -rf /var/lib/apt/lists/*

############### python setup ###############
# install pip
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3 get-pip.py
# install python3-dev
RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  python3-dev \
  && rm -rf /var/lib/apt/lists/*
# add local python dir to path
ENV PATH $PATH:/root/.local/bin
# install slither
RUN pip3 install --user slither-analyzer

############### node setup ###############
# create new node user
RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

USER node

WORKDIR /home/node

# install node
RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  && set -ex \
  && for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    74F12602B6F1C4E913FAA37AD3A89613643B6201 \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C \
  ; do \
    gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /home/node --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /home/node/bin/node /home/node/bin/nodejs

ENV PATH="/home/node/bin:${PATH}"

# # avoid million NPM install messages
ENV npm_config_loglevel warn

# # # allow installing when the main user is root
# ENV npm_config_unsafe_perm true

# # RUN mkdir -p /github/home/.npm
# # RUN mkdir -p /github/workflow

RUN mkdir -p /home/node/node_modules/.bin

# # ENV npm_config_cache /github/home/.npm

# # # # should be root user
# # RUN npm config -g set user root

# # install latest npm, regardless of node version, for speed and fixes
RUN npm install -g npm@latest

RUN npm doctor

RUN node --version
RUN npm --version

# ############### wrapping up ###############
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node"]
