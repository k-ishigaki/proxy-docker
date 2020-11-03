FROM alpine

LABEL maintainer="Kazuki Ishigaki<k-ishigaki@frontier.hokudai.ac.jp>"

EXPOSE 8080

RUN apk add --no-cache squid gettext curl

RUN touch /var/log/squid/access.log \
    && chown squid:squid /var/log/squid/access.log

# Create template conf
COPY squid.conf.template /tmp/

# Create endpoint script
RUN { \
    echo '#!/bin/sh -e'; \
    echo 'envsubst < /tmp/squid.conf.template > /etc/squid.conf'; \
    echo '/usr/sbin/squid -f /etc/squid.conf'; \
    echo 'tail -f /dev/null'; \
    } > /entrypoint && chmod +x /entrypoint

CMD [ "/entrypoint" ]
