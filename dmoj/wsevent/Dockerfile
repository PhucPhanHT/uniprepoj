FROM node:18-alpine

WORKDIR /app
COPY repo/package.json .
COPY repo/package-lock.json .
RUN npm install

ENV PATH="/app/node_modules/.bin:${PATH}"

EXPOSE 15100
EXPOSE 15101
EXPOSE 15102

ENTRYPOINT node /app/site/websocket/daemon.js
