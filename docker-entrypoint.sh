#!/bin/bash
set -e

# if first argument is single/double flag (-f | --option)
if [ "${1#-}" != "$1" ]; then
    echo 'entry 1'
	set -- ionstart "$@"
# if first argument has 'rc' extension
elif [ "${1%.rc}" != "$1" ]; then
    echo 'entry 2'
    set -- ionstart -I "$@"
# if first argument does not match above or ionstart, ensure
# the service is started prior to executing parameters
elif [ "$1" != "ionstart" ]; then
    echo 'entry 3'
    set -- ionstart -I /usr/local/etc/ion/sample.rc && "$@"
fi

# allow the container to be started with `--user`
# if [ "$1" = 'redis-server' -a "$(id -u)" = '0' ]; then
# 	find . \! -user redis -exec chown redis '{}' +
# 	exec gosu redis "$0" "$@"
# fi

echo "\
line1
line2
line3"

"$@" &

# ion tools do not run in foreground causing container
# to terminate on 'ionstart' return value
while true
do
    sleep 1
done