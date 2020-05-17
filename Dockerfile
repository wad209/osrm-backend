FROM debian:stretch-slim as builder
RUN mkdir -p /src  && mkdir -p /opt
COPY . /src
WORKDIR /src

RUN NPROC=${BUILD_CONCURRENCY:-$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1)} \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        cmake \
        make \
        git \
        gcc \
        g++ \
        libbz2-dev \
        libxml2-dev \
        libzip-dev \
        libboost1.62-all-dev \
        lua5.2 \
        liblua5.2-dev \
        libtbb-dev -o APT::Install-Suggests=0 -o APT::Install-Recommends=0 \
    && git show --format="%H" | head -n1 > /opt/OSRM_GITSHA \
    && mkdir -p build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release -DENABLE_ASSERTIONS=Off \
        -DBUILD_TOOLS=Off -DENABLE_LTO=On \
    && make -j${NPROC} install \
    && cd ../profiles \
    && cp -r * /opt \
    && strip /usr/local/bin/* \
    && rm -rf /src /usr/local/lib/libosrm*


FROM debian:stretch-slim as runstage
RUN mkdir -p /src  && mkdir -p /opt
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libboost-program-options1.62.0 \
        libboost-regex1.62.0 \
        libboost-date-time1.62.0 \
        libboost-chrono1.62.0 \
        libboost-filesystem1.62.0 \
        libboost-iostreams1.62.0 \
        libboost-thread1.62.0 \
        expat \
        liblua5.2-0 \
        libtbb2 \
    && rm -rf /var/lib/apt/lists/* 
COPY --from=builder /usr/local /usr/local
COPY --from=builder /opt /opt
WORKDIR /opt

COPY start_osrm.sh /opt/start_osrm
RUN chmod 0700 /opt/start_osrm

CMD ["/opt/start_osrm"]

EXPOSE 5000
