FROM alpine:3.12@sha256:a9c28c813336ece5bb98b36af5b66209ed777a394f4f856c6e62267790883820

ENV NODE_VERSION 14.17.0

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
# set home and project dirs
ENV HOME /root
ENV PROJECT $HOME/project
# create project dir
RUN mkdir -p $PROJECT
# create local bin dir
RUN mkdir -p $HOME/bin
# add local bin dir to path
ENV PATH $PATH:$HOME/bin
# work in local home dir
WORKDIR $HOME

# install deps
RUN apk add --no-cache \
        bash \
        python3 \
        libstdc++ \
        git \
        py3-pip \
        py3-setuptools \
        make \
        g++ \
        gcc \
        clang \
        unzip \
        curl \
        binutils-gold \
        gnupg \
        libgcc \
        linux-headers \
        tar \
        # mozjpeg dependencies
        autoconf \
        automake \
        libtool \
        tiff \
        jpeg \
        zlib \
        zlib-dev \
        pkgconf \
        nasm \
        file \
        musl-dev

############### node setup ###############
# create new node user
# RUN addgroup -g 1000 node \
#     && adduser -u 1000 -G node -s /bin/sh -D node
# install node
RUN ARCH= && alpineArch="$(apk --print-arch)" \
      && case "${alpineArch##*-}" in \
        x86_64) \
          ARCH='x64' \
          CHECKSUM="019a8cae26a0ab9a8dc1264c2e1f11ad659e2093716263bb470f02189856b0a4" \
          ;; \
        *) ;; \
      esac \
  && if [ -n "${CHECKSUM}" ]; then \
    set -eu; \
    curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz"; \
    echo "$CHECKSUM  node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" | sha256sum -c - \
      && tar -xJf "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" -C $HOME --strip-components=1 --no-same-owner \
      && ln -s $HOME/bin/node $HOME/bin/nodejs; \
  else \
    echo "Building from source" \
    # gpg keys listed at https://github.com/nodejs/node#release-keys
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
      gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
      gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
      gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
    done \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xf "node-v$NODE_VERSION.tar.xz" \
    && cd "node-v$NODE_VERSION" \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) V= \
    && make install \
    && cd .. \
    && rm -Rf "node-v$NODE_VERSION" \
    && rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt; \
  fi \
  && rm -f "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz"
# avoid million NPM install messages
ENV npm_config_loglevel warn
# allow installing when the main user is root
ENV npm_config_unsafe_perm true
# set npm path for global modules
# ENV NPM_CONFIG_PREFIX $HOME/.npm-global
# add npm global packages to path
# ENV PATH $PATH:$HOME/.npm-global/bin
# should be root user
RUN npm config -g set user root
# install latest npm, regardless of node version, for speed and fixes
RUN npm install -g npm@7.14.0
# remove old npm
# RUN rm $HOME/bin/npm
# create folders for npm doctor
RUN mkdir $HOME/node_modules
RUN mkdir $HOME/node_modules/.bin
# verify npm works
# disabled due to required update to node LTS
RUN npm doctor

############### yarn setup ###############
# install yarn
RUN for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/1.22.5/yarn-v1.22.5.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/1.22.5/yarn-v1.22.5.tar.gz.asc" \
  && gpg --batch --verify yarn-v1.22.5.tar.gz.asc yarn-v1.22.5.tar.gz \
  && mkdir -p $HOME \
  && tar -xzf yarn-v1.22.5.tar.gz -C $HOME \
  && ln -s $HOME/yarn-v1.22.5/bin/yarn $HOME/bin/yarn \
  && ln -s $HOME/yarn-v1.22.5/bin/yarnpkg $HOME/bin/yarnpkg \
  && rm yarn-v1.22.5.tar.gz.asc yarn-v1.22.5.tar.gz
# add yarn global packages to path
ENV PATH $PATH:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin
# set yarn path for global modules
RUN yarn config set prefix $HOME/.yarn

############### wrapping up ###############
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
WORKDIR $PROJECT
CMD ["node"]
