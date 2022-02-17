
FROM debian:stable-slim@sha256:3ecce669b6be99312305bc3acc90f91232880c68b566f257ae66647e9414174f

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
# required for patch-package on heroku
ENV NPM_CONFIG_PRODUCTION false
ENV YARN_PRODUCTION false

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
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
    done \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v16.14.0/node-v16.14.0-linux-$ARCH.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v16.14.0/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v16.14.0-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xJf "node-v16.14.0-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v16.14.0-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

# avoid million NPM install messages
ENV npm_config_loglevel warn

# allow installing when the main user is root
ENV npm_config_unsafe_perm true

# install latest npm, regardless of node version, for speed and fixes
RUN npm install -g npm@8.5.0

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
    && curl -fsSLO --compressed "https://yarnpkg.com/downloads/1.22.17/yarn-v1.22.17.tar.gz" \
    && curl -fsSLO --compressed "https://yarnpkg.com/downloads/1.22.17/yarn-v1.22.17.tar.gz.asc" \
    && gpg --batch --verify yarn-v1.22.17.tar.gz.asc yarn-v1.22.17.tar.gz \
    && mkdir -p /opt \
    && tar -xzf yarn-v1.22.17.tar.gz -C /opt/ \
    && ln -s /opt/yarn-v1.22.17/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v1.22.17/bin/yarnpkg /usr/local/bin/yarnpkg \
    && rm yarn-v1.22.17.tar.gz.asc yarn-v1.22.17.tar.gz
RUN yarn --version

############### WRAPPING UP ###############
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node"]
