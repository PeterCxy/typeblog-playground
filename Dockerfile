FROM base/archlinux:2015.06.01
MAINTAINER Peter Cai "peter@typeblog.net"

# Update the base image and install nodejs
RUN pacman -Syu --noconfirm
RUN pacman -S nodejs npm coffee-script --noconfirm

# Copy to workdir
WORKDIR /usr/src/peter
COPY node/src/ /usr/src/peter/src/
COPY node/index.js /usr/src/peter/
COPY node/package.json /usr/src/peter/
RUN npm install

# Entry
EXPOSE 8080
CMD ["npm", "start"]
