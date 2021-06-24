FROM debian:stable-slim@sha256:463cabea60abc361ab670570fe30549a6531cd9af4a1b8577b1c93e9b5a1d369

SHELL ["/bin/bash", "-c"]

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
  curl \
  binutils-gold \
  gnupg \
  # mozjpeg dependencies
  autoconf \
  automake \
  libtool \
  pkgconf \
  nasm \
  file \
  musl-dev \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get -y autoclean

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
# husky workaround - https://github.com/typicode/husky/issues/821
ENV HUSKY 0
ENV HUSKY_SKIP_INSTALL 1

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
# install node
ENV NVM_DIR /usr/local/nvm
ENV NVM_VERSION 0.38.0
ENV NODE_VERSION 14.17.1
ENV NPM_VERSION 7.18.1

# install node via nvm
RUN mkdir -p ${NVM_DIR} \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash \
    && source ${NVM_DIR}/nvm.sh \
    && nvm install ${NODE_VERSION} \
    && nvm alias default ${NODE_VERSION}

# add node and npm to path so the commands are available
ENV NODE_PATH ${NVM_DIR}/versions/node/v${NODE_VERSION}/lib/node_modules
ENV PATH ${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:$PATH

# avoid million NPM install messages
ENV npm_config_loglevel warn

# # allow installing when the main user is root
# ENV npm_config_unsafe_perm true

# # should be root user
# RUN npm config -g set user root

# install latest npm, regardless of node version, for speed and fixes
# RUN npm install -g npm@$NPM_VERSION

RUN npm i -g npm@$NPM_VERSION
# RUN npm install --global npm

RUN node --version
RUN npm --version

############### yarn setup ###############
# RUN set -ex \
#   && for key in \
#   6A010C5166006599AA17F08146C2130DFD2497F5 \
#   ; do \
#   gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
#   gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
#   gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
#   done \
#   && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
#   && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
#   && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
#   && mkdir -p /opt \
#   && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
#   && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
#   && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
#   && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz

# RUN yarn --version
