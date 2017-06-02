#!/bin/sh

# For systems without journald
mkdir -p /var/log/journal

# Copy host libsystemd into image to avoid compatibility issues.
if [ ! -z "$(ls /host/lib/libsystemd* 2>/dev/null)" ]; then
  rm /lib/x86_64-linux-gnu/libsystemd*
  cp -a /host/lib/libsystemd* /lib/x86_64-linux-gnu/
fi

fluentd $@
