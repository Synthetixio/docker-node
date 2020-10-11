FROM debian:buster-slim@sha256:8d81110c3f93a777e3f4053a6b18b70e4a1003655b8c2664bdf18b19043f99d9

ENV NODE_VERSION 12.19.0

# good colors for most applications
ENV TERM xterm

# no interactive frontend during docker build
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

# install curl for yarn
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    curl \
    ca-certificates \
    # install git and python
    git \
    python \
    python-pip \
    python-setuptools \
    # common build dependencies
    make \
    g++ \
    gcc \
    clang \
    unzip \
    # node deps
    wget \
    gnupg \
    dirmngr \
    xz-utils \
    libatomic1 \
    libc6 \
    libgcc1 \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# create new node user
RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# set home and project dirs
ENV HOME /home/root
ENV PROJECT $HOME/project

# create local bin dir
RUN mkdir -p $HOME/bin
# add local bin dir to path
ENV PATH $PATH:$HOME/bin

# create project dir
RUN mkdir -p $PROJECT

# work in local home dir
WORKDIR $HOME

# allow installing when the main user is root
ENV npm_config_unsafe_perm true
# set npm path for global modules
ENV NPM_CONFIG_PREFIX $HOME/.npm-global
# add npm global packages to path
ENV PATH $PATH:$HOME/.npm-global/bin

# avoid million NPM install messages
ENV npm_config_loglevel warn

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
    && set -ex \
    && for key in \
      4ED778F539E3634C779C87C6D7062848A1AB005C \
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
      A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
      108F52B48DB57BB0CC439B2997B01419BD92F80A \
      B9E2F5981AA6E0CD28160D9FF13993A75599653C \
    ; do \
      gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
      gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
      gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
    done \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C $HOME --strip-components=1 --no-same-owner \
    && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
    && find $HOME -type f -executable -exec ldd '{}' ';' \
      | awk '/=>/ { print $(NF-1) }' \
      | sort -u \
      | xargs -r dpkg-query --search \
      | cut -d: -f1 \
      | sort -u \
      | xargs -r apt-mark manual \
    && ln -s $HOME/bin/node $HOME/bin/nodejs

# install latest npm, regardless of node version, for speed and fixes
RUN npm install -g npm@6.14.8
# remove old npm
RUN rm $HOME/bin/npm
# verify npm works
RUN npm doctor
# should be root user
RUN npm config -g set user root

# install yarn
RUN set -ex \
  && savedAptMark="$(apt-mark showmanual)" \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/1.22.10/yarn-v1.22.10.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/1.22.10/yarn-v1.22.10.tar.gz.asc" \
  && gpg --batch --verify yarn-v1.22.10.tar.gz.asc yarn-v1.22.10.tar.gz \
  && mkdir -p $HOME \
  && tar -xzf yarn-v1.22.10.tar.gz -C $HOME \
  && ln -s $HOME/yarn-v1.22.10/bin/yarn $HOME/bin/yarn \
  && ln -s $HOME/yarn-v1.22.10/bin/yarnpkg $HOME/bin/yarnpkg \
  && rm yarn-v1.22.10.tar.gz.asc yarn-v1.22.10.tar.gz \
  && find $HOME -type f -executable -exec ldd '{}' ';' \
    | awk '/=>/ { print $(NF-1) }' \
    | sort -u \
    | xargs -r dpkg-query --search \
    | cut -d: -f1 \
    | sort -u \
    | xargs -r apt-mark manual

# add yarn global packages to path
ENV PATH $PATH:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin

# set yarn path for global modules
RUN yarn config set prefix $HOME/.yarn

# disable next.js telemetry
ENV NEXT_TELEMETRY_DISABLED 1

COPY docker-entrypoint.sh $HOME/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

WORKDIR $PROJECT

# print versions of local tools
RUN echo "node version:  $(node -v) \n" \
  "npm version:           $(npm -v) \n" \
  "yarn version:          $(yarn -v) \n" \
  "git version:           $(git --version) \n" \
  "user:                  $(whoami) \n" \
  "debian version:        $(cat /etc/os-release)"

CMD ["node"]
