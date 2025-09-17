FROM debian:11

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS="yes"

#RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt-get update && apt-get -yq install git apt-utils \
  && ln -sfn  /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime

RUN apt-get -yq install \
# build
    build-essential cmake automake autoconf 'libtool-bin|libtool' pkg-config \
# general
    libnss3-tools libssl-dev zlib1g-dev libdb-dev unixodbc-dev libncurses5-dev libexpat1-dev libgdbm-dev bison erlang-dev libtpl-dev libtiff5-dev uuid-dev \
# core
    libpcre3-dev libedit-dev libsqlite3-dev libcurl4-openssl-dev nasm \
# core codecs
    libogg-dev libspeex-dev libspeexdsp-dev \
# mod_enum
    libldns-dev \
# mod_python3
    python3-dev \
# mod_av
    libavformat-dev libswscale-dev libavresample-dev \
# mod_lua
    liblua5.2-dev lua5.2 lua-socket luarocks \
# mod_opus
    libopus-dev \
# mod_pgsql
    libpq-dev \
# mod_sndfile
    libsndfile1-dev libflac-dev libogg-dev libvorbis-dev \
# mod_shout
    libvorbis0a libogg0 libogg-dev libvorbis-dev libshout3-dev libmp3lame-dev libmpg123-dev libshout3-dev

RUN wget -O /bin/mkcert  https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64 \
  && chmod +x /bin/mkcert

COPY assets/*.tar.gz /tmp/

RUN cd /tmp && tar zxf freeswitch.tar.gz && tar zxf sofia-sip.tar.gz \
  && tar zxf libks.tar.gz && tar zxf spandsp.tar.gz \
  && mkdir -p /usr/src/libs  \
  && mv /tmp/freeswitch-1.10.12 /usr/src/freeswitch \
  && mv /tmp/sofia-sip-1.13.17 /usr/src/libs/sofia-sip \
  && mv /tmp/libks             /usr/src/libs/libks \
  && mv /tmp/spandsp           /usr/src/libs/spandsp


RUN cd /usr/src/libs/libks && cmake . -DCMAKE_INSTALL_PREFIX=/usr -DWITH_LIBBACKTRACE=1 && make install
RUN cd /usr/src/libs/sofia-sip && ./bootstrap.sh && ./configure CFLAGS="-g -ggdb" --with-pic --with-glib=no --without-doxygen --disable-stun --prefix=/usr && make -j`nproc --all` && make install
RUN cd /usr/src/libs/spandsp && ./bootstrap.sh && ./configure CFLAGS="-g -ggdb" --with-pic --prefix=/usr && make -j`nproc --all` && make install

RUN cd /usr/src/freeswitch && ./bootstrap.sh -j

#remove module
RUN cd /usr/src/freeswitch \
&& sed -i '/mod_signalwire/d' modules.conf

#add module
RUN cd /usr/src/freeswitch \
  && sed -i 's!#applications/mod_curl!applications/mod_curl!' modules.conf \
  && sed -i 's!#say/mod_say_zh!say/mod_say_zh!' modules.conf \
  && sed -i 's!#formats/mod_shout!formats/mod_shout!' modules.conf

RUN cd /usr/src/freeswitch \
  && ./configure \
  && make -j`nproc` install

RUN tar xvf /tmp/sounds.tar.gz -C /usr/local/freeswitch

RUN rm -rf /tmp/* \
  && rm -rf /usr/src/* \
  && apt-get clean

RUN ln -sfn /usr/local/freeswitch/bin/* /usr/bin/

RUN luarocks install inspect \
  && luarocks install lua-cjson

RUN rm -rf /usr/local/freeswitch/conf && rm -rf /usr/local/freeswitch/scripts
COPY conf /usr/local/freeswitch/conf
COPY scripts /usr/local/freeswitch/scripts

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
