# Freeswitch Docker Build

简呼([lightcall](https://github.com/tcmzzz/lightcall)) 中使用了 [Freeswitch](https://github.com/signalwire/freeswitch), 用来沟通WebRTC 和其他SIP服务商

由于官方没有提供镜像, 这里构建了一个项目会用到的镜像, 其中集成了:
1. 项目用到的 Lua entrypoint
2. wss 证书的生成
3. 默认配置文件
