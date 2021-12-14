#!/bin/bash
# Docker entrypoint for ION-DTN container image
# Ryan T. Moran
#
set -e

declare -r ion_version='4.10'
declare -r default_config_location='/usr/local/etc/ion/ion.rc'

# if first argument is single/double flag (-f | --option)
if [ "${1#-}" != "$1" ]; then
  echo "entry 1"
	set -- ionstart "$@"
# if first argument has 'rc' extension
elif [ "${1%.rc}" != "$1" ]; then
  echo "entry 2"
  set -- ionstart -I "$@"
elif [ "$1" = 'ionstart' -a "$(id -u)" = '0' ]; then
  # find . \! -user ionserv -exec chown ionserv:ionserv '{}' +
  set -- gosu ionserv "$0" "$@"

elif [ ${#} == 0 -o "${1}" != "ionstart" ]; then
  echo "entry 3"
  ionstart -I "${ION_CONFIG_PATH:=$default_config_location}"
  set -- "$@"
fi

"$@"

cat << EOF

ION Docker Container Started:
  ION-DTN:          v${ion_version}
  Bundle Protocol:  $(bpversion)

<Ctrl-C> to return
EOF

# necessary until ionstart entrypoint is rewritten
# to support foreground starts
sleep infinity
