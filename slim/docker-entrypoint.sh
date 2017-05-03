#!/bin/sh

# "docker run -ti znc sh" should work, according to
# https://github.com/docker-library/official-images
if [ "${1:0:1}" != '-' ]; then
    exec "$@"
fi

# Options.
DATADIR="/znc-data"

# This file is added by znc:full image
if [ -r /znc-build-modules.sh ]; then
    source /znc-build-modules.sh || exit 3
fi

cd /

# Make sure $DATADIR is owned by znc user. This affects ownership of the
# mounted directory on the host machine too.
chown -R znc:root "$DATADIR" || exit 1
chmod 700 "$DATADIR" || exit 2

# ZNC itself responds to SIGTERM, and reaps its children, but whatever was
# started via *shell module is not guaranteed to reap their children.
# That's why using tini.
exec /sbin/tini -- su-exec znc:znc /opt/znc/bin/znc --foreground --datadir "$DATADIR" "$@"
