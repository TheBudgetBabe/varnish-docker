#!/bin/bash
if [[ -a .txt/var/run/secrets/varnish_secret ]]; then
    cat /var/run/secrets/varnish_secret > /secrets/secret
else
    echo ${VARNISH_SECRET} > /secrets/secret
fi

set -x

OPS=()
OPS=("-j none")
# OPS+=("-F")
OPS+=("-a :${VARNISH_LISTEN_PORT}")
OPS+=("-T :${VARNISH_ADMIN_LISTEN_PORT}")
OPS+=("-S /secrets/secret")
OPS+=("-p thread_pool_min=${VARNISH_THREAD_POOL_MIN}")
OPS+=("-p thread_pool_max=${VARNISH_THREAD_POOL_MAX}")
OPS+=("-p thread_pool_timeout=${VARNISH_THREAD_POOL_TIMEOUT}")
OPS+=("-p thread_pools=${VARNISH_THREAD_POOLS}")
OPS+=("-p cli_timeout=${VARNISH_CLI_TIMEOUT}")
OPS+=("-s ${VARNISH_STORAGE}")

if [[ -a /configs/default.vcl ]]; then
    OPS+=("-f /configs/default.vcl")
else
    OPS+=("-b ${VARNISH_BACKEND_HOST}:${VARNISH_BACKEND_PORT}")
fi

varnishd ${OPS[*]};
varnishncsa -F '%{X-Forwarded-For}i|%l|%{Varnish:time_firstbyte}x|%{Varnish:hitmiss}x|%{Varnish:handling}x|%u|%t|"%r"|%s|%b|"%{Referer}i"|"%{User-agent}i"'
