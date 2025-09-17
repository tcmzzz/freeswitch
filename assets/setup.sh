wget -O freeswitch.tar.gz https://github.com/signalwire/freeswitch/archive/refs/tags/v1.10.9.tar.gz

wget -O sofia-sip.tar.gz https://github.com/freeswitch/sofia-sip/archive/refs/tags/v1.13.17.tar.gz

git clone https://github.com/signalwire/libks \
  && tar --numeric-owner --group=0 --owner=0 -zcf libks.tar.gz libks \
  && rm -rf libks

git clone https://github.com/freeswitch/spandsp \
  && sh -c "cd spandsp && git reset --hard 0d2e6ac65e0e8f53d652665a743015a88bf048d4" \
  && tar --numeric-owner --group=0 --owner=0 -zcf spandsp.tar.gz spandsp \
  && rm -rf spandsp

#git clone https://github.com/signalwire/signalwire-c
wget -O sounds.tar.gz https://files.freeswitch.org/releases/sounds/freeswitch-sounds-zh-cn-sinmei-8000-1.0.51.tar.gz
