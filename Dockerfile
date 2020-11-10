FROM alpine

LABEL maintainer="Kazuki Ishigaki<k-ishigaki@frontier.hokudai.ac.jp>"

EXPOSE 8080

# 'http_proxy' regular expression for `sed`.
# \1 : Scheme (http:// or https://)
# \2 : User authentification (<user>:<password>)
# \3 : Proxy's host (ip address or domain)
# \4 : Proxy's port number
ENV regular_expression='^(https?:\/\/)([^:]+:[^@]+)??@??([^:]+):([0-9]+)\/?$'

RUN export HTTP_PROXY_AUTH=$(echo $HTTP_PROXY | \
        sed -r 's/'"$regular_expression"'/basic:*:\2/' | \
        sed -r 's/%27/'"'"'/g' | \
        sed -r 's/%(..)/\\x\1/g' | \
        xargs -I {} echo -e {}) && \
    export HTTP_PROXY=$(echo $HTTP_PROXY | sed -r 's/'"$regular_expression"'/\1\3:\4/') && \
    apk add --no-cache squid gettext

RUN touch /var/log/squid/access.log \
    && chown squid:squid /var/log/squid/access.log

COPY squid.conf.template /

RUN { \
    echo '#!/bin/sh -e'; \
    echo 'export proxy_auth=`echo $HTTP_PROXY | sed -r '"'"'s/'"'"'$regular_expression'"'"'/\2/'"'"'`'; \
    echo 'export proxy_host=`echo $HTTP_PROXY | sed -r '"'"'s/'"'"'$regular_expression'"'"'/\3/'"'"'`'; \
    echo 'export proxy_port=`echo $HTTP_PROXY | sed -r '"'"'s/'"'"'$regular_expression'"'"'/\4/'"'"'`'; \
    echo 'envsubst < /squid.conf.template > /etc/squid.conf'; \
    echo '/usr/sbin/squid -f /etc/squid.conf'; \
    echo 'exec "$@"'; \
    } > /entrypoint && chmod +x /entrypoint
ENTRYPOINT [ "/entrypoint" ]

CMD [ "/bin/sh", "-c", "while sleep 1000; do :; done" ]
