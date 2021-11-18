#!/bin/bash
set -e

# if first argument is single/double flag (-f | --option)
if [ "${1#-}" != "$1" ]; then
    echo "entry 1"
	set -- ionstart "$@"
fi

# if first argument has 'rc' extension
if [ "${1%.rc}" != "$1" ]; then
    echo "entry 2"
    set -- ionstart -I "$@"
fi

if [ ${#} == 0 -o "${1}" != "ionstart" ]; then
    echo "entry 3"
    ionstart -I "${ION_CONFIG_PATH:="/usr/local/etc/ion/ion.rc"}"
    set -- "$@"
fi

# allow the container to be started with `--user`
# if [ "$1" = 'redis-server' -a "$(id -u)" = '0' ]; then
# 	find . \! -user redis -exec chown redis '{}' +
# 	exec gosu redis "$0" "$@"
# fi

echo "\
ION DTNv4.10
$(bpversion)
Container intialized"

echo "$@"
"$@"

# ion tools do not run in foreground causing container
# to terminate on 'ionstart' return value
while true
do
    sleep 1
done
