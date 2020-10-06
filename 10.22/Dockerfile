FROM cimg/node:10.22@sha256:9553bae032107ecc705767df483cb362af4fc04269885875fc4d895b1d65b25b

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
