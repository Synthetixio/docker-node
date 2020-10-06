FROM cimg/node:12.18@sha256:02adec9a20f3b660bffc00330689210107a254491a58f6884d666499949261ef

# home folder
ENV HOME /home/circleci

# good colors for most applications
ENV TERM xterm

# no interactive frontend during docker build
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

# set npm path for global modules
ENV NPM_CONFIG_PREFIX ${HOME}/.npm-global

# add npm global packages to path
ENV PATH $PATH:${HOME}/.npm-global/bin

# avoid million NPM install messages
ENV npm_config_loglevel warn

# install latest npm, regardless of node version, for speed and fixes
RUN npm i npm@latest -g

WORKDIR ${HOME}/project
