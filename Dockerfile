############################
# STEP 1 build executable binary
############################
FROM golang:1.21-alpine AS builder
RUN apk update && apk add --no-cache git bash wget curl
WORKDIR /go/src/XTLS/Xray-core
RUN git clone --progress https://github.com/XTLS/Xray-core.git --branch  v1.8.4 . && \
  CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -v -trimpath -ldflags "-s -w" -o /tmp/xray ./main
############################
# STEP 2 build a small image
############################
FROM alpine
RUN apk update && apk add bash && mkdir -p /CloudflareST && wget -O /CloudflareST/CloudflareST.tar.gz https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.2.4/CloudflareST_linux_amd64.tar.gz && cd /CloudflareST && tar -zxvf CloudflareST.tar.gz && rm -rf CloudflareST.tar.gz
RUN apk add ca-certificates && \
    mkdir -p /usr/bin && \
    wget -O /usr/bin/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat && \
    wget -O /usr/bin/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat
COPY --from=builder /tmp/xray /usr/bin/xray
ADD ./entrypoint.sh entrypoint.sh
RUN chmod +x ./entrypoint.sh
#ENTRYPOINT ["/usr/bin/v2ray/v2ray"]
ENV PATH /usr/bin/xray:$PATH
#CMD ["xray", "-config=/etc/xray/config.json"]
ENTRYPOINT ["sh", "./entrypoint.sh"]
