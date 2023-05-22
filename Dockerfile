# Base image
FROM ubuntu:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y git build-essential automake libtool pkg-config gengetopt \
                       libglib2.0-dev libconfig-dev libssl-dev libcurl4-openssl-dev \
                       libjansson-dev libnice-dev libsrtp2-dev libsofia-sip-ua-dev \
                       libglib2.0-dev libopus-dev libogg-dev libini-config-dev \
                       libcollection-dev libwebsockets-dev cmake wget libavutil-dev \
                       libavcodec-dev libavformat-dev libavdevice-dev libavfilter-dev \
                       libjson-glib-dev python3-pip python3-setuptools python3-wheel && \
    pip3 install meson ninja

# Clone Janus repository
RUN git clone https://github.com/meetecho/janus-gateway.git /janus

WORKDIR /janus

# Build Janus
RUN sh autogen.sh && \
    ./configure --prefix=/janus --disable-websockets --disable-data-channels \
                --disable-rabbitmq --disable-mqtt --disable-unix-sockets && \
    make && \
    make install && \
    make configs

# Install transport plugins
RUN git clone https://github.com/meetecho/janus-transports.git /janus/janus-transports && \
    cd /janus/janus-transports && \
    make && \
    cp *.so /janus/lib/janus/transports/

# Expose necessary ports
EXPOSE 8088
EXPOSE 8188

# Start Janus server
CMD ["/janus/bin/janus", "-F", "/janus/etc/janus"]
