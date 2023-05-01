############################
# STEP 1 build executable binary
############################
FROM golang:1.20.1-alpine AS builder
RUN apk update && apk add --no-cache git bash wget curl
WORKDIR /go/src/XTLS/Xray-core
RUN git clone --progress https://github.com/XTLS/Xray-core.git --branch  v1.8.1 . && \
  CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -v -trimpath -ldflags "-s -w" -o /tmp/xray ./main
############################
# STEP 2 build a small image
############################
FROM alpine

RUN apk update && apk add ca-certificates && \
    mkdir -p /usr/bin && \
    wget -O /usr/bin/geosite.dat  https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat && \
    wget -O /usr/bin/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
COPY --from=builder /tmp/xray /usr/bin/xray
ADD ./entrypoint.sh entrypoint.sh
RUN chmod +x ./entrypoint.sh
#ENTRYPOINT ["/usr/bin/v2ray/v2ray"]
ENV PATH /usr/bin/xray:$PATH
#CMD ["xray", "-config=/etc/xray/config.json"]
ENTRYPOINT ["sh", "./entrypoint.sh"]
