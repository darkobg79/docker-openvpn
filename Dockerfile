# Original credit: https://github.com/jpetazzo/dockvpn

# Smallest base image
FROM alpine:latest

LABEL maintainer="DarkoBG"

# Testing: pamtester libqrencode
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
#   echo "http://dl-4.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa tzdata python3 && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    apk add --update alpine-sdk python3 && \
    curl -L https://github.com/duosecurity/duo_openvpn/tarball/master > /tmp/duo-openvpn.tgz && \
    cd /tmp && tar xvzf duo-openvpn.tgz && cd duosecurity-duo_openvpn* && make install && cd / && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# timezone env with default
ENV TZ=Europe/London

# Needed by scripts
ENV OPENVPN=/etc/openvpn \
    EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki \
    HEALTH_CHECK_HOST=google.com

HEALTHCHECK --interval=1m CMD /usr/local/bin/healthcheck.sh

VOLUME ["/etc/openvpn"]
VOLUME ["/logs"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

