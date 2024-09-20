FROM node:16-alpine

ENV yq_version 4.44.3

RUN apk add --no-cache curl rsync && \
    curl -sSLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v$yq_version/yq_linux_amd64 && \
    chmod +x /usr/local/bin/yq

WORKDIR /app

CMD ["node", "--version"]
