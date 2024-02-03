
FROM debian:stable-slim@sha256:6368f4aa774c7ee6cfd897b9acd6c8b3e45db3fb01ea4189ea62cd8476348752

############### ENV SETUP ###############
# husky workaround - https://github.com/typicode/husky/issues/821
ENV HUSKY 0
ENV HUSKY_SKIP_INSTALL 1
# always behave as CI
ENV CI true
# disable next.js telemetry
ENV NEXT_TELEMETRY_DISABLED 1
# no interactive frontend during docker build
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
# good colors for most applications
ENV TERM xterm

############### INSTALL DEPS ###############
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    locales \
    software-properties-common \
    python3-distutils \
    python3-apt \
    python3-dev \
    build-essential \
    openssh-server \
    # mozjpeg dependencies
    autoconf \
    automake \
    libtool \
    pkgconf \
    nasm \
    file \
    musl-dev \
    # end of mozjpeg dependencies
    curl \
    python3 \
    make \
    g++ \
    gcc \
    git \
    clang \
    unzip \
    wget \
    binutils-gold \
    gnupg \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*
# locale setup
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

############### PYTHON SETUP ###############
# install pip
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3 get-pip.py
# add local python dir to path
ENV PATH $PATH:/root/.local/bin

############### NODE SETUP ###############
# create new node user
RUN groupadd --gid 1000 node \
    && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# node setup
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
      141F07595B7B3FFE74309A937405533BE57C7D57 \
      74F12602B6F1C4E913FAA37AD3A89613643B6201 \
      61FC681DFB92A079F1685E77973F295594EC4689 \
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
      C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
      108F52B48DB57BB0CC439B2997B01419BD92F80A \
    ; do \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
    done \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v18.19.0/node-v18.19.0-linux-$ARCH.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v18.19.0/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v18.19.0-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xJf "node-v18.19.0-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v18.19.0-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

# avoid million NPM install messages
ENV npm_config_loglevel warn

# allow installing when the main user is root
ENV npm_config_unsafe_perm true

# install latest npm, regardless of node version, for speed and fixes
RUN npm install -g npm@10.4.0

RUN node --version \
    && npm --version

# lock dependencies by default
RUN npm config set save-exact=true

############### YARN SETUP ###############
RUN set -ex \
    && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
    ; do \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
    done \
    && curl -fsSLO --compressed "https://yarnpkg.com/downloads/1.22.21/yarn-v1.22.21.tar.gz" \
    && curl -fsSLO --compressed "https://yarnpkg.com/downloads/1.22.21/yarn-v1.22.21.tar.gz.asc" \
    && gpg --batch --verify yarn-v1.22.21.tar.gz.asc yarn-v1.22.21.tar.gz \
    && mkdir -p /opt \
    && tar -xzf yarn-v1.22.21.tar.gz -C /opt/ \
    && ln -s /opt/yarn-v1.22.21/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v1.22.21/bin/yarnpkg /usr/local/bin/yarnpkg \
    && rm yarn-v1.22.21.tar.gz.asc yarn-v1.22.21.tar.gz
RUN yarn --version

# pm2 setup
RUN npm install -g pm2@5.3.1

# pnpm setup
RUN npm install -g pnpm@8.15.1

# turbo setup
RUN npm install -g turbo@1.12.2

############### WRAPPING UP ###############
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node"]
