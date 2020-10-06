FROM cimg/node:14.13@sha256:8a6cdbd42e3068ad43260eaafa6264cdccdc520c37706ef7068532576b57a428

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
RUN npm i npm@6.14.8 -g

WORKDIR ${HOME}/project
