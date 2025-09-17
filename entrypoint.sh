#!/bin/bash

# Docker entrypoint script
mkdir -p /usr/local/freeswitch/conf

# 处理环境变量和默认值
BACKEND_ADDR=${BACKEND_ADDR:-"http://backend:8090"}
CERT_DOMAIN=${CERT_DOMAIN:-"my.wss.freeswitch"}
PASSWORD_FILE="/usr/local/freeswitch/conf/.xml_rpc_password"

# 处理xml_rpc_password
if [ -n "$XML_RPC_PASSWORD" ]; then
    echo "$XML_RPC_PASSWORD" > "$PASSWORD_FILE"
    XML_RPC_PASSWORD_VALUE="$XML_RPC_PASSWORD"
else
    if [ -f "$PASSWORD_FILE" ]; then
        XML_RPC_PASSWORD_VALUE=$(cat "$PASSWORD_FILE")
    else
        # 生成8位随机字母数字密码
        XML_RPC_PASSWORD_VALUE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
        echo "$XML_RPC_PASSWORD_VALUE" > "$PASSWORD_FILE"
        chmod 600 "$PASSWORD_FILE"
    fi
fi

echo "Using XML RPC Password: $XML_RPC_PASSWORD_VALUE"

# 生成SSL证书
echo "Generating SSL certificate for domain: $CERT_DOMAIN"
mkdir -p /cert
if [ ! -f "/cert/${CERT_DOMAIN}.pem" ] || [ ! -f "/cert/${CERT_DOMAIN}-key.pem" ]; then
    echo "Certificate not found, generating new certificate..."
    cd /cert
    mkcert $CERT_DOMAIN
    echo "Certificate generated successfully"
else
    echo "Certificate already exists, skipping generation"
fi

# 合并证书和私钥供FreeSWITCH WSS使用
echo "Combining certificate and key for FreeSWITCH WSS"
mkdir -p /usr/local/freeswitch/certs
cat "/cert/${CERT_DOMAIN}.pem" "/cert/${CERT_DOMAIN}-key.pem" > "/usr/local/freeswitch/certs/wss.pem"
chmod 600 "/usr/local/freeswitch/certs/wss.pem"
echo "Certificate combined successfully"

# 生成vars.xml配置文件
rm -f /usr/local/freeswitch/conf/vars.xml
cp /usr/local/freeswitch/conf/vars-tpl.xml /usr/local/freeswitch/conf/vars.xml

# 替换模板中的变量
sed -i "s|{{XML_RPC_PASSWORD}}|${XML_RPC_PASSWORD_VALUE}|g" /usr/local/freeswitch/conf/vars.xml
sed -i "s|{{BACKEND_ADDR}}|${BACKEND_ADDR}|g" /usr/local/freeswitch/conf/vars.xml

echo "Generated vars.xml with backend_addr: ${BACKEND_ADDR}"

# 启动FreeSWITCH
exec /usr/local/freeswitch/bin/freeswitch -nonat -c