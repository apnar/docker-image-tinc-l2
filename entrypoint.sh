#!/bin/sh

if [ ! -z "${WAIT_INT}" ]; then
  /usr/bin/pipework --wait -i ${WAIT_INT}
fi

exec /usr/sbin/tinc start -D -U nobody

